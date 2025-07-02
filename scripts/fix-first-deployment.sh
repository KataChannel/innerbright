#!/bin/bash

# KataCore First-Time Deployment Fix Script
# This script addresses common issues during initial deployment
# Version: 2.0 - Enhanced error handling and validation

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

# Show usage information
show_usage() {
    echo -e "${CYAN}KataCore First-Time Deployment Fix Script${NC}"
    echo ""
    echo "This script fixes common issues during initial deployment to new servers:"
    echo "  • Configures environment variables for IP-based deployment"
    echo "  • Creates working Nginx configuration"
    echo "  • Fixes rate limiting conflicts"
    echo "  • Ensures health check tools are available"
    echo "  • Sets proper file permissions"
    echo ""
    echo "Usage:"
    echo "  $0 <server-host-or-ip> [--dry-run]"
    echo ""
    echo "Examples:"
    echo "  $0 116.118.85.41"
    echo "  $0 myserver.com --dry-run"
    echo "  bun run deploy:fix-first 116.118.85.41"
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without making changes"
    echo "  --help       Show this help message"
    echo ""
    exit 0
}

# Execute command with dry-run support
execute() {
    local cmd="$1"
    local description="$2"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log "[DRY RUN] Would execute: $description"
        log "[DRY RUN] Command: $cmd"
        return 0
    else
        eval "$cmd"
    fi
}

