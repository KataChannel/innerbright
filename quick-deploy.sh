#!/bin/bash

# =============================================================================
# Quick Deploy Wrapper - Innerbright Site
# Automatically finds and runs the deployment script from the correct directory
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
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

# Banner
echo -e "${BLUE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🚀 Innerbright Quick Deploy                             ║
║                   PWA-Optimized Deployment Wrapper                          ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Find the correct directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"

log_info "🔍 Detecting project structure..."
log_info "Script location: $SCRIPT_DIR"
log_info "Looking for site directory: $SITE_DIR"

# Check if we're in the correct project structure
if [ ! -d "$SITE_DIR" ]; then
    log_error "Site directory not found: $SITE_DIR"
    log_error "Please ensure you're running this script from the Innerbright root directory"
    exit 1
fi

# Check if site directory has the required files
if [ ! -f "$SITE_DIR/package.json" ]; then
    log_error "package.json not found in site directory"
    exit 1
fi

if [ ! -f "$SITE_DIR/build-deploy-optimized.sh" ]; then
    log_error "build-deploy-optimized.sh not found in site directory"
    exit 1
fi

# Check which deployment script to use
if [ -f "$SITE_DIR/deploy-pwa-optimized.sh" ]; then
    DEPLOY_SCRIPT="deploy-pwa-optimized.sh"
    log_info "🎯 Using PWA-optimized deployment script"
elif [ -f "$SITE_DIR/build-deploy-optimized.sh" ]; then
    DEPLOY_SCRIPT="build-deploy-optimized.sh"
    log_info "🎯 Using standard deployment script"
else
    log_error "No deployment script found"
    exit 1
fi

# Change to site directory
log_info "📁 Changing to site directory: $SITE_DIR"
cd "$SITE_DIR"

# Make script executable
chmod +x "$DEPLOY_SCRIPT"

# Show available options
log_info "📋 Available deployment options:"
echo "  1) build    - Build locally only"
echo "  2) docker   - Build Docker image only"
echo "  3) deploy   - Deploy to server (requires existing image)"
echo "  4) full     - Complete build and deploy process (default)"
echo "  5) clean    - Clean up temporary files"

# Get user choice or use default
COMMAND="${1:-full}"

if [ -z "$1" ]; then
    echo ""
    echo -e "${YELLOW}Enter deployment option (1-5) or press Enter for full deployment:${NC}"
    read -t 10 -p "Choice: " USER_CHOICE || USER_CHOICE=""
    
    case "$USER_CHOICE" in
        1) COMMAND="build" ;;
        2) COMMAND="docker" ;;
        3) COMMAND="deploy" ;;
        4|"") COMMAND="full" ;;
        5) COMMAND="clean" ;;
        *) 
            log_warning "Invalid choice, using full deployment"
            COMMAND="full"
            ;;
    esac
fi

# Display environment info
log_info "🔧 Environment Information:"
echo "  - Working Directory: $(pwd)"
echo "  - Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
echo "  - Bun: $(bun --version 2>/dev/null || echo 'Not installed')"
echo "  - Docker: $(docker --version 2>/dev/null || echo 'Not installed')"

# Run the deployment script
log_info "🚀 Starting deployment with command: $COMMAND"
echo ""

if ./"$DEPLOY_SCRIPT" "$COMMAND"; then
    log_success "✅ Deployment completed successfully!"
    
    if [ "$COMMAND" = "full" ] || [ "$COMMAND" = "deploy" ]; then
        echo ""
        log_info "🌐 Application should be available at:"
        echo "  - Local: http://localhost:3000"
        echo "  - Server: http://your-server-ip:3000"
        echo ""
        log_info "📊 Quick commands:"
        echo "  - Check status: docker ps | grep innerbright"
        echo "  - View logs: docker logs -f innerbright-site"
        echo "  - Stop: docker stop innerbright-site"
    fi
else
    log_error "❌ Deployment failed!"
    echo ""
    log_info "💡 Troubleshooting tips:"
    echo "  1. Check if you have proper permissions"
    echo "  2. Ensure Docker is running"
    echo "  3. Check available disk space"
    echo "  4. Try cleaning up: ./quick-deploy.sh clean"
    exit 1
fi
