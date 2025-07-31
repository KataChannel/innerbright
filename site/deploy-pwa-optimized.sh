#!/bin/bash

# =============================================================================
# PWA-Optimized Site Deployment - Giải quyết vấn đề CPU 100% hang
# Build local + Deploy remote để tránh PWA compilation trên server
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
CONTAINER_NAME="innerbright-site"
DOCKER_IMAGE="$PROJECT_NAME:latest"
SITE_DIR="/chikiet/Innerbright/innerbright/site"
BUILD_TIMEOUT="900" # 15 minutes timeout for local build

log_info "🚀 Starting PWA-optimized deployment process..."

# Step 1: Validate environment
log_info "📋 Validating environment..."

if [ ! -d "$SITE_DIR" ]; then
    log_error "Site directory not found: $SITE_DIR"
    exit 1
fi

if ! command -v bun &> /dev/null; then
    log_error "Bun is required for optimized builds"
    log_info "Install Bun: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

cd "$SITE_DIR"

# Step 2: Pre-deployment cleanup
log_info "🧹 Cleaning up previous builds..."

# Clean local build artifacts
rm -rf .next 2>/dev/null || true
rm -rf node_modules/.cache 2>/dev/null || true

# Clean Docker resources
docker container stop "$CONTAINER_NAME" 2>/dev/null || true
docker container rm "$CONTAINER_NAME" 2>/dev/null || true
docker image prune -f 2>/dev/null || true

# Step 3: Install dependencies with Bun
log_info "📦 Installing dependencies with Bun..."

if ! bun install --frozen-lockfile; then
    log_error "Failed to install dependencies"
    exit 1
fi

# Generate Prisma client
log_info "🔧 Generating Prisma client..."
bunx prisma generate --schema=./prisma/schema.prisma

# Step 4: LOCAL BUILD với PWA tắt để tránh CPU spike
log_info "🔨 Building locally with PWA disabled to prevent CPU hang..."

# Environment variables để tắt PWA khi build local
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export DISABLE_PWA_BUILD=true  # 🔑 Key: Tắt PWA để tránh CPU 100%
export BUILD_SITE_ONLY=true
export NODE_OPTIONS="--max-old-space-size=4096"

# Build với timeout để tránh hang
log_info "⏳ Starting timed build (max $BUILD_TIMEOUT seconds)..."

if timeout $BUILD_TIMEOUT bash -c '
    log_info() {
        echo -e "\033[0;34m[INFO]\033[0m $1"
    }
    
    log_info "🏗️  Building Next.js application..."
    if bun run build; then
        log_info "✅ Build completed successfully"
        exit 0
    else
        log_info "❌ Build failed"
        exit 1
    fi
'; then
    log_success "✅ Local build completed successfully!"
else
    log_error "❌ Local build failed or timed out"
    log_info "💡 Try building with smaller memory limit:"
    log_info "   NODE_OPTIONS=\"--max-old-space-size=2048\" bun run build"
    exit 1
fi

# Step 5: Verify build output
log_info "🔍 Verifying build output..."

if [ ! -d ".next/standalone" ]; then
    log_error "Standalone build output not found"
    log_info "Make sure output: 'standalone' is set in next.config.ts"
    exit 1
fi

if [ ! -d ".next/static" ]; then
    log_error "Static assets not found"
    exit 1
fi

BUILD_SIZE=$(du -sh .next | cut -f1)
log_info "📊 Build size: $BUILD_SIZE"

# Step 6: Build Docker image từ pre-built application
log_info "🐳 Building Docker image from pre-built application..."

# Tạo Dockerfile.prebuilt để copy pre-built application
cat > Dockerfile.prebuilt << 'EOF'
FROM oven/bun:1-alpine AS runner

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache \
    libc6-compat \
    dumb-init \
    ca-certificates

# Create app user for security
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy pre-built application (built locally with PWA disabled)
COPY --chown=nextjs:nodejs .next/standalone ./
COPY --chown=nextjs:nodejs .next/static ./.next/static
COPY --chown=nextjs:nodejs public ./public

# Copy node_modules for runtime dependencies
COPY --chown=nextjs:nodejs node_modules/.prisma ./node_modules/.prisma
COPY --chown=nextjs:nodejs node_modules/@prisma ./node_modules/@prisma

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000
ENV NEXT_TELEMETRY_DISABLED=1
ENV HOSTNAME="0.0.0.0"

# Expose port
EXPOSE 3000

# Switch to non-root user
USER nextjs

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["bun", "run", "server.js"]
EOF

# Build Docker image (không cần compile lại PWA)
if docker build -f Dockerfile.prebuilt -t "$DOCKER_IMAGE" .; then
    log_success "✅ Docker image built successfully!"
    rm -f Dockerfile.prebuilt
else
    log_error "❌ Docker build failed"
    rm -f Dockerfile.prebuilt
    exit 1
fi

# Step 7: Start new container
log_info "🚀 Starting new container..."

if docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    --memory="2g" \
    --memory-swap="2g" \
    --cpu-shares=1024 \
    -p 3000:3000 \
    -e NODE_ENV=production \
    -e NEXT_TELEMETRY_DISABLED=1 \
    "$DOCKER_IMAGE"; then
    
    log_success "✅ Container started successfully!"
else
    log_error "❌ Failed to start container"
    exit 1
fi

# Step 8: Health check
log_info "🩺 Performing health check..."

# Wait for container to be ready
sleep 10

if docker ps | grep -q "$CONTAINER_NAME"; then
    log_success "✅ Container is running"
    
    # Check if application responds
    for i in {1..30}; do
        if curl -f http://localhost:3000 >/dev/null 2>&1; then
            log_success "✅ Application is responding on port 3000"
            break
        fi
        
        if [ $i -eq 30 ]; then
            log_warning "⚠️  Application not responding after 30 attempts"
            log_info "📋 Container logs:"
            docker logs "$CONTAINER_NAME" --tail 20
        else
            echo -n "."
            sleep 2
        fi
    done
else
    log_error "❌ Container is not running"
    log_info "📋 Container logs:"
    docker logs "$CONTAINER_NAME"
    exit 1
fi

# Step 9: Cleanup
log_info "🧹 Cleaning up build artifacts..."
rm -rf .next/cache 2>/dev/null || true
rm -rf node_modules/.cache 2>/dev/null || true
docker image prune -f 2>/dev/null || true

# Step 10: Display deployment info
log_success "🎉 Deployment completed successfully!"
echo ""
echo "📊 Deployment Summary:"
echo "  - Image: $DOCKER_IMAGE"
echo "  - Container: $CONTAINER_NAME"
echo "  - Port: 3000"
echo "  - Status: $(docker ps --format 'table {{.Status}}' --filter "name=$CONTAINER_NAME" | tail -n1)"
echo "  - Memory: $(docker stats --no-stream --format 'table {{.MemUsage}}' "$CONTAINER_NAME" 2>/dev/null || echo 'N/A')"
echo ""
echo "🔗 Quick commands:"
echo "  - View logs: docker logs -f $CONTAINER_NAME"
echo "  - Check stats: docker stats $CONTAINER_NAME"
echo "  - Stop: docker stop $CONTAINER_NAME"
echo "  - Restart: docker restart $CONTAINER_NAME"
echo ""
echo "🌐 Application URL: http://localhost:3000"

# Final verification
log_info "🔍 Final verification..."
if curl -f http://localhost:3000 >/dev/null 2>&1; then
    log_success "✅ Site is live and accessible!"
else
    log_warning "⚠️  Site may still be starting up. Check logs if issues persist."
fi
