#!/bin/bash

# =============================================================================
# Memory-Optimized Build Script for Low-Resource Servers
# Prevents RAM exhaustion during Next.js builds
# =============================================================================

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configuration
MEMORY_LIMIT_BUILD="800m"
MEMORY_LIMIT_RUNTIME="400m"
CPU_LIMIT="0.5"
BUILD_TIMEOUT="900"

print_status "🚀 Starting memory-optimized build process..."

# Memory monitoring function
monitor_memory() {
    while true; do
        if command -v free >/dev/null 2>&1; then
            MEMORY_INFO=$(free | grep Mem)
            TOTAL_MEM=$(echo $MEMORY_INFO | awk '{print $2}')
            USED_MEM=$(echo $MEMORY_INFO | awk '{print $3}')
            MEMORY_USAGE=$(echo "scale=1; $USED_MEM * 100 / $TOTAL_MEM" | bc 2>/dev/null || echo "0")
            
            print_status "💻 Memory: ${MEMORY_USAGE}% (${USED_MEM}/${TOTAL_MEM})"
            
            # Kill build if memory usage is too high
            if (( $(echo "$MEMORY_USAGE > 95.0" | bc -l 2>/dev/null || echo 0) )); then
                print_error "Memory usage critical (${MEMORY_USAGE}%), stopping build"
                pkill -f "next build" 2>/dev/null || true
                exit 1
            fi
        fi
        sleep 15
    done
}

# Free up system memory before build
free_memory() {
    print_status "🧹 Freeing system memory..."
    
    # Clear cache if running as root
    if [ "$EUID" -eq 0 ]; then
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
        print_status "System cache cleared"
    fi
    
    # Docker cleanup
    print_status "Cleaning Docker resources..."
    docker system prune -f --volumes 2>/dev/null || true
    docker builder prune -f 2>/dev/null || true
    
    print_success "Memory cleanup completed"
}

