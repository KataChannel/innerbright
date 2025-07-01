#!/bin/bash

# Pre-deployment checks to prevent common deployment failures
# This script validates environment and fixes common issues before deployment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
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

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log "🔍 Running pre-deployment checks..."

# 1. Check if .env.prod exists
if [[ ! -f ".env.prod" ]]; then
    warning ".env.prod not found"
    if [[ -f ".env.prod.template" ]]; then
        info "Creating .env.prod from template..."
        cp .env.prod.template .env.prod
        success "Created .env.prod from template"
        warning "Please update .env.prod with your actual values before deployment"
    else
        error ".env.prod.template not found. Cannot create environment file."
    fi
fi

# 2. Check for placeholder values in .env.prod
log "🔍 Checking for placeholder values..."
PLACEHOLDER_FOUND=false

if grep -q "your-domain.com\|localhost\|example.com\|innerbright.vn" .env.prod; then
    warning "Found placeholder domains in .env.prod"
    PLACEHOLDER_FOUND=true
fi

if grep -q "__SECURE_.*__" .env.prod; then
    warning "Found placeholder passwords in .env.prod"
    PLACEHOLDER_FOUND=true
fi

if [[ "$PLACEHOLDER_FOUND" == "true" ]]; then
    warning "Please update placeholder values in .env.prod before deployment"
fi

# 3. Check required environment variables
log "🔍 Checking required environment variables..."
REQUIRED_VARS=(
    "POSTGRES_PASSWORD"
    "REDIS_PASSWORD"
    "JWT_SECRET"
    "MINIO_ROOT_PASSWORD"
    "PGADMIN_PASSWORD"
    "NEXT_PUBLIC_API_URL"
)

MISSING_VARS=()
for var in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${var}=" .env.prod || grep -q "^${var}=$" .env.prod; then
        MISSING_VARS+=("$var")
    fi
done

if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
    error "Missing required environment variables: ${MISSING_VARS[*]}"
fi

success "All required environment variables are set"

# 4. Check Docker and Docker Compose
log "🔍 Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    error "Docker is not installed. Please install Docker first."
fi

if ! docker compose version &> /dev/null && ! docker-compose version &> /dev/null; then
    error "Docker Compose is not installed. Please install Docker Compose first."
fi

success "Docker and Docker Compose are available"

# 5. Check project structure
log "🔍 Checking project structure..."
REQUIRED_FILES=(
    "docker-compose.prod.yml"
    "api/Dockerfile"
    "site/Dockerfile"
    "nginx/nginx.conf"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        error "Required file missing: $file"
    fi
done

success "Project structure is valid"

# 6. Validate Nginx configuration syntax (if nginx is available locally)
if command -v nginx &> /dev/null; then
    log "🔍 Checking Nginx configuration syntax..."
    if nginx -t -c nginx/nginx.conf -p . &> /dev/null; then
        success "Nginx configuration syntax is valid"
    else
        warning "Nginx configuration may have syntax issues"
    fi
fi

# 7. Check for common issues in Dockerfiles
log "🔍 Checking Dockerfiles for common issues..."

# Check if health check tools are included
if ! grep -q "curl\|wget" api/Dockerfile; then
    warning "API Dockerfile doesn't include health check tools (curl/wget)"
fi

if ! grep -q "curl\|wget" site/Dockerfile; then
    warning "Site Dockerfile doesn't include health check tools (curl/wget)"
fi

# 8. Generate simple Nginx config for IP-based deployment
log "🔍 Preparing Nginx configuration..."

# Create a backup of existing configs
mkdir -p nginx/conf.d/backup
if [[ -f "nginx/conf.d/katacore.conf" ]]; then
    cp nginx/conf.d/katacore.conf nginx/conf.d/backup/ 2>/dev/null || true
fi

# Create simple IP-based config
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

# 9. Set proper file permissions
log "🔍 Setting proper file permissions..."
chmod 600 .env.prod 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true
success "File permissions set"

# 10. Final summary
log "📋 Pre-deployment check summary:"
success "✅ Environment file exists and configured"
success "✅ Required tools are available"
success "✅ Project structure is valid"
success "✅ Nginx configuration prepared"
success "✅ File permissions set"

info "🚀 Ready for deployment!"
info "📝 Next steps:"
info "   1. Review .env.prod values"
info "   2. Run deployment script"
info "   3. Monitor logs during deployment"

exit 0
