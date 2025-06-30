#!/bin/bash

# KataCore Docker Management Script
# This script provides a unified interface for all Docker operations

set -e

# Setup Bun PATH
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bun-setup.sh"

if ! setup_bun_for_session; then
    exit 1
fi

PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Check and install Docker if needed
ensure_docker() {
    log "🔍 Checking Docker installation..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        warning "Docker not found. Installing automatically..."
        if "$SCRIPT_DIR/install-docker.sh" install; then
            success "Docker installed successfully"
        else
            error "Failed to install Docker"
        fi
    fi
    
    # Check if Docker Compose is available
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null 2>&1; then
        warning "Docker Compose not found. Installing..."
        if "$SCRIPT_DIR/install-docker.sh" install; then
            success "Docker Compose installed successfully"
        else
            error "Failed to install Docker Compose"
        fi
    fi
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        log "🔄 Docker is not running. Attempting to start..."
        
        if command -v systemctl &> /dev/null; then
            sudo systemctl start docker 2>/dev/null || warning "Could not start Docker with systemctl"
        elif command -v service &> /dev/null; then
            sudo service docker start 2>/dev/null || warning "Could not start Docker with service"
        else
            warning "Could not determine how to start Docker service"
        fi
        
        # Wait and check again
        sleep 3
        if ! docker info > /dev/null 2>&1; then
            error "Docker is not running and could not be started. Please start Docker manually."
        fi
        success "Docker started successfully"
    fi
    
    success "Docker is ready!"
}

# Show Docker status
show_status() {
    cd "$PROJECT_DIR"
    
    log "🐳 Docker System Status:"
    echo ""
    
    # Docker version
    if command -v docker &> /dev/null; then
        echo "Docker: $(docker --version)"
    else
        echo "Docker: ❌ Not installed"
    fi
    
    # Docker Compose version
    if command -v docker-compose &> /dev/null; then
        echo "Docker Compose: $(docker-compose --version)"
    elif docker compose version &> /dev/null 2>&1; then
        echo "Docker Compose: $(docker compose version --short)"
    else
        echo "Docker Compose: ❌ Not installed"
    fi
    
    echo ""
    
    # Docker daemon status
    if docker info > /dev/null 2>&1; then
        echo "Docker Daemon: ✅ Running"
        echo ""
        
        # System info
        echo "📊 System Information:"
        docker system df
        echo ""
        
        # Running containers
        echo "📦 Running Containers:"
        if [ "$(docker ps -q | wc -l)" -gt 0 ]; then
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        else
            echo "No containers running"
        fi
        echo ""
        
        # KataCore services status
        echo "🎯 KataCore Services Status:"
        if [ -f "docker-compose.yml" ]; then
            docker-compose ps 2>/dev/null || echo "Development services not running"
        fi
        
        if [ -f "docker-compose.prod.yml" ]; then
            echo ""
            echo "Production services:"
            docker-compose -f docker-compose.prod.yml ps 2>/dev/null || echo "Production services not running"
        fi
    else
        echo "Docker Daemon: ❌ Not running"
    fi
}

# Clean up Docker resources
cleanup_docker() {
    log "🧹 Cleaning up Docker resources..."
    
    ensure_docker
    
    cd "$PROJECT_DIR"
    
    # Stop all KataCore containers
    log "Stopping KataCore containers..."
    docker-compose down --remove-orphans 2>/dev/null || true
    docker-compose -f docker-compose.dev.yml down --remove-orphans 2>/dev/null || true
    docker-compose -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true
    
    # Remove unused Docker resources
    log "Removing unused Docker resources..."
    docker system prune -f
    
    # Optionally remove unused images
    read -p "Remove unused images? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker image prune -a -f
    fi
    
    # Optionally remove unused volumes
    read -p "Remove unused volumes? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker volume prune -f
    fi
    
    success "Docker cleanup completed"
}

# Reset Docker completely
reset_docker() {
    log "🔄 Resetting Docker completely..."
    
    read -p "This will remove ALL Docker containers, images, and volumes. Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Reset cancelled"
        exit 0
    fi
    
    ensure_docker
    
    cd "$PROJECT_DIR"
    
    # Stop all containers
    log "Stopping all containers..."
    docker stop $(docker ps -aq) 2>/dev/null || true
    
    # Remove all containers
    log "Removing all containers..."
    docker rm $(docker ps -aq) 2>/dev/null || true
    
    # Remove all images
    log "Removing all images..."
    docker rmi $(docker images -q) 2>/dev/null || true
    
    # Remove all volumes
    log "Removing all volumes..."
    docker volume rm $(docker volume ls -q) 2>/dev/null || true
    
    # Remove all networks
    log "Removing custom networks..."
    docker network rm $(docker network ls -q --filter type=custom) 2>/dev/null || true
    
    # Clean system
    docker system prune -a -f --volumes
    
    success "Docker reset completed"
}