# Build with extreme memory optimization
build_memory_optimized() {
    print_status "🔨 Building with strict memory limits..."
    
    # Start memory monitoring in background
    monitor_memory &
    MONITOR_PID=$!
    
    # Trap to kill monitor on exit
    trap "kill $MONITOR_PID 2>/dev/null || true" EXIT
    
    # Free memory first
    free_memory
    
    # Environment variables for memory optimization
    export NODE_ENV=production
    export NEXT_TELEMETRY_DISABLED=1
    export BUILD_SITE_ONLY=true
    export DISABLE_PWA_BUILD=true
    export SKIP_ENV_VALIDATION=true
    
    # Very conservative memory settings
    export NODE_OPTIONS="--max-old-space-size=512 --max-semi-space-size=64 --optimize-for-size"
    export UV_THREADPOOL_SIZE=1
    export NEXT_BUILD_WORKERS=1
    
    print_status "⏳ Starting build (timeout: ${BUILD_TIMEOUT}s)..."
    
    # Build with timeout and memory constraints
    if timeout ${BUILD_TIMEOUT}s npm run build 2>&1 | tee build.log; then
        print_success "✅ Local build completed successfully"
        
        # Clean up build artifacts
        print_status "🧹 Cleaning build artifacts..."
        rm -rf node_modules/.cache 2>/dev/null || true
        rm -rf .next/cache/webpack 2>/dev/null || true
        rm -rf .next/cache/images 2>/dev/null || true
        rm -rf /tmp/* 2>/dev/null || true
        
        # Kill monitor
        kill $MONITOR_PID 2>/dev/null || true
        return 0
    else
        print_error "❌ Build failed or timed out"
        print_status "💾 Final memory status:"
        free -h 2>/dev/null || true
        
        # Kill monitor
        kill $MONITOR_PID 2>/dev/null || true
        return 1
    fi
}

# Docker build with resource limits
build_docker_memory_limited() {
    print_status "🐳 Building Docker image with memory limits..."
    
    # Free memory before Docker build
    free_memory
    
    print_status "Building with limits: Memory=${MEMORY_LIMIT_BUILD}, CPU=${CPU_LIMIT}"
    
    # Build with very strict resource constraints
    if docker build \
        --memory="${MEMORY_LIMIT_BUILD}" \
        --memory-swap="${MEMORY_LIMIT_BUILD}" \
        --cpu-quota=50000 \
        --cpu-period=100000 \
        --no-cache \
        --progress=plain \
        --build-arg NODE_OPTIONS="--max-old-space-size=512" \
        --build-arg DISABLE_PWA_BUILD=true \
        -f Dockerfile.site-only \
        -t innerbright-site:memory-optimized \
        . 2>&1 | tee docker-build.log; then
        
        print_success "✅ Docker build completed successfully"
        
        # Show image size
        IMAGE_SIZE=$(docker images --format "table {{.Size}}" innerbright-site:memory-optimized | tail -n1)
        print_status "📦 Image size: $IMAGE_SIZE"
        
        return 0
    else
        print_error "❌ Docker build failed due to memory constraints"
        print_status "💡 Consider using local build approach instead"
        return 1
    fi
}

# Deploy memory-optimized container
deploy_memory_optimized() {
    print_status "🚀 Deploying memory-optimized container..."
    
    # Stop existing container
    docker stop innerbright-site 2>/dev/null || true
    docker rm innerbright-site 2>/dev/null || true
    
    # Start with memory constraints
    docker run -d \
        --name innerbright-site \
        --memory="${MEMORY_LIMIT_RUNTIME}" \
        --memory-swap="${MEMORY_LIMIT_RUNTIME}" \
        --cpus="${CPU_LIMIT}" \
        --restart unless-stopped \
        -p 3000:3000 \
        -e NODE_OPTIONS="--max-old-space-size=256" \
        innerbright-site:memory-optimized
    
    print_status "⏳ Waiting for container to start..."
    sleep 15
    
    # Health check
    if curl -f http://localhost:3000 >/dev/null 2>&1; then
        print_success "✅ Container is running and healthy"
        
        # Show container stats
        docker stats --no-stream innerbright-site 2>/dev/null || true
    else
        print_warning "⚠️  Container started but may not be ready yet"
        print_status "📋 Container logs:"
        docker logs innerbright-site --tail 20
    fi
}

# Create minimal transfer image for remote deployment
create_transfer_image() {
    print_status "📦 Creating minimal transfer image..."
    
    # Ensure build exists
    if [ ! -d ".next/standalone" ]; then
        print_error "Build output not found. Run build first."
        return 1
    fi
    
    # Create minimal Dockerfile
    cat > Dockerfile.minimal << 'EOF'
FROM node:20-alpine
WORKDIR /app
RUN apk add --no-cache ca-certificates dumb-init && \
    addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs
COPY .next/standalone ./
COPY .next/static ./.next/static
COPY public ./public
RUN chown -R nextjs:nodejs /app
USER nextjs
EXPOSE 3000
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=256"
ENV HOSTNAME="0.0.0.0"
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]
EOF
    
    # Build minimal image
    docker build -f Dockerfile.minimal -t innerbright-site:minimal .
    
    # Clean up temporary Dockerfile
    rm -f Dockerfile.minimal
    
    print_success "✅ Minimal transfer image created"
}

# Show usage
show_usage() {
    echo "Usage: $0 [build|docker|deploy|transfer|full|clean]"
    echo ""
    echo "Commands:"
    echo "  build     - Build locally with memory optimization"
    echo "  docker    - Build Docker image with memory limits"
    echo "  deploy    - Deploy memory-optimized container"
    echo "  transfer  - Create minimal image for transfer"
    echo "  full      - Complete build and deploy process"
    echo "  clean     - Clean up temporary files and containers"
}

# Clean up function
cleanup() {
    print_status "🧹 Cleaning up..."
    
    # Remove build logs
    rm -f build.log docker-build.log
    
    # Clean Docker
    docker system prune -f 2>/dev/null || true
    
    # Clean build cache
    rm -rf node_modules/.cache 2>/dev/null || true
    rm -rf .next/cache 2>/dev/null || true
    
    print_success "✅ Cleanup completed"
}

# Main execution
case "${1:-full}" in
    "build")
        build_memory_optimized
        ;;
    "docker")
        build_docker_memory_limited
        ;;
    "deploy")
        deploy_memory_optimized
        ;;
    "transfer")
        build_memory_optimized && create_transfer_image
        ;;
    "full")
        if build_memory_optimized; then
            if build_docker_memory_limited; then
                deploy_memory_optimized
            else
                print_warning "Docker build failed, creating transfer image instead"
                create_transfer_image
            fi
        else
            print_error "Local build failed, cannot proceed"
            exit 1
        fi
        ;;
    "clean")
        cleanup
        ;;
    "help"|"-h"|"--help")
        show_usage
        ;;
    *)
        print_error "Invalid command: $1"
        show_usage
        exit 1
        ;;
esac
