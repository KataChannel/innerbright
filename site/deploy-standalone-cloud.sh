#!/bin/bash

# =============================================================================
# Optimized Standalone Build & Cloud Deploy Script
# Build locally with minimal resources then deploy to cloud server
# =============================================================================

set -euo pipefail

# Colors for output
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Configuration
CLOUD_USER="${CLOUD_USER:-root}"
CLOUD_HOST="${CLOUD_HOST:-116.118.85.41}"
CLOUD_PATH="${CLOUD_PATH:-/var/www/innerbright/site}"
SSH_KEY="${SSH_KEY:-~/.ssh/id_rsa}"
BUILD_TIMEOUT="${BUILD_TIMEOUT:-900}"
CONTAINER_NAME="innerbright-site"

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

# Function to build standalone locally
build_standalone_local() {
    log_info "🔨 Building Next.js standalone locally..."
    
    # Clean previous build
    rm -rf .next node_modules/.cache
    
    # Build with optimized settings for cloud deployment
    timeout $BUILD_TIMEOUT env \
        DISABLE_PWA_BUILD=true \
        NODE_ENV=production \
        NEXT_TELEMETRY_DISABLED=1 \
        SKIP_ENV_VALIDATION=true \
        NODE_OPTIONS="--max-old-space-size=4096" \
        npm run build
    
    if [ ! -d ".next/standalone" ]; then
        log_error "❌ Standalone build failed - no output directory found"
        exit 1
    fi
    
    log_success "✅ Standalone build completed"
    
    # Show build size
    BUILD_SIZE=$(du -sh .next | cut -f1)
    log_info "📦 Build size: $BUILD_SIZE"
}

# Function to sync build to cloud server
sync_to_cloud() {
    log_info "☁️  Syncing build artifacts to cloud server..."
    
    # Test connection
    if ! ssh -i $SSH_KEY -o ConnectTimeout=10 $CLOUD_USER@$CLOUD_HOST "echo 'Connection OK'" >/dev/null 2>&1; then
        log_error "❌ Cannot connect to cloud server"
        exit 1
    fi
    
    # Create directory structure on server
    ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "
        mkdir -p $CLOUD_PATH/{.next/static,public,node_modules/{.prisma,@prisma}}
    "
    
    # Sync standalone build (main application)
    log_info "📄 Syncing standalone application..."
    rsync -avz --delete --progress \
        -e "ssh -i $SSH_KEY" \
        .next/standalone/ \
        $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/
    
    # Sync static assets
    log_info "🎨 Syncing static assets..."
    rsync -avz --delete --progress \
        -e "ssh -i $SSH_KEY" \
        .next/static/ \
        $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/.next/static/
    
    # Sync public directory
    log_info "🌐 Syncing public files..."
    rsync -avz --delete --progress \
        -e "ssh -i $SSH_KEY" \
        public/ \
        $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/public/
    
    # Sync essential config files
    log_info "⚙️  Syncing config files..."
    rsync -avz --progress \
        -e "ssh -i $SSH_KEY" \
        package.json Dockerfile \
        $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/
    
    # Sync Prisma client if exists
    if [ -d "node_modules/.prisma" ]; then
        log_info "🗄️  Syncing Prisma client..."
        rsync -avz --progress \
            -e "ssh -i $SSH_KEY" \
            node_modules/.prisma/ \
            $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/node_modules/.prisma/
            
        rsync -avz --progress \
            -e "ssh -i $SSH_KEY" \
            node_modules/@prisma/ \
            $CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/node_modules/@prisma/
    fi
    
    log_success "✅ Sync completed"
}

# Function to build and deploy Docker container on cloud
deploy_docker_cloud() {
    log_info "🐳 Building and deploying Docker container on cloud..."
    
    ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "
        cd $CLOUD_PATH
        
        # Stop and remove existing container
        docker stop $CONTAINER_NAME 2>/dev/null || true
        docker rm $CONTAINER_NAME 2>/dev/null || true
        
        # Build optimized Docker image
        docker build -t $CONTAINER_NAME:latest .
        
        # Run new container with optimized settings
        docker run -d \
            --name $CONTAINER_NAME \
            --restart unless-stopped \
            -p 3000:3000 \
            --memory=512m \
            --memory-swap=512m \
            --cpus='0.5' \
            -e NODE_ENV=production \
            -e NEXT_TELEMETRY_DISABLED=1 \
            $CONTAINER_NAME:latest
        
        # Cleanup old images
        docker image prune -f
    "
    
    log_success "✅ Docker deployment completed"
}

# Function to verify deployment
verify_deployment() {
    log_info "🔍 Verifying deployment..."
    
    # Wait for container to start
    sleep 10
    
    # Check container status
    CONTAINER_STATUS=$(ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "docker ps --filter name=$CONTAINER_NAME --format '{{.Status}}'" || echo "Not running")
    
    if [[ $CONTAINER_STATUS == *"Up"* ]]; then
        log_success "✅ Container is running: $CONTAINER_STATUS"
        
        # Test health endpoint
        if ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "curl -s http://localhost:3000/api/health >/dev/null"; then
            log_success "✅ Health check passed"
        else
            log_warning "⚠️  Health check failed, but container is running"
        fi
        
        # Show container info
        log_info "📊 Container info:"
        ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "docker stats $CONTAINER_NAME --no-stream --format 'CPU: {{.CPUPerc}} | Memory: {{.MemUsage}}'"
        
        log_success "🎉 Deployment successful!"
        echo -e "${BLUE}🌐 Application should be available at: http://$CLOUD_HOST:3000${NC}"
        
    else
        log_error "❌ Container is not running: $CONTAINER_STATUS"
        
        # Show container logs for debugging
        log_info "📋 Container logs:"
        ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "docker logs $CONTAINER_NAME --tail=20" || true
        
        exit 1
    fi
}

# Function to show logs
show_logs() {
    log_info "📋 Showing container logs..."
    ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "docker logs -f $CONTAINER_NAME"
}

# Function to show status
show_status() {
    log_info "📊 Deployment status:"
    ssh -i $SSH_KEY $CLOUD_USER@$CLOUD_HOST "
        echo 'Container status:'
        docker ps --filter name=$CONTAINER_NAME --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' || echo 'Container not found'
        
        echo ''
        echo 'System resources:'
        docker stats $CONTAINER_NAME --no-stream --format 'CPU: {{.CPUPerc}} | Memory: {{.MemUsage}} | Network: {{.NetIO}}' 2>/dev/null || echo 'Container not running'
        
        echo ''
        echo 'Disk usage:'
        df -h $CLOUD_PATH 2>/dev/null || echo 'Path not found'
    "
}

# Main execution
main() {
    case "${1:-deploy}" in
        "build")
            build_standalone_local
            ;;
        "sync")
            sync_to_cloud
            ;;
        "docker")
            deploy_docker_cloud
            ;;
        "verify")
            verify_deployment
            ;;
        "logs")
            show_logs
            ;;
        "status")
            show_status
            ;;
        "deploy"|"full")
            log_info "🚀 Starting full deployment process..."
            build_standalone_local
            sync_to_cloud
            deploy_docker_cloud
            verify_deployment
            ;;
        "help"|"--help")
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  build   - Build standalone locally only"
            echo "  sync    - Sync build to cloud server only"
            echo "  docker  - Build and deploy Docker on cloud only"
            echo "  verify  - Verify deployment only"
            echo "  logs    - Show container logs"
            echo "  status  - Show deployment status"
            echo "  deploy  - Full deployment process (default)"
            echo "  help    - Show this help"
            ;;
        *)
            log_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Execute main function with all arguments
main "$@"
