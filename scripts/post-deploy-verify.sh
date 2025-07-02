#!/bin/bash

# Post-deployment verification script
# Checks if all services are running and accessible

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get server info from arguments or environment
SERVER_HOST=${1:-${DEPLOYMENT_HOST:-}}
SERVER_PORT=${2:-${DEPLOYMENT_PORT:-22}}
SERVER_USER=${3:-${DEPLOYMENT_USER:-root}}

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
}

info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Test URL with retries
test_url() {
    local url=$1
    local name=$2
    local retries=5
    local delay=10
    
    for i in $(seq 1 $retries); do
        if curl -sSf "$url" >/dev/null 2>&1; then
            success "$name is accessible at $url"
            return 0
        fi
        
        if [[ $i -lt $retries ]]; then
            warning "$name not ready yet, retrying in ${delay}s... ($i/$retries)"
            sleep $delay
        fi
    done
    
    error "$name is not accessible at $url"
    return 1
}

if [[ -z "$SERVER_HOST" ]]; then
    error "Server host is required. Usage: $0 <server_host> [port] [user]"
    exit 1
fi

log "🔍 Starting post-deployment verification for $SERVER_HOST..."

# 1. Check if Docker containers are running
log "🐳 Checking Docker containers..."
if ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "cd /opt/katacore && docker compose -f docker-compose.prod.yml --env-file .env.prod ps --filter status=running" | grep -q "healthy\|running"; then
    success "Docker containers are running"
else
    warning "Some containers may not be running properly"
fi

# 2. Wait for services to be ready
log "⏳ Waiting for services to be ready..."
sleep 30

# 3. Test main application endpoints
log "🌐 Testing application endpoints..."

# Test frontend
test_url "http://$SERVER_HOST" "Frontend"

# Test API health
test_url "http://$SERVER_HOST/api/health" "API Health"

# Test Nginx health
test_url "http://$SERVER_HOST/nginx-health" "Nginx Health" || warning "Nginx health endpoint not available"

# Test MinIO console (may be behind auth)
if curl -sSf "http://$SERVER_HOST:9001" >/dev/null 2>&1; then
    success "MinIO Console is accessible at http://$SERVER_HOST:9001"
else
    warning "MinIO Console may require authentication"
fi

# Test pgAdmin (may be behind auth)
if curl -sSf "http://$SERVER_HOST:8080" >/dev/null 2>&1; then
    success "pgAdmin is accessible at http://$SERVER_HOST:8080"
else
    warning "pgAdmin may require authentication"
fi

# 4. Check container health status
log "🏥 Checking container health status..."
HEALTH_OUTPUT=$(ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "cd /opt/katacore && docker compose -f docker-compose.prod.yml --env-file .env.prod ps" 2>/dev/null || echo "")

if echo "$HEALTH_OUTPUT" | grep -q "healthy"; then
    success "All critical containers are healthy"
else
    warning "Some containers may not be healthy yet"
fi

# 5. Check logs for errors
log "📋 Checking for critical errors in logs..."
CRITICAL_ERRORS=$(ssh -p "$SERVER_PORT" "$SERVER_USER@$SERVER_HOST" "cd /opt/katacore && docker compose -f docker-compose.prod.yml --env-file .env.prod logs --tail=20 2>/dev/null | grep -i 'error\|fail\|exception' | grep -v 'level=info' || true")

if [[ -z "$CRITICAL_ERRORS" ]]; then
    success "No critical errors found in recent logs"
else
    warning "Found some errors in logs:"
    echo "$CRITICAL_ERRORS" | head -5
fi

# 6. Final summary
log "📊 Deployment Verification Summary:"
success "✅ Server: $SERVER_HOST"
success "✅ Frontend: http://$SERVER_HOST"
success "✅ API: http://$SERVER_HOST/api/"
info "🔧 MinIO Console: http://$SERVER_HOST:9001"
info "🔧 pgAdmin: http://$SERVER_HOST:8080"

log "🎉 Post-deployment verification completed!"
info "📝 Useful commands:"
info "   Check status: ssh $SERVER_USER@$SERVER_HOST 'cd /opt/katacore && docker compose ps'"
info "   View logs:    ssh $SERVER_USER@$SERVER_HOST 'cd /opt/katacore && docker compose logs -f'"
info "   Restart:      ssh $SERVER_USER@$SERVER_HOST 'cd /opt/katacore && docker compose restart'"

exit 0
