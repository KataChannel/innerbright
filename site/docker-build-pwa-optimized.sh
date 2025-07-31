#!/bin/bash

# =============================================================================
# Docker Build với PWA Optimization - Giải quyết CPU 100% Hang Issue
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
PROJECT_NAME="innerbright-site"
DOCKER_IMAGE="$PROJECT_NAME:latest"
DOCKER_REGISTRY="ghcr.io/innerbright"
BUILD_TIMEOUT="1200" # 20 minutes timeout
MAX_RETRIES=3

log_info "🚀 Starting Docker build with PWA optimization..."

# Step 1: Pre-build checks
log_info "📋 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed"
    exit 1
fi

if ! command -v bun &> /dev/null; then
    log_warning "Bun not found, will use Node.js in Docker"
fi

# Step 2: Clean up previous builds
log_info "🧹 Cleaning up previous builds..."
docker system prune -f --filter "until=24h" 2>/dev/null || true
docker builder prune -f 2>/dev/null || true

# Step 3: Build with resource limits and PWA disabled
log_info "🔨 Building Docker image with PWA optimization..."

# Set environment variables to prevent PWA CPU spike
export DOCKER_BUILDKIT=1
export BUILDKIT_PROGRESS=plain
export DISABLE_PWA_BUILD=true
export DOCKER_BUILD=true
export NODE_OPTIONS="--max-old-space-size=2048"

# Function to perform Docker build with retries
build_docker_image() {
    local attempt=1
    
    while [ $attempt -le $MAX_RETRIES ]; do
        log_info "🔄 Build attempt $attempt/$MAX_RETRIES..."
        
        # Use timeout to prevent hanging builds
        if timeout $BUILD_TIMEOUT docker build \
            --progress=plain \
            --no-cache \
            --build-arg DISABLE_PWA_BUILD=true \
            --build-arg DOCKER_BUILD=true \
            --build-arg NODE_OPTIONS="--max-old-space-size=2048" \
            --build-arg BUILDKIT_INLINE_CACHE=1 \
            --memory=4g \
            --memory-swap=4g \
            --cpu-shares=1024 \
            --ulimit nofile=65536:65536 \
            -t "$DOCKER_IMAGE" \
            -f Dockerfile \
            ../; then
            
            log_success "✅ Docker build completed successfully!"
            return 0
        else
            log_warning "⚠️  Build attempt $attempt failed or timed out"
            
            # Clean up failed build artifacts
            docker system prune -f 2>/dev/null || true
            
            if [ $attempt -eq $MAX_RETRIES ]; then
                log_error "❌ All build attempts failed"
                return 1
            fi
            
            # Wait before next attempt
            log_info "⏳ Waiting 30 seconds before retry..."
            sleep 30
            
            ((attempt++))
        fi
    done
}

# Step 4: Execute build with monitoring
log_info "📊 Starting build with CPU/Memory monitoring..."

# Monitor system resources during build
monitor_resources() {
    while true; do
        if command -v htop &> /dev/null; then
            CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
            MEM_USAGE=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
            log_info "💻 CPU: ${CPU_USAGE}%, Memory: ${MEM_USAGE}%"
        fi
        sleep 30
    done
}

# Start resource monitoring in background
monitor_resources &
MONITOR_PID=$!

# Trap to cleanup monitor process
trap "kill $MONITOR_PID 2>/dev/null || true" EXIT

# Perform the build
if build_docker_image; then
    log_success "🎉 Docker build completed successfully!"
    
    # Step 5: Tag and prepare for deployment
    log_info "🏷️  Tagging image for deployment..."
    docker tag "$DOCKER_IMAGE" "$DOCKER_REGISTRY/$PROJECT_NAME:latest"
    docker tag "$DOCKER_IMAGE" "$DOCKER_REGISTRY/$PROJECT_NAME:$(date +%Y%m%d-%H%M%S)"
    
    # Step 6: Display build info
    log_info "📦 Build information:"
    echo "  - Image: $DOCKER_IMAGE"
    echo "  - Registry: $DOCKER_REGISTRY/$PROJECT_NAME"
    echo "  - Size: $(docker images --format "table {{.Size}}" $DOCKER_IMAGE | tail -n1)"
    
    # Step 7: Optional - Push to registry
    if [ "$1" = "--push" ]; then
        log_info "📤 Pushing to registry..."
        docker push "$DOCKER_REGISTRY/$PROJECT_NAME:latest"
        docker push "$DOCKER_REGISTRY/$PROJECT_NAME:$(date +%Y%m%d-%H%M%S)"
        log_success "✅ Images pushed to registry!"
    fi
    
    # Step 8: Cleanup build cache
    log_info "🧹 Cleaning up build cache..."
    docker builder prune -f --filter type=exec.cachemount
    docker builder prune -f --filter type=source.local
    
    log_success "🚀 Build process completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Test the image locally: docker run -p 3000:3000 $DOCKER_IMAGE"
    echo "2. Deploy to server: ./deploy-site-production.sh"
    echo "3. Monitor deployment: docker logs -f innerbright-site"
    
else
    log_error "❌ Docker build failed after $MAX_RETRIES attempts"
    
    # Debug information
    log_info "🔍 Debug information:"
    echo "  - Docker version: $(docker --version)"
    echo "  - Available memory: $(free -h | grep Mem | awk '{print $7}')"
    echo "  - Available disk: $(df -h . | tail -1 | awk '{print $4}')"
    
    # Suggest solutions
    echo ""
    echo "💡 Suggested solutions:"
    echo "1. Free up memory: docker system prune -a"
    echo "2. Increase Docker memory limit"
    echo "3. Build on a machine with more resources"
    echo "4. Use build-deploy-optimized.sh for local build + server deploy"
    
    exit 1
fi

# Kill monitor process
kill $MONITOR_PID 2>/dev/null || true
