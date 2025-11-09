#!/bin/bash

# Cleanup and Reset Script for rausachcore
# Safely removes all containers, volumes, and data

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if docker-compose is available
check_compose() {
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    elif docker compose version &> /dev/null; then
        COMPOSE_CMD="docker compose"
    else
        print_error "Docker Compose is not available"
        exit 1
    fi
}

# Stop all services
stop_all_services() {
    print_step "Stopping all rausachcore services..."
    
    # Stop main services
    if [ -f "docker-compose.yml" ]; then
        $COMPOSE_CMD down
    fi
    
    # Stop monitoring services
    if [ -f "docker-compose.monitoring.yml" ]; then
        $COMPOSE_CMD -f docker-compose.yml -f docker-compose.monitoring.yml down
    fi
    
    # Stop Redis cluster
    if [ -f "docker-compose.redis-cluster.yml" ]; then
        $COMPOSE_CMD -f docker-compose.redis-cluster.yml down
    fi
    
    # Stop production services
    if [ -f "docker-compose.prod.yml" ]; then
        $COMPOSE_CMD -f docker-compose.yml -f docker-compose.prod.yml down
    fi
    
    print_success "All services stopped"
}

# Remove containers
remove_containers() {
    print_step "Removing rausachcore containers..."
    
    # Remove containers by name pattern
    containers=$(docker ps -a --filter "name=rausachcore" --filter "name=redis-cluster" --filter "name=prometheus" --filter "name=grafana" --format "{{.Names}}" 2>/dev/null || true)
    
    if [ -n "$containers" ]; then
        echo "$containers" | xargs docker rm -f
        print_success "Containers removed"
    else
        print_warning "No rausachcore containers found"
    fi
}

# Remove volumes
remove_volumes() {
    print_warning "This will permanently delete all data!"
    read -p "Are you sure you want to remove all volumes? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Removing volumes..."
        
        # Remove named volumes
        volumes=$(docker volume ls --filter "name=rausachcore" --filter "name=redis-cluster" --filter "name=prometheus" --filter "name=grafana" --format "{{.Name}}" 2>/dev/null || true)
        
        if [ -n "$volumes" ]; then
            echo "$volumes" | xargs docker volume rm -f
            print_success "Volumes removed"
        else
            print_warning "No rausachcore volumes found"
        fi
    else
        print_step "Volume removal cancelled"
    fi
}

# Remove networks
remove_networks() {
    print_step "Removing networks..."
    
    networks=("rausachcore-network" "rausachcore-prod")
    
    for network in "${networks[@]}"; do
        if docker network ls | grep -q "$network"; then
            docker network rm "$network" 2>/dev/null || print_warning "Could not remove network: $network"
        fi
    done
    
    print_success "Networks cleaned up"
}

# Remove images
remove_images() {
    read -p "Remove built images? This will require rebuilding. (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Removing images..."
        
        # Remove rausachcore images
        images=$(docker images --filter "reference=rausachcore*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
        
        if [ -n "$images" ]; then
            echo "$images" | xargs docker rmi -f
            print_success "Images removed"
        else
            print_warning "No rausachcore images found"
        fi
    else
        print_step "Image removal cancelled"
    fi
}

# Clean up generated files
cleanup_files() {
    read -p "Remove generated files (.env, certs, logs)? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Cleaning up generated files..."
        
        # Remove environment files
        rm -f .env .env.production
        
        # Remove certificates
        rm -rf docker/minio/certs/
        
        # Remove logs
        rm -rf logs/
        
        # Remove backups
        rm -rf backups/
        
        print_success "Generated files cleaned up"
    else
        print_step "File cleanup cancelled"
    fi
}

# Full reset
full_reset() {
    print_warning "FULL RESET: This will remove everything!"
    print_warning "- All containers will be stopped and removed"
    print_warning "- All volumes and data will be deleted"
    print_warning "- All networks will be removed"
    print_warning "- All generated files will be deleted"
    echo
    read -p "Are you absolutely sure? Type 'yes' to confirm: " -r
    
    if [[ $REPLY == "yes" ]]; then
        stop_all_services
        remove_containers
        
        # Force remove volumes
        REPLY="y"
        remove_volumes
        
        remove_networks
        
        # Force remove images
        REPLY="y"
        remove_images
        
        # Force cleanup files
        REPLY="y"
        cleanup_files
        
        print_success "Full reset complete!"
        print_step "You can now run './scripts/deploy-phase5.sh' to start fresh"
    else
        print_step "Full reset cancelled"
    fi
}

# Show current status
show_status() {
    print_step "Current rausachcore status..."
    
    echo ""
    echo "🐳 Containers:"
    containers=$(docker ps -a --filter "name=rausachcore" --filter "name=redis-cluster" --filter "name=prometheus" --filter "name=grafana" --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || true)
    if [ -n "$containers" ]; then
        echo "$containers"
    else
        echo "  No rausachcore containers found"
    fi
    
    echo ""
    echo "📦 Volumes:"
    volumes=$(docker volume ls --filter "name=rausachcore" --filter "name=redis-cluster" --filter "name=prometheus" --filter "name=grafana" --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null || true)
    if [ -n "$volumes" ]; then
        echo "$volumes"
    else
        echo "  No rausachcore volumes found"
    fi
    
    echo ""
    echo "🌐 Networks:"
    networks=$(docker network ls --filter "name=rausachcore" --format "table {{.Name}}\t{{.Driver}}" 2>/dev/null || true)
    if [ -n "$networks" ]; then
        echo "$networks"
    else
        echo "  No rausachcore networks found"
    fi
    
    echo ""
    echo "🖼️  Images:"
    images=$(docker images --filter "reference=rausachcore*" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || true)
    if [ -n "$images" ]; then
        echo "$images"
    else
        echo "  No rausachcore images found"
    fi
}

# Show help
show_help() {
    echo "rausachcore Cleanup and Reset Script"
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  stop        - Stop all running services"
    echo "  containers  - Remove all containers"
    echo "  volumes     - Remove all volumes (with confirmation)"
    echo "  networks    - Remove all networks"
    echo "  images      - Remove all built images (with confirmation)"
    echo "  files       - Clean up generated files (with confirmation)"
    echo "  full        - Full reset (removes everything)"
    echo "  status      - Show current status"
    echo "  help        - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 stop      # Stop services but keep data"
    echo "  $0 status    # Check what's currently running"
    echo "  $0 full      # Complete reset (destructive)"
    echo
    echo "⚠️  WARNING: Some operations are destructive and cannot be undone!"
}

# Main execution
main() {
    check_compose
    
    case ${1:-""} in
        "stop")
            stop_all_services
            ;;
        "containers")
            stop_all_services
            remove_containers
            ;;
        "volumes")
            remove_volumes
            ;;
        "networks")
            remove_networks
            ;;
        "images")
            remove_images
            ;;
        "files")
            cleanup_files
            ;;
        "full")
            full_reset
            ;;
        "status")
            show_status
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Handle cleanup on exit
cleanup() {
    echo ""
    print_warning "Cleanup interrupted"
    exit 1
}

trap cleanup INT TERM

# Run main function
main $@
