#!/bin/bash

# 🚀 Build Local + Deploy Docker Optimized Script
# Tối ưu hóa tốc độ build và dung lượng Docker image

set -e

# Configuration
PROJECT_NAME="innerbright-site"
DOCKER_IMAGE="$PROJECT_NAME:latest"
DOCKERFILE="Dockerfile"
SERVER_IP="116.118.85.41"
SERVER_USER="root"
SSH_KEY_PATH="$HOME/.ssh/default"
CONTAINER_NAME="innerbright-site-only"
HOST_PORT="3000"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
success() { echo -e "${GREEN}✅ $1${NC}"; }

show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║              🚀 Build Local + Deploy Docker Optimized                       ║
║                                                                              ║
║    Tối ưu tốc độ build và dung lượng Docker cho production                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Check prerequisites
check_prerequisites() {
    log "🔍 Checking prerequisites..."
    
    # Check if we're in the right directory
    if [[ ! -f "package.json" ]] || [[ ! -f "next.config.ts" ]]; then
        error "Please run this script from the site directory"
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
    fi
    
    # Check if bun is installed
    if ! command -v bun &> /dev/null; then
        warn "Bun is not installed, using npm instead"
        BUILD_CMD="npm run"
    else
        BUILD_CMD="bun run"
    fi
    
    success "Prerequisites checked"
}

# Clean build artifacts
clean_build() {
    log "🧹 Cleaning previous build artifacts..."
    
    rm -rf .next
    rm -rf dist
    rm -rf build
    
    success "Build artifacts cleaned"
}

# Build application locally with optimizations
build_local() {
    log "🔨 Building application locally with optimizations..."
    
    # Install dependencies if node_modules doesn't exist
    if [[ ! -d "node_modules" ]]; then
        log "📦 Installing dependencies..."
        if command -v bun &> /dev/null; then
            bun install
        else
            npm install
        fi
    fi
    
    # Set environment variables for optimal build
    export BUILD_SITE_ONLY=true
    export NEXT_TELEMETRY_DISABLED=1
    export NODE_ENV=production
    export NODE_OPTIONS="--max-old-space-size=4096"
    
    # Build with the fastest available method
    if command -v bun &> /dev/null; then
        info "Using Bun for fastest build..."
        bun run build:site-only || error "Bun build failed"
    else
        info "Using npm for build..."
        npm run build:site-only || npm run build || error "NPM build failed"
    fi
    
    # Verify standalone build exists
    if [[ ! -d ".next/standalone" ]]; then
        error "Standalone build not found. Make sure output: 'standalone' is set in next.config.ts"
    fi
    
    # Verify static build exists
    if [[ ! -d ".next/static" ]]; then
        warn "Static build directory not found, creating empty directory"
        mkdir -p .next/static
    fi
    
    # Check build size
    local build_size=$(du -sh .next 2>/dev/null | cut -f1 || echo "unknown")
    info "Build size: $build_size"
    
    success "Local build completed"
}

# Build optimized Docker image
build_docker_image() {
    log "🐳 Building optimized Docker image..."
    
    # Remove old images to save space
    docker image prune -f >/dev/null 2>&1 || true
    
    # Build with optimizations
    DOCKER_BUILDKIT=1 docker build \
        --no-cache \
        --rm \
        --compress \
        -t "$DOCKER_IMAGE" \
        -f "$DOCKERFILE" \
        . || error "Docker build failed"
    
    # Show image size
    local image_size=$(docker images "$DOCKER_IMAGE" --format "table {{.Size}}" | tail -n 1)
    info "Docker image size: $image_size"
    
    success "Docker image built successfully"
}

