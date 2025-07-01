#!/bin/bash

# KataCore Local Test Deployment Script
# Optimized for quick local testing and development

set -e

# Colors for better UX
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging functions
log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
debug() { echo -e "${PURPLE}🔍 $1${NC}"; }

# Banner
show_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    KataCore Local Deploy                     ║"
    echo "║                  Quick Test & Development                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --clean         Clean deploy (remove all containers and volumes)"
    echo "  --build-only    Only build images without starting services"
    echo "  --logs          Show logs after deployment"
    echo "  --no-logs       Don't show logs after deployment"
    echo "  --rebuild       Force rebuild all images"
    echo "  --quick         Quick deploy (skip some checks)"
    echo "  --dev           Development mode with hot reload"
    echo "  --prod          Production-like mode locally"
    echo "  --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Normal local deploy"
    echo "  $0 --clean --logs     # Clean deploy with logs"
    echo "  $0 --dev              # Development mode"
    echo "  $0 --rebuild          # Force rebuild everything"
}

# Default values
CLEAN_DEPLOY=false
BUILD_ONLY=false
SHOW_LOGS=true
FORCE_REBUILD=false
QUICK_MODE=false
DEV_MODE=false
PROD_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN_DEPLOY=true
            shift
            ;;
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --logs)
            SHOW_LOGS=true
            shift
            ;;
        --no-logs)
            SHOW_LOGS=false
            shift
            ;;
        --rebuild)
            FORCE_REBUILD=true
            shift
            ;;
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --dev)
            DEV_MODE=true
            shift
            ;;
        --prod)
            PROD_MODE=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            error "Unknown option: $1. Use --help for usage information."
            ;;
    esac
done

# Environment setup
setup_environment() {
    log "🔧 Setting up local environment..."
    
    # Create .env.local if it doesn't exist
    if [[ ! -f ".env.local" ]]; then
        if [[ -f ".env.local.example" ]]; then
            cp .env.local.example .env.local
            success "Created .env.local from example"
        else
            error ".env.local.example not found"
        fi
    else
        debug ".env.local already exists"
    fi
    
    # Validate required environment variables
    source .env.local
    
    local required_vars=("POSTGRES_PASSWORD" "REDIS_PASSWORD" "JWT_SECRET")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            error "Required environment variable $var is not set in .env.local"
        fi
    done
    
    success "Environment validated"
}

# Check prerequisites
check_prerequisites() {
    if [[ "$QUICK_MODE" == "true" ]]; then
        debug "Skipping prerequisite checks (quick mode)"
        return
    fi
    
    log "🔍 Checking prerequisites..."
    
    # Check if Docker is installed and running
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker first."
    fi
    
    if ! docker ps >/dev/null 2>&1; then
        error "Docker is not running. Please start Docker first."
    fi
    
    # Check if Docker Compose is available
    if ! docker compose version >/dev/null 2>&1; then
        if ! docker-compose --version >/dev/null 2>&1; then
            error "Docker Compose is not available."
        else
            warning "Using legacy docker-compose command"
        fi
    fi
    
    # Check available disk space
    available_space=$(df . | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 2097152 ]]; then # 2GB in KB
        warning "Low disk space: $(($available_space/1024/1024))GB available"
    fi
    
    success "Prerequisites checked"
}

# Clean up function
cleanup_containers() {
    if [[ "$CLEAN_DEPLOY" == "true" ]]; then
        log "🧹 Cleaning up previous deployment..."
        
        # Stop and remove containers
        docker compose -f docker-compose.local.yml down -v --remove-orphans 2>/dev/null || true
        
        # Remove images if force rebuild
        if [[ "$FORCE_REBUILD" == "true" ]]; then
            debug "Removing local images..."
            docker images --format "table {{.Repository}}:{{.Tag}}" | grep "katacore" | xargs -r docker rmi -f 2>/dev/null || true
        fi
        
        # Clean up unused resources
        docker system prune -f >/dev/null 2>&1 || true
        
        success "Cleanup completed"
    else
        debug "Skipping cleanup"
    fi
}

# Build and deploy
build_and_deploy() {
    log "🚀 Building and deploying services..."
    
    local compose_args=""
    
    # Add build args based on mode
    if [[ "$FORCE_REBUILD" == "true" ]]; then
        compose_args="$compose_args --build --force-recreate"
    elif [[ "$DEV_MODE" == "true" ]]; then
        compose_args="$compose_args --build"
    fi
    
    # Choose compose file based on mode
    local compose_file="docker-compose.local.yml"
    if [[ "$PROD_MODE" == "true" ]]; then
        compose_file="docker-compose.yml"
        warning "Using production compose file locally"
    fi
    
    # Build only mode
    if [[ "$BUILD_ONLY" == "true" ]]; then
        docker compose -f "$compose_file" build
        success "Build completed (build-only mode)"
        return
    fi
    
    # Deploy services
    docker compose -f "$compose_file" up -d $compose_args
    
    success "Services deployed"
}

