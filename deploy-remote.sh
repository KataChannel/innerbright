#!/bin/bash

# ==============================================================================
# INNERBRIGHT DEPLOY SCRIPT
# Deploy Next.js build to remote server
# Usage: ./deploy-remote.sh [--build]
# ==============================================================================

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SERVER_IP="116.118.48.208"
SERVER_USER="root"
REMOTE_DIR="/root/innerbright"
LOCAL_DIR="$(pwd)"

# Parse arguments
BUILD_FRONTEND=false
if [[ "$1" == "--build" ]]; then
    BUILD_FRONTEND=true
fi

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function: Build frontend
build_frontend() {
    log_info "═══════════════════════════════════════════════════════"
    log_info "Building Next.js application..."
    log_info "═══════════════════════════════════════════════════════"
    
    if command -v bun &> /dev/null; then
        log_info "Using Bun to build..."
        bun run build
    elif command -v npm &> /dev/null; then
        log_info "Using npm to build..."
        npm run build
    else
        log_error "Neither bun nor npm found. Please install one of them."
        exit 1
    fi
    
    log_success "✅ Build completed!"
}

# Function: Verify build output
verify_build() {
    log_info "Verifying build output..."
    
    local has_error=false
    
    # Check .next/standalone
    if [[ ! -d "$LOCAL_DIR/.next/standalone" ]]; then
        log_error "❌ Missing: $LOCAL_DIR/.next/standalone"
        has_error=true
    else
        log_success "✅ Found: .next/standalone"
        log_info "  Files: $(find $LOCAL_DIR/.next/standalone -type f | wc -l) files"
    fi
    
    # Check .next/static
    if [[ ! -d "$LOCAL_DIR/.next/static" ]]; then
        log_error "❌ Missing: $LOCAL_DIR/.next/static"
        has_error=true
    else
        log_success "✅ Found: .next/static"
        local css_count=$(find $LOCAL_DIR/.next/static -name "*.css" 2>/dev/null | wc -l)
        local js_count=$(find $LOCAL_DIR/.next/static -name "*.js" 2>/dev/null | wc -l)
        log_info "  CSS files: $css_count, JS files: $js_count"
    fi
    
    # Check public directory
    if [[ ! -d "$LOCAL_DIR/public" ]]; then
        log_warning "⚠️  Missing: $LOCAL_DIR/public (optional)"
    else
        log_success "✅ Found: public"
        log_info "  Files: $(find $LOCAL_DIR/public -type f | wc -l) files"
    fi
    
    if [[ "$has_error" == true ]]; then
        log_error "Build verification failed!"
        log_error "Hint: Run with --build flag: ./deploy-remote.sh --build"
        exit 1
    fi
    
    log_success "✅ All required build outputs found!"
}

# Function: Deploy to server
deploy_to_server() {
    log_info "═══════════════════════════════════════════════════════"
    log_info "Deploying to server..."
    log_info "═══════════════════════════════════════════════════════"
    
    # Create remote directory structure
    log_info "Step 1: Creating remote directory structure..."
    ssh "${SERVER_USER}@${SERVER_IP}" "mkdir -p ${REMOTE_DIR}/.next/standalone ${REMOTE_DIR}/.next/static ${REMOTE_DIR}/public"
    
    # Sync .next/standalone
    log_info "Step 2: Syncing .next/standalone..."
    rsync -avz --delete \
        "$LOCAL_DIR/.next/standalone/" \
        "${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/.next/standalone/" \
        --exclude 'node_modules' \
        --exclude '.git'
    
    # Sync .next/static
    log_info "Step 3: Syncing .next/static..."
    rsync -avz --delete \
        "$LOCAL_DIR/.next/static/" \
        "${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/.next/static/"
    
    # Sync public directory
    if [[ -d "$LOCAL_DIR/public" ]]; then
        log_info "Step 4: Syncing public directory..."
        rsync -avz --delete \
            "$LOCAL_DIR/public/" \
            "${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/public/"
    fi
    
    # Sync package.json and other configs
    log_info "Step 5: Syncing configuration files..."
    rsync -avz \
        "$LOCAL_DIR/package.json" \
        "$LOCAL_DIR/next.config.ts" \
        "${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/"
    
    log_success "✅ All files synced successfully!"
}

# Function: Restart application on server
restart_app() {
    log_info "═══════════════════════════════════════════════════════"
    log_info "Restarting application on server..."
    log_info "═══════════════════════════════════════════════════════"
    
    # Stop existing process
    log_info "Stopping existing process..."
    ssh "${SERVER_USER}@${SERVER_IP}" "cd ${REMOTE_DIR} && pkill -f 'node.*server.js' || true"
    
    sleep 2
    
    # Start application
    log_info "Starting application..."
    ssh "${SERVER_USER}@${SERVER_IP}" "cd ${REMOTE_DIR}/.next/standalone && nohup node server.js > /tmp/innerbright.log 2>&1 &"
    
    sleep 3
    
    # Check if process is running
    log_info "Checking application status..."
    if ssh "${SERVER_USER}@${SERVER_IP}" "pgrep -f 'node.*server.js' > /dev/null"; then
        log_success "✅ Application is running!"
        log_info "Application URL: http://${SERVER_IP}:3000"
        log_info "View logs: ssh ${SERVER_USER}@${SERVER_IP} 'tail -f /tmp/innerbright.log'"
    else
        log_error "❌ Application failed to start!"
        log_info "Check logs: ssh ${SERVER_USER}@${SERVER_IP} 'cat /tmp/innerbright.log'"
        exit 1
    fi
}

# Main execution
main() {
    log_info "═══════════════════════════════════════════════════════"
    log_info "INNERBRIGHT DEPLOYMENT SCRIPT"
    log_info "═══════════════════════════════════════════════════════"
    log_info "Server: ${SERVER_USER}@${SERVER_IP}"
    log_info "Remote directory: ${REMOTE_DIR}"
    log_info "Build mode: $([ "$BUILD_FRONTEND" == true ] && echo 'YES' || echo 'NO')"
    log_info "═══════════════════════════════════════════════════════"
    echo ""
    
    # Build if requested
    if [[ "$BUILD_FRONTEND" == true ]]; then
        build_frontend
        echo ""
    fi
    
    # Verify build
    verify_build
    echo ""
    
    # Confirm deployment
    read -p "Deploy to ${SERVER_IP}? (y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Deployment cancelled."
        exit 0
    fi
    
    # Deploy
    deploy_to_server
    echo ""
    
    # Restart
    read -p "Restart application? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restart_app
    else
        log_info "Skipping restart. You can manually restart later."
    fi
    
    echo ""
    log_success "═══════════════════════════════════════════════════════"
    log_success "DEPLOYMENT COMPLETED SUCCESSFULLY!"
    log_success "═══════════════════════════════════════════════════════"
}

# Run main function
main
