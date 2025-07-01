#!/bin/bash

# 🚀 KataCore StartKit v1 - Quick Start Script
# This script helps you get started with KataCore StartKit v1 quickly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
}

# Banner
echo -e "${PURPLE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║    🚀 KataCore StartKit v1.0.0 - Quick Start            ║
║                                                           ║
║    Production-ready full-stack application               ║
║    Deploy to any cloud server in minutes!                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check prerequisites
check_prerequisites() {
    info "Checking prerequisites..."
    
    # Check Bun
    if ! command -v bun &> /dev/null; then
        error "Bun.js is not installed. Please install it from https://bun.sh"
        exit 1
    fi
    success "Bun.js $(bun --version) is installed ✓"
    
    # Check Git
    if ! command -v git &> /dev/null; then
        error "Git is not installed. Please install Git first."
        exit 1
    fi
    success "Git is installed ✓"
    
    # Check Docker (optional for local dev)
    if command -v docker &> /dev/null; then
        success "Docker is installed ✓"
    else
        warning "Docker not found (optional for local development)"
    fi
}

# Install dependencies
install_dependencies() {
    info "Installing dependencies..."
    
    if [ ! -f "package.json" ]; then
        error "package.json not found. Are you in the KataCore directory?"
        exit 1
    fi
    
    bun run install:all
    success "Dependencies installed successfully!"
}

# Show menu
show_menu() {
    echo -e "\n${BLUE}What would you like to do?${NC}\n"
    echo "1. 🔧 Start local development"
    echo "2. 🚀 Deploy to production server"
    echo "3. 📖 View documentation"
    echo "4. 🧪 Run tests"
    echo "5. 📝 Create environment template"
    echo "6. ❌ Exit"
    echo
}

# Start development
start_development() {
    info "Starting local development environment..."
    echo
    info "This will start:"
    echo "  • Frontend: http://localhost:3000"
    echo "  • Backend:  http://localhost:3001"
    echo "  • Database and cache services"
    echo
    warning "Press Ctrl+C to stop all services"
    echo
    
    bun run dev
}

# Deploy to production
deploy_production() {
    echo
    info "Production deployment with StartKit v1"
    echo
    read -p "Enter your server IP address: " server_ip
    
    if [ -z "$server_ip" ]; then
        error "Server IP is required"
        return
    fi
    
    echo
    read -p "Enter your domain (optional, press Enter to skip): " domain
    
    echo
    info "Deploying to server: $server_ip"
    if [ ! -z "$domain" ]; then
        info "Domain: $domain"
        bun run deploy:startkit "$server_ip" --domain "$domain"
    else
        bun run deploy:startkit "$server_ip"
    fi
}

# View documentation
view_docs() {
    echo
    info "Opening documentation..."
    echo
    echo "📚 Available documentation:"
    echo "  • README.md - Main documentation"
    echo "  • README.startkit.md - StartKit v1 specific guide"
    echo "  • docs/GETTING_STARTED.md - Step-by-step guide"
    echo "  • docs/CUSTOMIZATION.md - Customization guide"
    echo "  • CHANGELOG.md - Release notes"
    echo
    
    if command -v xdg-open &> /dev/null; then
        xdg-open README.md
    elif command -v open &> /dev/null; then
        open README.md
    else
        info "Please open README.md in your preferred text editor"
    fi
}

# Run tests
run_tests() {
    info "Running tests..."
    echo
    bun run test
    success "Tests completed!"
}

# Create environment template
create_env_template() {
    info "Creating environment template..."
    echo
    bun run env:create-template
    success "Environment template created!"
    echo
    info "Edit .env.prod with your actual values before deployment"
}

# Main function
main() {
    check_prerequisites
    
    # Install dependencies if not already installed
    if [ ! -d "node_modules" ] || [ ! -d "site/node_modules" ] || [ ! -d "api/node_modules" ]; then
        install_dependencies
    fi
    
    while true; do
        show_menu
        read -p "Choose an option (1-6): " choice
        
        case $choice in
            1)
                start_development
                ;;
            2)
                deploy_production
                ;;
            3)
                view_docs
                ;;
            4)
                run_tests
                ;;
            5)
                create_env_template
                ;;
            6)
                echo
                success "Thank you for using KataCore StartKit v1! 🚀"
                exit 0
                ;;
            *)
                error "Invalid option. Please choose 1-6."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