# Fix Docker permissions
fix_permissions() {
    log "🔧 Fixing Docker permissions..."
    
    if [ "$EUID" -eq 0 ]; then
        warning "Running as root, no permission fixes needed"
        return 0
    fi
    
    current_user=$(whoami)
    
    # Add user to docker group
    if groups "$current_user" | grep -q "\bdocker\b"; then
        success "User $current_user is already in docker group"
    else
        log "Adding user $current_user to docker group..."
        sudo usermod -aG docker "$current_user"
        success "User added to docker group"
        warning "Please log out and log back in for changes to take effect"
    fi
    
    # Check if docker socket has correct permissions
    if [ -S /var/run/docker.sock ]; then
        log "Checking Docker socket permissions..."
        sudo chmod 666 /var/run/docker.sock 2>/dev/null || warning "Could not modify socket permissions"
        success "Docker socket permissions checked"
    fi
}

# Development environment management
dev_environment() {
    local action=${1:-"up"}
    
    ensure_docker
    cd "$PROJECT_DIR"
    
    case "$action" in
        "up"|"start")
            log "🚀 Starting development environment..."
            docker-compose -f docker-compose.dev.yml up -d
            ;;
        "down"|"stop")
            log "🛑 Stopping development environment..."
            docker-compose -f docker-compose.dev.yml down
            ;;
        "restart")
            log "🔄 Restarting development environment..."
            docker-compose -f docker-compose.dev.yml restart
            ;;
        "logs")
            log "📋 Showing development environment logs..."
            docker-compose -f docker-compose.dev.yml logs -f
            ;;
        "build")
            log "🔨 Building development environment..."
            docker-compose -f docker-compose.dev.yml build --no-cache
            ;;
        *)
            error "Unknown development action: $action"
            ;;
    esac
}

# Production environment management
prod_environment() {
    local action=${1:-"up"}
    
    ensure_docker
    cd "$PROJECT_DIR"
    
    case "$action" in
        "up"|"start")
            log "🚀 Starting production environment..."
            docker-compose -f docker-compose.prod.yml up -d
            ;;
        "down"|"stop")
            log "🛑 Stopping production environment..."
            docker-compose -f docker-compose.prod.yml down
            ;;
        "restart")
            log "🔄 Restarting production environment..."
            docker-compose -f docker-compose.prod.yml restart
            ;;
        "logs")
            log "📋 Showing production environment logs..."
            docker-compose -f docker-compose.prod.yml logs -f
            ;;
        "build")
            log "🔨 Building production environment..."
            docker-compose -f docker-compose.prod.yml build --no-cache
            ;;
        *)
            error "Unknown production action: $action"
            ;;
    esac
}

# Show usage information
show_usage() {
    echo "KataCore Docker Management Script"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  install               Install Docker and Docker Compose"
    echo "  check                 Check Docker installation and status"
    echo "  status                Show detailed Docker status"
    echo "  ensure                Ensure Docker is installed and running"
    echo "  start                 Start Docker service"
    echo "  stop                  Stop Docker service"
    echo "  restart               Restart Docker service"
    echo "  cleanup               Clean up unused Docker resources"
    echo "  reset                 Reset Docker completely (removes everything)"
    echo "  fix-permissions       Fix Docker permissions for current user"
    echo ""
    echo "Environment Management:"
    echo "  dev [up|down|restart|logs|build]    Manage development environment"
    echo "  prod [up|down|restart|logs|build]   Manage production environment"
    echo ""
    echo "Examples:"
    echo "  $0 install           # Install Docker if not present"
    echo "  $0 status            # Show Docker status"
    echo "  $0 dev up           # Start development environment"
    echo "  $0 prod logs         # Show production logs"
    echo "  $0 cleanup           # Clean unused resources"
}

# Main command handler
case "${1:-status}" in
    "install")
        "$SCRIPT_DIR/install-docker.sh" install
        ;;
    "check")
        "$SCRIPT_DIR/install-docker.sh" check
        ;;
    "status")
        show_status
        ;;
    "ensure")
        ensure_docker
        ;;
    "start")
        sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null || error "Could not start Docker"
        success "Docker service started"
        ;;
    "stop")
        sudo systemctl stop docker 2>/dev/null || sudo service docker stop 2>/dev/null || error "Could not stop Docker"
        success "Docker service stopped"
        ;;
    "restart")
        sudo systemctl restart docker 2>/dev/null || sudo service docker restart 2>/dev/null || error "Could not restart Docker"
        success "Docker service restarted"
        ;;
    "cleanup")
        cleanup_docker
        ;;
    "reset")
        reset_docker
        ;;
    "fix-permissions")
        fix_permissions
        ;;
    "dev")
        dev_environment "$2"
        ;;
    "prod")
        prod_environment "$2"
        ;;
    "help"|"--help"|"-h")
        show_usage
        ;;
    *)
        echo "Unknown command: $1"
        echo ""
        show_usage
        exit 1
        ;;
esac
