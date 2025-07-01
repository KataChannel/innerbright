#!/bin/bash

# Cleanup and preparation script for KataCore deployment
# Removes conflicting configurations and prepares environment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log "🧹 Running cleanup and preparation..."

# 1. Backup existing configurations
if [[ -d "nginx/conf.d" ]]; then
    mkdir -p nginx/conf.d/backup
    for conf in nginx/conf.d/*.conf; do
        if [[ -f "$conf" ]] && [[ "$(basename "$conf")" != "simple-ip.conf" ]]; then
            cp "$conf" "nginx/conf.d/backup/" 2>/dev/null || true
            info "Backed up $(basename "$conf")"
        fi
    done
fi

# 2. Remove potentially conflicting Docker containers
log "🐳 Cleaning up existing containers..."
if command -v docker &> /dev/null; then
    # Stop and remove containers with katacore prefix
    docker ps -a --format "table {{.Names}}" | grep "katacore.*prod" | while read -r container; do
        if [[ -n "$container" ]]; then
            warning "Stopping container: $container"
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        fi
    done
    
    # Clean up unused images and volumes
    docker system prune -f 2>/dev/null || true
    success "Docker cleanup completed"
fi

# 3. Reset Nginx configuration to simple state
log "🔧 Preparing Nginx configuration..."
if [[ -d "nginx/conf.d" ]]; then
    # Remove all .conf files except simple-ip.conf
    for conf in nginx/conf.d/*.conf; do
        if [[ -f "$conf" ]] && [[ "$(basename "$conf")" != "simple-ip.conf" ]]; then
            rm -f "$conf"
        fi
    done
    
    # Ensure simple-ip.conf exists
    if [[ ! -f "nginx/conf.d/simple-ip.conf" ]]; then
        cat > nginx/conf.d/simple-ip.conf << 'EOF'
# Simple IP-based configuration for initial deployment
upstream katacore_api {
    server api:3001;
    keepalive 32;
}

upstream katacore_site {
    server site:3000;
    keepalive 32;
}

server {
    listen 80 default_server;
    server_name _;

    # Health check endpoint
    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

    # API routes
    location /api/ {
        proxy_pass http://katacore_api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Frontend routes
    location / {
        proxy_pass http://katacore_site/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF
        success "Created simple Nginx configuration"
    fi
fi

# 4. Ensure deployment logs directory exists
mkdir -p .deploy-logs .deploy-cache
touch .deploy-logs/.gitkeep .deploy-cache/.gitkeep

# 5. Set proper permissions
chmod +x scripts/*.sh 2>/dev/null || true
if [[ -f ".env.prod" ]]; then
    chmod 600 .env.prod
fi

success "🎉 Cleanup and preparation completed!"
info "📋 Summary:"
info "   ✅ Backed up existing configurations"
info "   ✅ Cleaned up Docker containers"
info "   ✅ Prepared simple Nginx configuration"
info "   ✅ Set proper file permissions"
info ""
info "🚀 Ready for fresh deployment!"

exit 0
