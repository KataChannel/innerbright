#!/bin/bash
# 🚀 Site-Only Docker Build & Deploy Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

progress() {
    echo -e "${BLUE}[PROGRESS]${NC} $1"
}

# Configuration
IMAGE_NAME="innerbright-site"
IMAGE_TAG="${1:-latest}"
CONTAINER_NAME="innerbright-site-container"
PORT="${2:-3000}"

# Main function
main() {
    log "🚀 Starting Site-Only Docker Build & Deploy Process"
    log "Image: ${IMAGE_NAME}:${IMAGE_TAG}"
    log "Port: ${PORT}"
    
    # Check if we're in the site directory
    if [ ! -f "package.json" ]; then
        error "package.json not found. Please run this script from the site directory."
    fi
    
    # Stop and remove existing container
    progress "🛑 Stopping existing container..."
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
    
    # Remove existing image for fresh build
    progress "🗑️ Removing existing image..."
    docker rmi "${IMAGE_NAME}:${IMAGE_TAG}" 2>/dev/null || true
    
    # Build the Docker image
    progress "🔨 Building Docker image..."
    docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" . || error "Docker build failed"
    
    success "✅ Docker image built successfully"
    
    # Run the container
    progress "🚀 Starting container..."
    docker run -d \
        --name "${CONTAINER_NAME}" \
        -p "${PORT}:3000" \
        -e BUILD_SITE_ONLY=true \
        -e NODE_ENV=production \
        -e NEXT_TELEMETRY_DISABLED=1 \
        "${IMAGE_NAME}:${IMAGE_TAG}" || error "Failed to start container"
    
    # Wait for container to start
    sleep 5
    
    # Check container status
    if docker ps | grep -q "${CONTAINER_NAME}"; then
        success "✅ Container started successfully"
        log "🌐 Site is running at: http://localhost:${PORT}"
        
        # Test health check
        progress "🔍 Testing health check..."
        sleep 10
        if curl -f "http://localhost:${PORT}" >/dev/null 2>&1; then
            success "✅ Site is responding correctly"
        else
            warning "⚠️ Site may not be ready yet, check logs: docker logs ${CONTAINER_NAME}"
        fi
    else
        error "❌ Container failed to start"
    fi
    
    # Show container info
    log "📊 Container Information:"
    docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    success "🎉 Site-Only deployment completed successfully!"
    log "📝 Useful commands:"
    log "   View logs: docker logs -f ${CONTAINER_NAME}"
    log "   Stop container: docker stop ${CONTAINER_NAME}"
    log "   Remove container: docker rm ${CONTAINER_NAME}"
}

# Help function
show_help() {
    echo "Usage: $0 [IMAGE_TAG] [PORT]"
    echo ""
    echo "Options:"
    echo "  IMAGE_TAG    Docker image tag (default: latest)"
    echo "  PORT         Host port to bind (default: 3000)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Build with 'latest' tag on port 3000"
    echo "  $0 v1.0.0            # Build with 'v1.0.0' tag on port 3000"
    echo "  $0 latest 8080       # Build with 'latest' tag on port 8080"
}

# Handle script arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    *)
        main
        ;;
esac