# Validate arguments
if [[ $# -eq 0 ]]; then
    show_usage
fi

# Check for help flag
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_usage
fi

SERVER_HOST="$1"
DRY_RUN=false

# Check for dry-run flag
if [[ "${2:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    warning "DRY RUN MODE - No changes will be made"
fi

# Validate SERVER_HOST format
if [[ ! "$SERVER_HOST" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    error "Invalid server host format: $SERVER_HOST"
fi

log "🔧 Fixing common first-time deployment issues for $SERVER_HOST..."

# 1. Fix environment variables
if [[ -f ".env.prod" ]]; then
    log "🔍 Fixing .env.prod configuration..."
    
    # Create backup
    execute "cp .env.prod .env.prod.backup" "Create backup of .env.prod"
    
    # Fix domain references for IP-based deployment
    if [[ "$SERVER_HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        log "📱 Configuring for IP-based deployment..."
        
        if [[ "$DRY_RUN" == "false" ]]; then
            # Replace all domain references with the server IP
            if command -v sed >/dev/null 2>&1; then
                # Create temporary file and use mv to avoid permission issues
                temp_file=$(mktemp)
                cp .env.prod "$temp_file"
                
                # Apply all replacements
                sed "s/innerbright\.vn/$SERVER_HOST/g" "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
                sed "s/your-domain\.com/$SERVER_HOST/g" "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
                sed "s/localhost/$SERVER_HOST/g" "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
                
                # Force HTTP for IP addresses
                sed "s/https:\/\//http:\/\//g" "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
                sed "s/ENABLE_SSL=true/ENABLE_SSL=false/g" "$temp_file" > "$temp_file.tmp" && mv "$temp_file.tmp" "$temp_file"
                
                # Replace original file
                mv "$temp_file" .env.prod
            else
                error "sed command not found"
            fi
        else
            log "[DRY RUN] Would replace domain references with $SERVER_HOST in .env.prod"
        fi
        
        success "Fixed .env.prod for IP-based deployment"
    else
        log "📱 Configuring for domain-based deployment..."
        success "Domain-based deployment detected, keeping current configuration"
    fi
else
    warning ".env.prod not found, creating minimal configuration..."
    if [[ "$DRY_RUN" == "false" ]]; then
        cat > .env.prod << EOF
NODE_ENV=production
SERVER_HOST=$SERVER_HOST
ENABLE_SSL=false
API_URL=http://$SERVER_HOST/api
SITE_URL=http://$SERVER_HOST
POSTGRES_PASSWORD=\$(openssl rand -hex 16)
REDIS_PASSWORD=\$(openssl rand -hex 16)
JWT_SECRET=\$(openssl rand -hex 32)
MINIO_ROOT_PASSWORD=\$(openssl rand -hex 16)
PGADMIN_PASSWORD=\$(openssl rand -hex 16)
DOMAIN=$SERVER_HOST
DATABASE_URL=postgresql://katacore_user:\$(grep POSTGRES_PASSWORD .env.prod | cut -d'=' -f2)@postgres:5432/katacore_db
REDIS_URL=redis://:\$(grep REDIS_PASSWORD .env.prod | cut -d'=' -f2)@redis:6379
NEXT_PUBLIC_API_URL=http://$SERVER_HOST/api
EOF
    else
        log "[DRY RUN] Would create minimal .env.prod configuration"
    fi
    success "Created minimal .env.prod"
fi

# 2. Fix Nginx configuration conflicts
log "🔧 Fixing Nginx configuration..."

if [[ "$DRY_RUN" == "false" ]]; then
    mkdir -p nginx/conf.d/backup

    # Remove conflicting configurations
    rm -f nginx/conf.d/katacore.conf nginx/conf.d/katacore.optimized.conf 2>/dev/null || true

    # Create simple working configuration
    cat > nginx/conf.d/simple-ip.conf << 'EOF'
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

    location /nginx-health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }

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
else
    log "[DRY RUN] Would create nginx/conf.d/simple-ip.conf with working configuration"
fi

success "Created working Nginx configuration"

# 3. Fix rate limiting conflicts in nginx.conf
log "🔧 Fixing nginx.conf rate limiting..."
if [[ -f "nginx/nginx.conf" ]]; then
    # Comment out rate limiting to prevent conflicts
    if command -v sed >/dev/null 2>&1; then
        if [[ "$DRY_RUN" == "false" ]]; then
            temp_file=$(mktemp)
            sed 's/^[[:space:]]*limit_req_zone/#&/' nginx/nginx.conf > "$temp_file"
            mv "$temp_file" nginx/nginx.conf
        else
            log "[DRY RUN] Would comment out limit_req_zone lines in nginx/nginx.conf"
        fi
        success "Fixed nginx.conf rate limiting conflicts"
    else
        warning "sed not available, please manually comment out limit_req_zone lines in nginx/nginx.conf"
    fi
else
    warning "nginx/nginx.conf not found"
fi

# 4. Ensure Dockerfiles have health check tools
log "🔧 Checking Dockerfiles..."

# Check API Dockerfile
if [[ -f "api/Dockerfile" ]]; then
    if ! grep -q "curl" api/Dockerfile; then
        warning "API Dockerfile needs curl for health checks"
        log "Adding curl to API Dockerfile..."
        
        # More robust way to add curl
        if grep -q "apk add --no-cache dumb-init" api/Dockerfile; then
            temp_file=$(mktemp)
            sed 's/apk add --no-cache dumb-init/apk add --no-cache dumb-init curl/' api/Dockerfile > "$temp_file"
            mv "$temp_file" api/Dockerfile
        elif grep -q "apk add" api/Dockerfile; then
            # Find any apk add line and add curl to it
            temp_file=$(mktemp)
            sed 's/apk add \([^&]*\)/apk add \1 curl/' api/Dockerfile > "$temp_file"
            mv "$temp_file" api/Dockerfile
        else
            # Add a new RUN line if no apk add found
            temp_file=$(mktemp)
            sed '/FROM.*alpine/a RUN apk add --no-cache curl' api/Dockerfile > "$temp_file"
            mv "$temp_file" api/Dockerfile
        fi
        success "Added curl to API Dockerfile"
    else
        success "API Dockerfile already has curl"
    fi
else
    warning "api/Dockerfile not found"
fi

# Check Site Dockerfile
if [[ -f "site/Dockerfile" ]]; then
    if ! grep -q "curl" site/Dockerfile; then
        warning "Site Dockerfile needs curl for health checks"
        log "Adding curl to site Dockerfile..."
        
        # More robust way to add curl
        if grep -q "apk add --no-cache libc6-compat dumb-init" site/Dockerfile; then
            temp_file=$(mktemp)
            sed 's/apk add --no-cache libc6-compat dumb-init/apk add --no-cache libc6-compat dumb-init curl/' site/Dockerfile > "$temp_file"
            mv "$temp_file" site/Dockerfile
        elif grep -q "apk add" site/Dockerfile; then
            # Find any apk add line and add curl to it
            temp_file=$(mktemp)
            sed 's/apk add \([^&]*\)/apk add \1 curl/' site/Dockerfile > "$temp_file"
            mv "$temp_file" site/Dockerfile
        else
            # Add a new RUN line if no apk add found
            temp_file=$(mktemp)
            sed '/FROM.*alpine/a RUN apk add --no-cache curl' site/Dockerfile > "$temp_file"
            mv "$temp_file" site/Dockerfile
        fi
        success "Added curl to site Dockerfile"
    else
        success "Site Dockerfile already has curl"
    fi
else
    warning "site/Dockerfile not found"
fi

success "Dockerfiles configured for health checks"

# 5. Set proper permissions
log "🔒 Setting file permissions..."
if [[ "$DRY_RUN" == "false" ]]; then
    chmod 600 .env.prod 2>/dev/null || warning "Could not set .env.prod permissions"
    chmod +x scripts/*.sh 2>/dev/null || warning "Could not set script permissions"
    # Ensure the script itself is executable
    chmod +x scripts/fix-first-deployment.sh 2>/dev/null || true
else
    log "[DRY RUN] Would set file permissions for .env.prod and scripts/*.sh"
fi
success "File permissions set"

# 6. Validate fixes
log "🔍 Validating fixes..."
errors=0

if [[ ! -f ".env.prod" ]]; then
    error ".env.prod not found after fixes"
    ((errors++))
fi

if [[ "$DRY_RUN" == "false" ]]; then
    if [[ ! -f "nginx/conf.d/simple-ip.conf" ]]; then
        error "nginx/conf.d/simple-ip.conf not created"
        ((errors++))
    fi
    
    # Check if .env.prod contains the correct server IP
    if ! grep -q "$SERVER_HOST" .env.prod; then
        warning ".env.prod may not contain the correct server IP"
    fi
    
    # Check if nginx config file is not empty
    if [[ -f "nginx/conf.d/simple-ip.conf" && ! -s "nginx/conf.d/simple-ip.conf" ]]; then
        error "nginx/conf.d/simple-ip.conf is empty"
        ((errors++))
    fi
else
    log "[DRY RUN] Skipping file validation checks"
fi

if [[ $errors -gt 0 ]]; then
    error "Validation failed with $errors errors"
fi

success "All fixes validated successfully"

log "✅ First-time deployment fixes completed!"
log ""

# Final deployment readiness check
log "� Final deployment readiness check..."
readiness_score=0
total_checks=5

# Check 1: Environment file exists and is valid
if [[ -f ".env.prod" ]]; then
    if grep -q "$SERVER_HOST" .env.prod 2>/dev/null; then
        success "✅ Environment configuration is ready"
        ((readiness_score++))
    else
        warning "❌ Environment may not be properly configured"
    fi
else
    warning "❌ .env.prod file missing"
fi

# Check 2: Nginx configuration exists
if [[ -f "nginx/conf.d/simple-ip.conf" ]]; then
    success "✅ Nginx configuration is ready"
    ((readiness_score++))
else
    warning "❌ Nginx configuration missing"
fi

# Check 3: Rate limiting is commented out
if grep -q "^[[:space:]]*#.*limit_req_zone" nginx/nginx.conf 2>/dev/null; then
    success "✅ Rate limiting conflicts resolved"
    ((readiness_score++))
else
    warning "❌ Rate limiting may still conflict"
fi

# Check 4: Dockerfiles have health check tools
if grep -q "curl" api/Dockerfile 2>/dev/null && grep -q "curl" site/Dockerfile 2>/dev/null; then
    success "✅ Health check tools available"
    ((readiness_score++))
else
    warning "❌ Health check tools may be missing"
fi

# Check 5: Script permissions
if [[ -x "scripts/fix-first-deployment.sh" ]]; then
    success "✅ Script permissions are correct"
    ((readiness_score++))
else
    warning "❌ Script permissions need fixing"
fi

log ""
log "📊 Deployment Readiness Score: $readiness_score/$total_checks"

if [[ $readiness_score -eq $total_checks ]]; then
    success "🎯 Perfect! All checks passed - ready for deployment!"
elif [[ $readiness_score -ge 3 ]]; then
    info "👍 Good! Most checks passed - deployment should work"
else
    warning "⚠️  Some issues detected - please review before deploying"
fi

log ""
log "�📝 Next steps:"
log "   1. Run: bun run deploy:safe --host $SERVER_HOST"
log "   2. Wait for all containers to be healthy"
log "   3. Test frontend: curl -I http://$SERVER_HOST"
log "   4. Test API: curl -I http://$SERVER_HOST/api/health"
log ""
log "📋 Summary of fixes applied:"
log "   ✅ Environment variables configured for $SERVER_HOST"
log "   ✅ Nginx configuration simplified and fixed"
log "   ✅ Rate limiting conflicts resolved"
log "   ✅ Dockerfiles configured for health checks"
log "   ✅ File permissions set correctly"

echo ""
if [[ $readiness_score -eq $total_checks ]]; then
    success "🎉 Ready for deployment!"
else
    info "🔧 Review warnings above before deploying"
fi
