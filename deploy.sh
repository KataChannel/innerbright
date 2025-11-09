#!/bin/bash

# ==============================================================================
# InnerBright Deployment - Main Script
# Wrapper for different deployment modes
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Functions
print_header() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Main menu
show_menu() {
    clear
    print_header "InnerBright Deployment Tool"
    echo ""
    echo "Choose deployment mode:"
    echo ""
    echo "  1) 🚀 Deploy to Remote Server (95copy.sh)"
    echo "     - Deploy with build: Build + Upload + Restart Docker"
    echo "     - Deploy only: Upload existing build"
    echo ""
    echo "  2) 🐳 Deploy Local Docker (docker-compose)"
    echo "     - Run application locally on port 14000"
    echo ""
    echo "  3) ✅ Verify Build"
    echo "     - Check if build output exists"
    echo ""
    echo "  4) 🔧 Fix Mode (Critical Files Only)"
    echo "     - Quick fix for production issues"
    echo ""
    echo "  0) Exit"
    echo ""
    echo -n "Enter choice [0-4]: "
}

# Deploy to remote server
deploy_remote() {
    print_header "Deploy to Remote Server"
    echo ""
    echo "Options:"
    echo "  1) Deploy with build (recommended)"
    echo "  2) Deploy only (no build)"
    echo "  3) Back to menu"
    echo ""
    echo -n "Enter choice [1-3]: "
    read remote_choice
    
    case $remote_choice in
        1)
            print_info "Starting deployment with build..."
            ./scripts/95copy.sh --build
            ;;
        2)
            print_info "Starting deployment without build..."
            ./scripts/95copy.sh
            ;;
        3)
            return
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
    
    echo ""
    echo "Press Enter to continue..."
    read
}

# Deploy local docker
deploy_local() {
    print_header "Deploy Local Docker"
    
    print_info "Building Docker image..."
    docker-compose build innerbright-web
    
    print_info "Starting containers..."
    docker-compose up -d innerbright-web
    
    sleep 5
    
    print_info "Checking container status..."
    docker-compose ps innerbright-web
    
    echo ""
    print_success "✅ Local deployment complete!"
    print_info "Application URL: http://localhost:14000"
    echo ""
    echo "Useful commands:"
    echo "  - View logs: docker-compose logs -f innerbright-web"
    echo "  - Stop: docker-compose stop innerbright-web"
    echo "  - Restart: docker-compose restart innerbright-web"
    
    echo ""
    echo "Press Enter to continue..."
    read
}

# Verify build
verify_build() {
    print_header "Verify Build Output"
    ./scripts/95copy.sh --verify
    echo ""
    echo "Press Enter to continue..."
    read
}

# Fix mode
fix_mode() {
    print_header "Fix Mode - Critical Files Only"
    echo ""
    print_info "This will deploy only critical frontend files"
    echo -n "Continue? (y/n): "
    read confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        ./scripts/95copy.sh --fix
    else
        print_info "Cancelled"
    fi
    
    echo ""
    echo "Press Enter to continue..."
    read
}

# Main loop
main() {
    while true; do
        show_menu
        read choice
        
        case $choice in
            1)
                deploy_remote
                ;;
            2)
                deploy_local
                ;;
            3)
                verify_build
                ;;
            4)
                fix_mode
                ;;
            0)
                print_success "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                sleep 2
                ;;
        esac
    done
}

# Check if scripts exist
if [[ ! -f "./scripts/95copy.sh" ]]; then
    print_error "scripts/95copy.sh not found!"
    exit 1
fi

# Run main
main