# Deploy to server
deploy_to_server() {
    log "🚀 Deploying to server..."
    
    # Test SSH connection
    if ! ssh -i "$SSH_KEY_PATH" -o ConnectTimeout=10 "$SERVER_USER@$SERVER_IP" "echo 'SSH OK'" >/dev/null 2>&1; then
        error "Cannot connect to server $SERVER_IP"
    fi
    
    # Export Docker image
    log "📤 Exporting Docker image..."
    docker save "$DOCKER_IMAGE" | gzip > "/tmp/${PROJECT_NAME}.tar.gz"
    
    # Transfer image to server
    log "📡 Transferring image to server..."
    scp -i "$SSH_KEY_PATH" "/tmp/${PROJECT_NAME}.tar.gz" "$SERVER_USER@$SERVER_IP:/tmp/" || error "Failed to transfer image"
    
    # Deploy on server
    log "🔄 Deploying on server..."
    ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_IP" << EOF
        set -e
        
        echo "📥 Loading Docker image..."
        docker load < "/tmp/${PROJECT_NAME}.tar.gz"
        
        echo "🛑 Stopping old container..."
        docker stop "$CONTAINER_NAME" 2>/dev/null || true
        docker rm "$CONTAINER_NAME" 2>/dev/null || true
        
        echo "🚀 Starting new container..."
        docker run -d \
            --name "$CONTAINER_NAME" \
            --restart unless-stopped \
            -p "$HOST_PORT:3000" \
            -e NODE_ENV=production \
            -e NEXT_TELEMETRY_DISABLED=1 \
            "$DOCKER_IMAGE"
        
        echo "⏳ Waiting for container to start..."
        sleep 10
        
        echo "🔍 Checking container health..."
        if docker ps | grep -q "$CONTAINER_NAME"; then
            echo "✅ Container is running"
            if curl -f -s "http://localhost:$HOST_PORT" >/dev/null 2>&1; then
                echo "✅ Service is responding"
            else
                echo "⚠️  Service might still be starting..."
            fi
        else
            echo "❌ Container failed to start"
            docker logs "$CONTAINER_NAME" --tail 20
            exit 1
        fi
        
        echo "🧹 Cleaning up..."
        rm -f "/tmp/${PROJECT_NAME}.tar.gz"
        docker image prune -f >/dev/null 2>&1 || true
EOF
    
    # Clean up local temp file
    rm -f "/tmp/${PROJECT_NAME}.tar.gz"
    
    success "Deployment completed successfully"
}

# Show deployment info
show_deployment_info() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                         🎉 DEPLOYMENT SUCCESSFUL!                           ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${BLUE}🌐 Service Information:${NC}"
    echo -e "   📍 Server: $SERVER_IP:$HOST_PORT"
    echo -e "   🌍 URL: http://$SERVER_IP:$HOST_PORT"
    echo -e "   🐳 Container: $CONTAINER_NAME"
    echo -e "   📦 Image: $DOCKER_IMAGE"
    echo ""
    
    echo -e "${BLUE}📋 Management Commands:${NC}"
    echo -e "   🔍 Check logs: ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_IP 'docker logs $CONTAINER_NAME'"
    echo -e "   🔄 Restart: ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_IP 'docker restart $CONTAINER_NAME'"
    echo -e "   ⏹️  Stop: ssh -i $SSH_KEY_PATH $SERVER_USER@$SERVER_IP 'docker stop $CONTAINER_NAME'"
    echo ""
}

# Main deployment function
main() {
    local action="${1:-deploy}"
    
    show_banner
    
    case "$action" in
        "build")
            check_prerequisites
            clean_build
            build_local
            build_docker_image
            ;;
        "deploy")
            check_prerequisites
            clean_build
            build_local
            build_docker_image
            deploy_to_server
            show_deployment_info
            ;;
        "clean")
            clean_build
            docker rmi "$DOCKER_IMAGE" 2>/dev/null || true
            success "Cleaned build artifacts and Docker image"
            ;;
        "logs")
            ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_IP" "docker logs $CONTAINER_NAME --tail 50 -f"
            ;;
        "status")
            ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_IP" << EOF
                echo "Container Status:"
                docker ps --filter name=$CONTAINER_NAME
                echo ""
                echo "Resource Usage:"
                docker stats $CONTAINER_NAME --no-stream
EOF
            ;;
        "restart")
            ssh -i "$SSH_KEY_PATH" "$SERVER_USER@$SERVER_IP" "docker restart $CONTAINER_NAME"
            success "Container restarted"
            ;;
        *)
            echo "Usage: $0 [build|deploy|clean|logs|status|restart]"
            echo ""
            echo "Commands:"
            echo "  build   - Build locally and create Docker image"
            echo "  deploy  - Full build and deploy to server (default)"
            echo "  clean   - Clean build artifacts and Docker image"
            echo "  logs    - Show container logs"
            echo "  status  - Show container status and resources"
            echo "  restart - Restart container on server"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
