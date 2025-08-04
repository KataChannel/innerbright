#!/bin/bash

# Health Check and Monitoring Script for Innerbright
# This script monitors the health of all services and sends alerts if needed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.yml"
LOG_FILE="./logs/health-check.log"
ALERT_EMAIL="${ALERT_EMAIL:-admin@innerbright.vn}"

# Create logs directory
mkdir -p ./logs

echo -e "${BLUE}🏥 Innerbright Health Check - $(date)${NC}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[HEALTHY]${NC} $1"
    echo "$(date): [HEALTHY] $1" >> "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "$(date): [WARNING] $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "$(date): [ERROR] $1" >> "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "$(date): [INFO] $1" >> "$LOG_FILE"
}

# Service health checks
check_service_health() {
    local service=$1
    local expected_status="Up"
    
    if docker-compose ps $service | grep -q "$expected_status"; then
        print_status "$service is running"
        return 0
    else
        print_error "$service is not running or unhealthy"
        return 1
    fi
}

# Database connectivity check
check_database() {
    print_info "Checking database connectivity..."
    
    if docker-compose exec -T postgres pg_isready -U postgres -d innerbright_db > /dev/null 2>&1; then
        print_status "Database is accepting connections"
        
        # Check database size
        DB_SIZE=$(docker-compose exec -T postgres psql -U postgres -d innerbright_db -t -c "SELECT pg_size_pretty(pg_database_size('innerbright_db'));" | xargs)
        print_info "Database size: $DB_SIZE"
        
        return 0
    else
        print_error "Database is not accepting connections"
        return 1
    fi
}

# Redis connectivity check
check_redis() {
    print_info "Checking Redis connectivity..."
    
    if docker-compose exec -T redis redis-cli ping > /dev/null 2>&1; then
        print_status "Redis is responding"
        
        # Check Redis memory usage
        REDIS_MEMORY=$(docker-compose exec -T redis redis-cli info memory | grep used_memory_human | cut -d: -f2 | tr -d '\r')
        print_info "Redis memory usage: $REDIS_MEMORY"
        
        return 0
    else
        print_error "Redis is not responding"
        return 1
    fi
}

# MinIO connectivity check
check_minio() {
    print_info "Checking MinIO connectivity..."
    
    if curl -s -f http://localhost:9000/minio/health/live > /dev/null 2>&1; then
        print_status "MinIO is responding"
        return 0
    else
        print_error "MinIO is not responding"
        return 1
    fi
}

# Application health check
check_application() {
    print_info "Checking application health..."
    
    # Check health endpoint
    if curl -s -f -m 10 http://localhost:3000/health > /dev/null 2>&1; then
        print_status "Application health endpoint is responding"
    elif curl -s -f -m 10 http://localhost:3000/ > /dev/null 2>&1; then
        print_status "Application is responding (health endpoint may not be implemented)"
    else
        print_error "Application is not responding"
        return 1
    fi
    
    # Check response time
    RESPONSE_TIME=$(curl -s -w "%{time_total}" -o /dev/null http://localhost:3000/ || echo "0")
    print_info "Application response time: ${RESPONSE_TIME}s"
    
    if (( $(echo "$RESPONSE_TIME > 5" | bc -l) )); then
        print_warning "Application response time is slow (>5s)"
    fi
    
    return 0
}

# Nginx health check
check_nginx() {
    print_info "Checking Nginx health..."
    
    if docker-compose exec -T nginx nginx -t > /dev/null 2>&1; then
        print_status "Nginx configuration is valid"
    else
        print_error "Nginx configuration has errors"
        return 1
    fi
    
    # Check HTTP redirect
    if curl -s -I -m 5 http://localhost | grep -q "301\|302"; then
        print_status "HTTP to HTTPS redirect is working"
    else
        print_warning "HTTP to HTTPS redirect may not be working"
    fi
    
    return 0
}

# System resource check
check_system_resources() {
    print_info "Checking system resources..."
    
    # Check disk space
    DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 80 ]; then
        print_warning "Disk usage is high: ${DISK_USAGE}%"
    else
        print_status "Disk usage is normal: ${DISK_USAGE}%"
    fi
    
    # Check memory usage
    MEMORY_USAGE=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')
    if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
        print_warning "Memory usage is high: ${MEMORY_USAGE}%"
    else
        print_status "Memory usage is normal: ${MEMORY_USAGE}%"
    fi
    
    # Check load average
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    print_info "System load average: $LOAD_AVG"
}

# Docker resource check
check_docker_resources() {
    print_info "Checking Docker container resources..."
    
    # Check container CPU and memory usage
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" | while read line; do
        if [[ $line == *"%"* ]]; then
            print_info "$line"
        fi
    done
    
    # Check for any stopped containers
    STOPPED_CONTAINERS=$(docker-compose ps --filter "status=exited" --quiet)
    if [ -n "$STOPPED_CONTAINERS" ]; then
        print_warning "Found stopped containers"
        docker-compose ps --filter "status=exited"
    fi
}

# SSL certificate check
check_ssl_certificate() {
    print_info "Checking SSL certificate..."
    
    if [ -f "/etc/letsencrypt/live/innerbright.vn/fullchain.pem" ]; then
        # Check certificate expiry
        CERT_EXPIRY=$(openssl x509 -enddate -noout -in /etc/letsencrypt/live/innerbright.vn/fullchain.pem | cut -d= -f2)
        CERT_EXPIRY_EPOCH=$(date -d "$CERT_EXPIRY" +%s)
        CURRENT_EPOCH=$(date +%s)
        DAYS_UNTIL_EXPIRY=$(( (CERT_EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))
        
        if [ $DAYS_UNTIL_EXPIRY -gt 30 ]; then
            print_status "SSL certificate is valid (expires in $DAYS_UNTIL_EXPIRY days)"
        elif [ $DAYS_UNTIL_EXPIRY -gt 7 ]; then
            print_warning "SSL certificate expires soon ($DAYS_UNTIL_EXPIRY days)"
        else
            print_error "SSL certificate expires very soon ($DAYS_UNTIL_EXPIRY days)"
        fi
    else
        print_warning "SSL certificate not found"
    fi
}

# Run all health checks
run_health_checks() {
    local failed_checks=0
    
    print_info "=== Starting Health Checks ==="
    
    # Service checks
    check_service_health "postgres" || ((failed_checks++))
    check_service_health "redis" || ((failed_checks++))
    check_service_health "minio" || ((failed_checks++))
    check_service_health "site" || ((failed_checks++))
    check_service_health "nginx" || ((failed_checks++))
    
    # Connectivity checks
    check_database || ((failed_checks++))
    check_redis || ((failed_checks++))
    check_minio || ((failed_checks++))
    check_application || ((failed_checks++))
    check_nginx || ((failed_checks++))
    
    # System checks
    check_system_resources
    check_docker_resources
    check_ssl_certificate
    
    print_info "=== Health Check Summary ==="
    
    if [ $failed_checks -eq 0 ]; then
        print_status "All health checks passed! 🎉"
        return 0
    else
        print_error "$failed_checks health check(s) failed!"
        return 1
    fi
}

# Main execution
if run_health_checks; then
    echo -e "${GREEN}✅ System is healthy${NC}"
    exit 0
else
    echo -e "${RED}❌ System has issues that need attention${NC}"
    echo -e "${BLUE}Check the logs for details: $LOG_FILE${NC}"
    exit 1
fi
