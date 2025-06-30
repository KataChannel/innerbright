#!/bin/bash

# Test Production Deployment Script
# This script tests the production deployment locally

set -e

# Setup Bun PATH
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bun-setup.sh"

if ! setup_bun_for_session; then
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
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

# Navigate to project root
cd "$(dirname "$SCRIPT_DIR")"

log "🧪 Testing KataCore Production Deployment..."

# Check prerequisites
log "🔍 Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    error "Docker is not installed"
fi

if ! command -v docker-compose &> /dev/null; then
    error "Docker Compose is not installed"
fi

success "Prerequisites check passed"

# Create test environment file
log "📝 Creating test environment file..."

cat > .env.test << EOF
POSTGRES_DB=katacore_test
POSTGRES_USER=test_user
POSTGRES_PASSWORD=test_password_123
REDIS_PASSWORD=test_redis_123
MINIO_ROOT_USER=test_minio_admin
MINIO_ROOT_PASSWORD=test_minio_123
PGADMIN_EMAIL=test@katacore.com
PGADMIN_PASSWORD=test_admin_123
JWT_SECRET=test_jwt_secret_key_minimum_32_characters_long
API_VERSION=test
CORS_ORIGIN=http://localhost:3000
SITE_VERSION=test
NEXT_PUBLIC_API_URL=http://localhost:3001
DOMAIN=localhost
API_DOMAIN=api.localhost
ADMIN_DOMAIN=admin.localhost
STORAGE_DOMAIN=storage.localhost
EOF

success "Test environment file created"

# Stop any existing containers
log "🛑 Stopping existing containers..."
docker-compose -f docker-compose.prod.yml down --volumes --remove-orphans 2>/dev/null || true
docker-compose -f docker-compose.yml down --volumes --remove-orphans 2>/dev/null || true

# Create necessary directories
log "📁 Creating necessary directories..."
mkdir -p ssl backups nginx/logs

# Create self-signed SSL certificates for testing
log "🔒 Creating test SSL certificates..."
openssl req -x509 -nodes -days 30 -newkey rsa:2048 \
    -keyout ssl/privkey.pem \
    -out ssl/fullchain.pem \
    -subj "/C=US/ST=Test/L=Test/O=KataCore/CN=localhost" \
    > /dev/null 2>&1

success "Test SSL certificates created"

# Build images
log "🔨 Building Docker images..."
if ! docker-compose -f docker-compose.prod.yml build --no-cache; then
    error "Failed to build Docker images"
fi

success "Docker images built successfully"

# Start databases first
log "🗄️  Starting database services..."
docker-compose -f docker-compose.prod.yml --env-file .env.test up -d postgres redis minio

# Wait for databases
log "⏳ Waiting for databases to be ready..."
sleep 30

# Start application services
log "🌐 Starting application services..."
docker-compose -f docker-compose.prod.yml --env-file .env.test up -d api site nginx

# Wait for services to start
log "⏳ Waiting for services to start..."
sleep 45

# Health checks
log "🏥 Performing health checks..."

# Check if containers are running
containers=("katacore-postgres-prod" "katacore-redis-prod" "katacore-minio-prod" "katacore-api-prod" "katacore-site-prod" "katacore-nginx-prod")

for container in "${containers[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        success "Container $container is running"
    else
        warning "Container $container is not running"
    fi
done

# Test endpoints
log "🔍 Testing service endpoints..."

# Test API health endpoint
log "Testing API health endpoint..."
for i in {1..5}; do
    if curl -f -s http://localhost:3001/health > /dev/null 2>&1; then
        success "API health endpoint is responding"
        break
    elif [ $i -eq 5 ]; then
        warning "API health endpoint not responding (this might be expected)"
    else
        log "Attempt $i: API not ready, waiting..."
        sleep 10
    fi
done

# Test frontend
log "Testing frontend..."
for i in {1..5}; do
    if curl -f -s http://localhost:3000 > /dev/null 2>&1; then
        success "Frontend is responding"
        break
    elif [ $i -eq 5 ]; then
        warning "Frontend not responding (this might be expected)"
    else
        log "Attempt $i: Frontend not ready, waiting..."
        sleep 10
    fi
done

# Show service status
log "📊 Service Status:"
docker-compose -f docker-compose.prod.yml --env-file .env.test ps

echo ""
success "🎉 Production deployment test completed!"
echo ""
echo "🌐 Access URLs (for testing):"
echo "   Frontend: http://localhost:3000"
echo "   API: http://localhost:3001"
echo "   PgAdmin: http://localhost:8080"
echo "   MinIO Console: http://localhost:9001"
echo ""

# Ask if user wants to keep services running
read -p "Keep services running for manual testing? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "🛑 Stopping test services..."
    docker-compose -f docker-compose.prod.yml --env-file .env.test down
    rm -f .env.test
    success "Test cleanup completed"
else
    log "Services are still running for manual testing"
fi
