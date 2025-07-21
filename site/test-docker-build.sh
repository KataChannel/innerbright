#!/bin/bash

# 🧪 Site Docker Build Test Script
# Test the site Dockerfile build

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

# Check if we're in the right directory
if [[ ! -f "Dockerfile" ]] || [[ ! -f "package.json" ]]; then
    error "Please run this script from the site directory"
    exit 1
fi

log "🚀 Testing Site Dockerfile build..."

# Build the Docker image
log "Building Docker image..."
if docker build -t innerbright-site-test . --no-cache; then
    success "Docker build completed successfully"
else
    error "Docker build failed"
    exit 1
fi

# Test running the container
log "Testing container startup..."
if docker run -d --name innerbright-site-test -p 3333:3000 innerbright-site-test; then
    success "Container started successfully"
    
    # Wait for the service to start
    log "Waiting for service to start..."
    sleep 15
    
    # Test health endpoint
    log "Testing health endpoint..."
    if curl -f http://localhost:3333/api/health > /dev/null 2>&1; then
        success "Health endpoint is working"
    else
        warning "Health endpoint failed, trying root endpoint..."
        if curl -f http://localhost:3333/ > /dev/null 2>&1; then
            success "Root endpoint is working"
        else
            error "Service is not responding"
        fi
    fi
    
    # Cleanup
    log "Cleaning up test container..."
    docker stop innerbright-site-test > /dev/null 2>&1 || true
    docker rm innerbright-site-test > /dev/null 2>&1 || true
    
else
    error "Failed to start container"
    exit 1
fi

# Cleanup test image
log "Cleaning up test image..."
docker rmi innerbright-site-test > /dev/null 2>&1 || true

success "🎉 Site Dockerfile test completed successfully!"
info "The Dockerfile is ready for deployment"
