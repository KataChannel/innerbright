#!/bin/bash

# KataCore Simple Local Test Script
# Quick and easy local deployment for testing

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; exit 1; }

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                 KataCore Local Test Deploy                   ║"
echo "║                    Quick & Simple                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check Docker
log "🔍 Checking Docker..."
if ! docker ps >/dev/null 2>&1; then
    error "Docker is not running. Please start Docker first."
fi
success "Docker is running"

# Setup environment
log "🔧 Setting up environment..."
if [[ ! -f ".env.local" ]]; then
    if [[ -f ".env.local.example" ]]; then
        cp .env.local.example .env.local
        success "Created .env.local from example"
    else
        warning "Creating basic .env.local"
        cat > .env.local << 'EOF'
NODE_ENV=development
POSTGRES_DB=katacore_local
POSTGRES_USER=katacore_user
POSTGRES_PASSWORD=local_postgres_pass_123
REDIS_PASSWORD=local_redis_pass_123
JWT_SECRET=local_jwt_secret_key_for_development_only_32_chars
MINIO_ROOT_USER=katacore_minio_admin
MINIO_ROOT_PASSWORD=local_minio_pass_123
PGLADMIN_EMAIL=admin@localhost.com
PGADMIN_PASSWORD=local_pgladmin_pass_123
CORS_ORIGIN=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3001
EOF
        success "Created basic .env.local"
    fi
else
    info ".env.local already exists"
fi

# Parse arguments
CLEAN_DEPLOY=false
SHOW_LOGS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN_DEPLOY=true
            shift
            ;;
        --logs)
            SHOW_LOGS=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --clean    Clean deploy (remove containers and volumes)"
            echo "  --logs     Show logs after deployment"
            echo "  --help     Show this help"
            exit 0
            ;;
        *)
            warning "Unknown option: $1 (ignored)"
            shift
            ;;
    esac
done

# Clean up if requested
if [[ "$CLEAN_DEPLOY" == "true" ]]; then
    log "🧹 Cleaning up previous deployment..."
    docker compose -f docker-compose.test.yml down -v --remove-orphans 2>/dev/null || true
    docker system prune -f >/dev/null 2>&1 || true
    success "Cleanup completed"
fi

# Deploy
log "🚀 Deploying services..."
docker compose -f docker-compose.test.yml up -d --build

# Wait a bit for services to start
log "⏳ Waiting for services to start..."
sleep 10

# Basic health checks
log "🔍 Checking basic service status..."

# Check if containers are running
containers=("katacore-postgres-local" "katacore-redis-local" "katacore-api-local" "katacore-site-local")
for container in "${containers[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "$container"; then
        success "$container is running"
    else
        warning "$container may not be running properly"
    fi
done

# Quick connection tests
if curl -s http://localhost:3001/health >/dev/null 2>&1; then
    success "API is responding"
else
    warning "API may not be ready yet"
fi

if curl -s http://localhost:3000 >/dev/null 2>&1; then
    success "Frontend is responding"
else
    warning "Frontend may not be ready yet"
fi

# Show access information
echo ""
success "🎉 Local deployment completed!"
echo ""
info "🌐 Access URLs:"
echo "   Frontend:     http://localhost:3000"
echo "   API:          http://localhost:3001"
echo "   API Health:   http://localhost:3001/health"
echo "   PgAdmin:      http://localhost:8080"
echo "   MinIO Console: http://localhost:9001"
echo ""
info "🔑 Default Credentials:"
echo "   PgAdmin:      admin@localhost.com / local_pgladmin_pass_123"
echo "   MinIO:        katacore_minio_admin / local_minio_pass_123"
echo ""
info "🛠️  Useful Commands:"
echo "   Stop all:     docker compose -f docker-compose.test.yml down"
echo "   View logs:    docker compose -f docker-compose.test.yml logs -f [service]"
echo "   Clean deploy: $0 --clean"
echo ""

# Show logs if requested
if [[ "$SHOW_LOGS" == "true" ]]; then
    echo ""
    info "📋 Recent logs:"
    echo ""
    echo -e "${CYAN}=== API Logs ===${NC}"
    docker logs katacore-api-local --tail 20 2>/dev/null || echo "API logs not available yet"
    echo ""
    echo -e "${CYAN}=== Frontend Logs ===${NC}"
    docker logs katacore-site-local --tail 20 2>/dev/null || echo "Frontend logs not available yet"
fi

success "🚀 KataCore is running locally!"
info "💡 Use 'docker compose -f docker-compose.test.yml logs -f' to follow all logs"
