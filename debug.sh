#!/bin/bash

# KataCore Debug Script
# Help debug common deployment issues

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
error() { echo -e "${RED}❌ $1${NC}"; }

# Function to check Docker status
check_docker_status() {
    log "🐳 Checking Docker status..."
    
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed"
        return 1
    fi
    
    if ! docker ps >/dev/null 2>&1; then
        error "Docker is not running or you don't have permission"
        return 1
    fi
    
    success "Docker is running"
    
    # Show Docker version
    docker --version
    docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo "Docker Compose not found"
}

# Function to check container status
check_containers() {
    log "📦 Checking container status..."
    echo ""
    
    # Check for any KataCore containers
    if docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -i katacore; then
        echo ""
        success "Found KataCore containers"
    else
        warning "No KataCore containers found"
    fi
}

# Function to check logs for failed containers
check_failed_logs() {
    log "📋 Checking logs for failed containers..."
    
    # Find failed containers
    local failed_containers=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | grep -i katacore || true)
    
    if [[ -n "$failed_containers" ]]; then
        for container in $failed_containers; do
            echo ""
            warning "Logs for failed container: $container"
            echo "----------------------------------------"
            docker logs "$container" --tail 20
            echo "----------------------------------------"
        done
    else
        success "No failed KataCore containers found"
    fi
}

# Function to check running containers health
check_container_health() {
    log "🏥 Checking container health..."
    
    # Check API container specifically
    if docker ps --format "{{.Names}}" | grep -q "katacore-api"; then
        local api_container=$(docker ps --format "{{.Names}}" | grep "katacore-api")
        echo ""
        info "API Container: $api_container"
        
        # Test health endpoint
        local container_ip=$(docker inspect "$api_container" --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null || echo "")
        if [[ -n "$container_ip" ]]; then
            info "Container IP: $container_ip"
            if curl -f -s "http://$container_ip:3001/health" >/dev/null 2>&1; then
                success "API health endpoint responding"
                curl -s "http://$container_ip:3001/health" | jq . 2>/dev/null || curl -s "http://$container_ip:3001/health"
            else
                warning "API health endpoint not responding"
            fi
        fi
        
        # Check if port is accessible from host
        if curl -f -s "http://localhost:3001/health" >/dev/null 2>&1; then
            success "API accessible from host"
        else
            warning "API not accessible from host on port 3001"
        fi
    else
        warning "No API container found running"
    fi
}

# Function to check environment files
check_environment() {
    log "🔧 Checking environment configuration..."
    
    if [[ -f ".env.prod" ]]; then
        success ".env.prod exists"
        
        # Check for placeholder values
        if grep -q "your_" .env.prod; then
            warning "Found placeholder values in .env.prod:"
            grep "your_" .env.prod | head -5
        else
            success "No obvious placeholder values found"
        fi
    else
        warning ".env.prod not found"
    fi
    
    if [[ -f ".env.local" ]]; then
        success ".env.local exists (for local testing)"
    else
        info ".env.local not found (optional for local testing)"
    fi
}

# Function to check network connectivity
check_network() {
    log "🌐 Checking network connectivity..."
    
    # Check if containers can reach each other
    local api_container=$(docker ps --format "{{.Names}}" | grep "katacore-api" | head -1)
    local postgres_container=$(docker ps --format "{{.Names}}" | grep "katacore-postgres" | head -1)
    
    if [[ -n "$api_container" && -n "$postgres_container" ]]; then
        info "Testing connectivity from API to PostgreSQL..."
        if docker exec "$api_container" sh -c "nc -z postgres 5432" 2>/dev/null; then
            success "API can reach PostgreSQL"
        else
            warning "API cannot reach PostgreSQL"
        fi
    fi
}

# Function to check system resources
check_resources() {
    log "💻 Checking system resources..."
    
    # Check disk space
    local disk_usage=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt 90 ]]; then
        warning "Disk usage is high: ${disk_usage}%"
    else
        success "Disk usage: ${disk_usage}%"
    fi
    
    # Check available memory
    if command -v free &> /dev/null; then
        local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
        info "Memory usage: ${mem_usage}%"
    fi
    
    # Check Docker resources
    docker system df
}

# Function to show quick fixes
show_quick_fixes() {
    echo ""
    info "🔧 Quick fixes for common issues:"
    echo ""
    echo "1. API container unhealthy:"
    echo "   - Check logs: docker logs katacore-api-prod"
    echo "   - Restart API: docker restart katacore-api-prod"
    echo "   - Rebuild API: docker compose up --build api"
    echo ""
    echo "2. Database connection issues:"
    echo "   - Check PostgreSQL: docker logs katacore-postgres-prod"
    echo "   - Reset database: docker compose down postgres && docker compose up postgres"
    echo ""
    echo "3. Environment issues:"
    echo "   - Validate env: bun run env:validate"
    echo "   - Recreate env: cp .env.local .env.prod"
    echo ""
    echo "4. Complete reset:"
    echo "   - Local: bun run deploy:local:clean"
    echo "   - Production: bun run deploy:universal:clean --host YOUR_IP"
    echo ""
}

# Main function
main() {
    log "🔍 KataCore Debug Tool Starting..."
    echo ""
    
    check_docker_status
    echo ""
    check_containers
    echo ""
    check_failed_logs
    echo ""
    check_container_health
    echo ""
    check_environment
    echo ""
    check_network
    echo ""
    check_resources
    
    show_quick_fixes
    
    success "Debug check completed! 🎉"
}

# Run main function
main "$@"
