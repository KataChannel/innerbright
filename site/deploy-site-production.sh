#!/bin/bash
# 🚀 Site-Only Production Deploy Script

set -e

# Configuration
PROJECT_NAME="innerbright"
SERVICE_NAME="site"
IMAGE_NAME="${PROJECT_NAME}-${SERVICE_NAME}"
DOCKERFILE="Dockerfile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
progress() { echo -e "${BLUE}[PROGRESS]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    if [ ! -f "package.json" ]; then
        error "package.json not found. Run from site directory."
    fi
    
    if [ ! -f "${DOCKERFILE}" ]; then
        error "Dockerfile not found. Please create it first."
    fi
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    success "✅ Prerequisites check passed"
}

# Clean up old containers and images
cleanup() {
    progress "🧹 Cleaning up old containers and images..."
    
    # Stop and remove container
    docker stop "${PROJECT_NAME}-${SERVICE_NAME}" 2>/dev/null || true
    docker rm "${PROJECT_NAME}-${SERVICE_NAME}" 2>/dev/null || true
    
    # Remove old images (keep last 2 versions)
    OLD_IMAGES=$(docker images "${IMAGE_NAME}" --format "{{.ID}}" | tail -n +3)
    if [ -n "$OLD_IMAGES" ]; then
        echo "$OLD_IMAGES" | xargs docker rmi -f 2>/dev/null || true
        log "Removed old Docker images"
    fi
    
    success "✅ Cleanup completed"
}

# Build Docker image
build_image() {
    local tag="${1:-latest}"
    progress "🔨 Building Docker image: ${IMAGE_NAME}:${tag}"
    
    # Build with timestamp tag for versioning
    local timestamp=$(date +%Y%m%d-%H%M%S)
    
    docker build \
        -t "${IMAGE_NAME}:${tag}" \
        -t "${IMAGE_NAME}:${timestamp}" \
        --build-arg BUILD_SITE_ONLY=true \
        --build-arg NODE_ENV=production \
        -f "${DOCKERFILE}" \
        . || error "Docker build failed"
    
    success "✅ Docker image built: ${IMAGE_NAME}:${tag}"
}

# Deploy with Docker Compose
deploy_with_compose() {
    progress "🚀 Deploying with Docker Compose..."
    
    if [ -f "../docker-compose.yml" ]; then
        cd ..
        COMPOSE_PROJECT_NAME="${PROJECT_NAME}" docker-compose up -d --build site
        cd site
        success "✅ Deployed with Docker Compose"
    else
        warning "⚠️ docker-compose.yml not found, using direct Docker run"
        deploy_direct
    fi
}

# Direct Docker deployment
deploy_direct() {
    local tag="${1:-latest}"
    local port="${2:-3000}"
    
    progress "🚀 Deploying container directly..."
    
    docker run -d \
        --name "${PROJECT_NAME}-${SERVICE_NAME}" \
        --restart unless-stopped \
        -p "${port}:3000" \
        -e BUILD_SITE_ONLY=true \
        -e NODE_ENV=production \
        -e NEXT_TELEMETRY_DISABLED=1 \
        -e PORT=3000 \
        -e HOSTNAME="0.0.0.0" \
        "${IMAGE_NAME}:${tag}" || error "Failed to start container"
    
    success "✅ Container deployed: ${PROJECT_NAME}-${SERVICE_NAME}"
}

# Health check
health_check() {
    local port="${1:-3000}"
    progress "🔍 Performing health check..."
    
    # Wait for container to be ready
    sleep 10
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f "http://localhost:${port}" >/dev/null 2>&1; then
            success "✅ Site is healthy and responding"
            return 0
        fi
        
        log "Health check attempt ${attempt}/${max_attempts}..."
        sleep 2
        ((attempt++))
    done
    
    warning "⚠️ Health check failed after ${max_attempts} attempts"
    return 1
}

# Show deployment info
show_info() {
    local port="${1:-3000}"
    
    success "🎉 Site-Only deployment completed!"
    echo ""
    log "📊 Container Information:"
    docker ps --filter "name=${PROJECT_NAME}-${SERVICE_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    log "🌐 Access URLs:"
    log "   • Site: http://localhost:${port}"
    echo ""
    log "📝 Management Commands:"
    log "   • View logs: docker logs -f ${PROJECT_NAME}-${SERVICE_NAME}"
    log "   • Stop: docker stop ${PROJECT_NAME}-${SERVICE_NAME}"
    log "   • Restart: docker restart ${PROJECT_NAME}-${SERVICE_NAME}"
    log "   • Remove: docker rm -f ${PROJECT_NAME}-${SERVICE_NAME}"
}

# Main deployment function
main() {
    local deployment_type="${1:-compose}"
    local tag="${2:-latest}"
    local port="${3:-3000}"
    
    log "🚀 Starting Site-Only Production Deployment"
    log "Type: ${deployment_type}, Tag: ${tag}, Port: ${port}"
    
    check_prerequisites
    cleanup
    build_image "${tag}"
    
    case "${deployment_type}" in
        "compose")
            deploy_with_compose
            ;;
        "direct")
            deploy_direct "${tag}" "${port}"
            ;;
        *)
            error "Unknown deployment type: ${deployment_type}"
            ;;
    esac
    
    health_check "${port}"
    show_info "${port}"
}

# Help function
show_help() {
    echo "Usage: $0 [DEPLOYMENT_TYPE] [TAG] [PORT]"
    echo ""
    echo "Parameters:"
    echo "  DEPLOYMENT_TYPE   'compose' or 'direct' (default: compose)"
    echo "  TAG              Docker image tag (default: latest)"
    echo "  PORT             Host port to bind (default: 3000)"
    echo ""
    echo "Examples:"
    echo "  $0                        # Deploy with Docker Compose"
    echo "  $0 direct                 # Deploy directly with Docker"
    echo "  $0 compose v1.0.0         # Deploy specific version with Compose"
    echo "  $0 direct latest 8080     # Deploy on port 8080"
}

# Handle arguments
case "${1:-}" in
    "help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