# Health checks
check_services_health() {
    if [[ "$QUICK_MODE" == "true" ]]; then
        debug "Skipping health checks (quick mode)"
        return
    fi
    
    log "🔍 Checking service health..."
    
    local max_attempts=30
    local attempt=0
    
    # Check API health
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -s http://localhost:3001/health >/dev/null 2>&1; then
            success "API is healthy"
            break
        fi
        ((attempt++))
        if [[ $attempt -eq $max_attempts ]]; then
            warning "API health check timeout"
            break
        fi
        sleep 2
    done
    
    # Check Frontend
    attempt=0
    while [[ $attempt -lt $max_attempts ]]; do
        if curl -s http://localhost:3000 >/dev/null 2>&1; then
            success "Frontend is healthy"
            break
        fi
        ((attempt++))
        if [[ $attempt -eq $max_attempts ]]; then
            warning "Frontend health check timeout"
            break
        fi
        sleep 2
    done
    
    # Check Database
    if docker exec katacore-postgres-local pg_isready -U katacore_user >/dev/null 2>&1; then
        success "PostgreSQL is healthy"
    else
        warning "PostgreSQL health check failed"
    fi
    
    # Check Redis
    if docker exec katacore-redis-local redis-cli -a local_redis_pass_123 ping 2>/dev/null | grep -q "PONG"; then
        success "Redis is healthy"
    else
        warning "Redis health check failed"
    fi
}

# Show access information
show_access_info() {
    echo ""
    success "🎉 Local deployment completed!"
    echo ""
    info "🌐 Access URLs:"
    echo "   Frontend:     http://localhost:3000"
    echo "   API:          http://localhost:3001"
    echo "   API Health:   http://localhost:3001/health"
    echo "   PgAdmin:      http://localhost:8080"
    echo "   MinIO Console: http://localhost:9001"
    echo ""
    info "📊 Direct Database Access:"
    echo "   PostgreSQL:   localhost:5432"
    echo "   Redis:        localhost:6379"
    echo "   MinIO S3:     localhost:9000"
    echo ""
    info "🔑 Default Credentials:"
    echo "   PgAdmin:      admin@localhost.com / local_pgladmin_pass_123"
    echo "   MinIO:        katacore_minio_admin / local_minio_pass_123"
    echo ""
    info "🛠️  Useful Commands:"
    echo "   View logs:    docker compose -f docker-compose.local.yml logs -f [service]"
    echo "   Stop all:     docker compose -f docker-compose.local.yml down"
    echo "   Restart:      docker compose -f docker-compose.local.yml restart [service]"
    echo "   Clean deploy: $0 --clean"
    echo ""
    
    if [[ "$DEV_MODE" == "true" ]]; then
        info "🔥 Development Mode Active - Hot reload enabled"
    fi
}

# Show logs function
show_logs_if_requested() {
    if [[ "$SHOW_LOGS" == "true" && "$BUILD_ONLY" == "false" ]]; then
        echo ""
        info "📋 Recent service logs:"
        echo ""
        
        echo -e "${CYAN}=== API Logs ===${NC}"
        docker logs katacore-api-local --tail 10 2>/dev/null || echo "API logs not available"
        
        echo ""
        echo -e "${CYAN}=== Frontend Logs ===${NC}"
        docker logs katacore-site-local --tail 10 2>/dev/null || echo "Frontend logs not available"
        
        echo ""
        info "📝 For real-time logs: docker compose -f docker-compose.local.yml logs -f"
    fi
}

# Performance monitoring
show_resource_usage() {
    if [[ "$QUICK_MODE" == "false" ]]; then
        echo ""
        info "💻 Resource Usage:"
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
            katacore-api-local katacore-site-local katacore-postgres-local katacore-redis-local 2>/dev/null || true
    fi
}

# Error handling
trap 'error "Deployment failed at line $LINENO"' ERR

# Main execution
main() {
    show_banner
    
    # Setup
    setup_environment
    check_prerequisites
    cleanup_containers
    
    # Deploy
    build_and_deploy
    
    # Post-deploy checks
    if [[ "$BUILD_ONLY" == "false" ]]; then
        check_services_health
        show_access_info
        show_resource_usage
        show_logs_if_requested
    fi
    
    # Final message
    if [[ "$BUILD_ONLY" == "true" ]]; then
        success "🏗️  Build process completed successfully!"
    else
        success "🚀 KataCore is now running locally!"
        info "💡 Pro tip: Use '$0 --clean' for a fresh deployment"
    fi
}

# Execute main function
main "$@"
