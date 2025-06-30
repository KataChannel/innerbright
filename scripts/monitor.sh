#!/bin/bash

# KataCore Production Monitoring Script
# Monitors all services and sends alerts if needed

set -e

# Setup Bun PATH
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bun-setup.sh"

if ! setup_bun_for_session; then
    exit 1
fi

# Configuration
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="/tmp/katacore-monitor.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

# Health check functions
check_service_endpoint() {
    local service_name=$1
    local url=$2
    local timeout=${3:-10}
    
    if curl -f -s --max-time "$timeout" "$url" > /dev/null 2>&1; then
        success "Service $service_name endpoint ($url) is responding"
        return 0
    else
        error "Service $service_name endpoint ($url) is not responding"
        return 1
    fi
}

# Main monitoring function
run_health_checks() {
    log "🏥 Starting KataCore health checks..."
    
    local failed_checks=0
    
    # Navigate to project directory
    cd "$PROJECT_DIR"
    
    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Run 'bun run docker:install' to install Docker."
        return 1
    fi
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        error "Docker is not running. Please start Docker first."
        return 1
    fi
    
    # Check if docker-compose is running
    if ! docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        error "No services are running"
        return 1
    fi
    
    # Container health checks
    log "🐳 Checking container health..."
    containers=("katacore-postgres-prod" "katacore-redis-prod" "katacore-minio-prod" "katacore-api-prod" "katacore-site-prod" "katacore-nginx-prod")
    
    for container in "${containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "$container"; then
            success "Container $container is running"
        else
            error "Container $container is not running"
            ((failed_checks++))
        fi
    done
    
    # Service endpoint checks
    log "🌐 Checking service endpoints..."
    
    # Check API  
    if check_service_endpoint "API" "http://localhost:3001/health" 10; then
        success "API health check passed"
    else
        ((failed_checks++))
    fi
    
    # Check Frontend
    if check_service_endpoint "Frontend" "http://localhost:3000" 10; then
        success "Frontend health check passed"
    else
        ((failed_checks++))
    fi
    
    # Log summary
    if [ "$failed_checks" -eq 0 ]; then
        success "All health checks passed! 🎉"
        return 0
    else
        error "$failed_checks health check(s) failed"
        return 1
    fi
}

# Show service status
show_status() {
    cd "$PROJECT_DIR"
    
    log "📊 Service Status:"
    docker-compose -f docker-compose.prod.yml ps
    
    echo ""
    log "💾 Docker Stats:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" 2>/dev/null || echo "No running containers"
    
    echo ""
    log "📈 System Resources:"
    echo "Memory Usage: $(free | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
    echo "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"
}

# Show usage information
show_usage() {
    echo "KataCore Production Monitoring Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --check               Run health checks only"
    echo "  --status              Show service status and stats"
    echo "  --logs [service]      Show logs for service (default: all)"
    echo "  --restart [service]   Restart specific service or all"
    echo "  --help                Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --check"
    echo "  $0 --status"
    echo "  $0 --logs api"
    echo "  $0 --restart nginx"
}

# Main execution
case "${1:---check}" in
    "--check")
        if run_health_checks; then
            exit 0
        else
            exit 1
        fi
        ;;
    "--status")
        show_status
        ;;
    "--logs")
        cd "$PROJECT_DIR"
        if [ -n "$2" ]; then
            docker-compose -f docker-compose.prod.yml logs -f "$2"
        else
            docker-compose -f docker-compose.prod.yml logs -f
        fi
        ;;
    "--restart")
        cd "$PROJECT_DIR"
        if [ -n "$2" ]; then
            log "🔄 Restarting service: $2"
            docker-compose -f docker-compose.prod.yml restart "$2"
        else
            log "🔄 Restarting all services..."
            docker-compose -f docker-compose.prod.yml restart
        fi
        success "Restart completed"
        ;;
    "--help"|"-h")
        show_usage
        ;;
    *)
        echo "Unknown option: $1"
        show_usage
        exit 1
        ;;
esac
