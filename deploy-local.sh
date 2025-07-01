#!/bin/bash

# KataCore Local Deployment Script
# Deploy and test on local machine

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Function to check if Docker is running
check_docker() {
    if ! docker ps >/dev/null 2>&1; then
        error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    success "Docker is running"
}

# Function to setup environment
setup_environment() {
    log "🔧 Setting up local environment..."
    
    # Copy local environment if .env.prod doesn't exist
    if [[ ! -f ".env.prod" ]]; then
        if [[ -f ".env.local" ]]; then
            cp .env.local .env.prod
            success "Copied .env.local to .env.prod for local testing"
        else
            error ".env.local not found. Please run the script again."
            exit 1
        fi
    else
        info ".env.prod already exists, keeping current configuration"
    fi
}

# Function to clean up previous containers
cleanup_containers() {
    log "🧹 Cleaning up previous containers..."
    
    # Stop and remove local containers if they exist
    if docker ps -a --format "table {{.Names}}" | grep -q "katacore.*local"; then
        docker compose -f docker-compose.local.yml down --volumes --remove-orphans 2>/dev/null || true
        success "Cleaned up previous local containers"
    fi
    
    # Clean up unused images (optional)
    docker image prune -f >/dev/null 2>&1 || true
}

# Function to build and deploy
deploy_local() {
    log "🚀 Building and deploying locally..."
    
    # Build and start services
    docker compose -f docker-compose.local.yml up --build -d
    
    success "Local deployment started"
}

# Function to check service health
check_services() {
    log "🔍 Checking service health..."
    
    # Wait for services to be ready
    local max_attempts=30
    local attempt=0
    
    while [[ $attempt -lt $max_attempts ]]; do
        attempt=$((attempt + 1))
        
        # Check if API is responding
        if curl -f -s http://localhost:3001/health >/dev/null 2>&1; then
            success "API service is healthy"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            warning "API service is taking longer than expected to start"
            log "Checking API logs..."
            docker logs katacore-api-local --tail 20
            break
        fi
        
        log "Waiting for API service... (attempt $attempt/$max_attempts)"
        sleep 2
    done
    
    # Check frontend
    attempt=0
    while [[ $attempt -lt $max_attempts ]]; do
        attempt=$((attempt + 1))
        
        if curl -f -s http://localhost:3000 >/dev/null 2>&1; then
            success "Frontend service is healthy"
            break
        fi
        
        if [[ $attempt -eq $max_attempts ]]; then
            warning "Frontend service is taking longer than expected to start"
            log "Checking Frontend logs..."
            docker logs katacore-site-local --tail 20
            break
        fi
        
        log "Waiting for Frontend service... (attempt $attempt/$max_attempts)"
        sleep 2
    done
}

# Function to show access information
show_access_info() {
    echo ""
    success "🎉 Local deployment completed!"
    echo ""
    info "🌐 Access your application:"
    echo "   Frontend:    http://localhost:3000"
    echo "   API:         http://localhost:3001"
    echo "   API Health:  http://localhost:3001/health"
    echo "   PgAdmin:     http://localhost:8080"
    echo "   MinIO Console: http://localhost:9001"
    echo ""
    info "📊 Database connections:"
    echo "   PostgreSQL:  localhost:5432"
    echo "   Redis:       localhost:6379"
    echo "   MinIO:       localhost:9000"
    echo ""
    info "🔑 Default credentials (from .env.local):"
    echo "   PgAdmin:     admin@localhost.com / local_pgladmin_pass_123"
    echo "   MinIO:       katacore_minio_admin / local_minio_pass_123"
    echo ""
    info "📝 Useful commands:"
    echo "   View logs:   docker compose -f docker-compose.local.yml logs -f [service]"
    echo "   Stop all:    docker compose -f docker-compose.local.yml down"
    echo "   Restart:     docker compose -f docker-compose.local.yml restart [service]"
    echo ""
}

# Function to show logs
show_logs() {
    log "📋 Showing recent logs..."
    echo ""
    info "API Logs:"
    docker logs katacore-api-local --tail 10
    echo ""
    info "Frontend Logs:"
    docker logs katacore-site-local --tail 10
    echo ""
}

# Main function
main() {
    log "🚀 KataCore Local Deployment Starting..."
    
    # Parse arguments
    CLEAN_DEPLOY=false
    SHOW_LOGS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --clean)
                CLEAN_DEPLOY=true
                shift
                ;;
            --logs)
                SHOW_LOGS=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--clean] [--logs]"
                echo "  --clean   Clean deployment (remove all containers and volumes)"
                echo "  --logs    Show service logs after deployment"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    # Check prerequisites
    check_docker
    setup_environment
    
    if [[ "$CLEAN_DEPLOY" == "true" ]]; then
        cleanup_containers
    fi
    
    # Deploy
    deploy_local
    check_services
    show_access_info
    
    if [[ "$SHOW_LOGS" == "true" ]]; then
        show_logs
    fi
    
    success "Local deployment completed successfully! 🎉"
}

# Run main function
main "$@"
