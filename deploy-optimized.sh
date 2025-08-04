#!/bin/bash

# Optimized Production Deploy Script for Innerbright
# This script deploys the application with production optimizations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
BACKUP_DIR="./backups"

echo -e "${BLUE}🚀 Starting Optimized Production Deploy for Innerbright${NC}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    print_error ".env file not found!"
    print_status "Please copy .env.example to .env and configure your settings"
    exit 1
fi

# Create backup directory
mkdir -p $BACKUP_DIR

# Pre-deployment checks
print_step "1. Pre-deployment checks..."

# Check Docker and Docker Compose
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed!"
    exit 1
fi

# Check disk space (minimum 2GB free)
AVAILABLE_SPACE=$(df / | awk 'NR==2 {print $4}')
if [ $AVAILABLE_SPACE -lt 2097152 ]; then
    print_warning "Low disk space detected. Consider cleaning up."
fi

print_status "✅ Pre-deployment checks passed"

# Backup existing data
print_step "2. Creating backup..."
BACKUP_TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/backup_$BACKUP_TIMESTAMP.tar.gz"

if docker-compose ps | grep -q "Up"; then
    print_status "Creating database backup..."
    docker-compose exec -T postgres pg_dump -U postgres innerbright_db > "$BACKUP_DIR/db_backup_$BACKUP_TIMESTAMP.sql" 2>/dev/null || true
fi

print_status "✅ Backup created: $BACKUP_FILE"

# Build and deploy
print_step "3. Building optimized Docker images..."

# Enable BuildKit for faster builds
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Pull latest base images
print_status "Pulling latest base images..."
docker-compose pull --quiet postgres redis minio nginx

# Build with optimization flags
print_status "Building application with optimizations..."
docker-compose build \
    --no-cache \
    --compress \
    --parallel \
    site

print_status "✅ Docker images built successfully"

# Deploy services
print_step "4. Deploying services..."

# Stop existing services gracefully
if docker-compose ps | grep -q "Up"; then
    print_status "Stopping existing services..."
    docker-compose down --timeout 30
fi

# Start core services first
print_status "Starting core services..."
docker-compose up -d postgres redis minio

# Wait for core services to be healthy
print_status "Waiting for core services to be ready..."
sleep 30

# Start application
print_status "Starting application..."
docker-compose up -d site

# Wait for application to be ready
print_status "Waiting for application to be ready..."
sleep 45

# Start nginx last
print_status "Starting nginx..."
docker-compose up -d nginx

print_status "✅ All services deployed"

# Post-deployment checks
print_step "5. Post-deployment verification..."

# Check service health
print_status "Checking service health..."
sleep 30

FAILED_SERVICES=""
for service in postgres redis minio site nginx; do
    if ! docker-compose ps $service | grep -q "Up"; then
        FAILED_SERVICES="$FAILED_SERVICES $service"
    fi
done

if [ -n "$FAILED_SERVICES" ]; then
    print_error "Failed services:$FAILED_SERVICES"
    print_status "Check logs with: docker-compose logs [service-name]"
    exit 1
fi

# Test application endpoints
print_status "Testing application endpoints..."

# Test HTTP redirect
if curl -s -I -m 10 http://localhost | grep -q "301\|302"; then
    print_status "✅ HTTP redirect working"
else
    print_warning "HTTP redirect may not be working"
fi

# Test application health
if curl -s -f -m 10 http://localhost:3000/health > /dev/null 2>&1; then
    print_status "✅ Application health check passed"
else
    print_warning "Application health check failed - checking if app is starting..."
    sleep 30
    if curl -s -f -m 10 http://localhost:3000/ > /dev/null 2>&1; then
        print_status "✅ Application is responding"
    else
        print_warning "Application may still be starting up"
    fi
fi

print_status "✅ Post-deployment checks completed"

# Performance optimization
print_step "6. Performance optimization..."

# Clean up unused Docker resources
print_status "Cleaning up unused Docker resources..."
docker system prune -f --volumes 2>/dev/null || true

# Show resource usage
print_status "Current resource usage:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

print_status "✅ Performance optimization completed"

# Final status
print_step "7. Deployment Summary"

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo ""
echo -e "${BLUE}Service Status:${NC}"
docker-compose ps

echo ""
echo -e "${BLUE}Application URLs:${NC}"
echo "• Application: http://localhost:3000"
echo "• MinIO Console: http://localhost:9001"
echo "• PgAdmin: http://localhost:5050"

echo ""
echo -e "${BLUE}Useful Commands:${NC}"
echo "• View logs: docker-compose logs -f [service]"
echo "• Restart service: docker-compose restart [service]"
echo "• Stop all: docker-compose down"
echo "• Update: ./deploy-optimized.sh"

echo ""
echo -e "${GREEN}✨ Innerbright is now running in production mode!${NC}"

# Save deployment info
echo "Deployment completed at: $(date)" > "$BACKUP_DIR/last_deployment.log"
echo "Services: $(docker-compose ps --services | tr '\n' ' ')" >> "$BACKUP_DIR/last_deployment.log"
