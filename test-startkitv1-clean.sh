#!/bin/bash

# 🧪 KataCore StartKit v1 Clean - Test Deployment
# Comprehensive testing script for deployment validation

set -euo pipefail

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Configuration
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ENV_FILE="$PROJECT_ROOT/.env"
readonly COMPOSE_FILE="$PROJECT_ROOT/docker-compose.startkitv1-clean.yml"

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Logging functions
log() { echo -e "${GREEN}[$(date +'%H:%M:%S')]${NC} $1"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
test_pass() { echo -e "${GREEN}✅ TEST PASSED:${NC} $1"; ((PASSED_TESTS++)); }
test_fail() { echo -e "${RED}❌ TEST FAILED:${NC} $1"; ((FAILED_TESTS++)); }

# Test helper functions
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TOTAL_TESTS++))
    
    if eval "$test_command" > /dev/null 2>&1; then
        test_pass "$test_name"
        return 0
    else
        test_fail "$test_name"
        return 1
    fi
}

# Show banner
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                🧪 KataCore StartKit v1 Clean - Test Suite                   ║
║                                                                              ║
║           Comprehensive validation of deployment and services                ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Test file existence
test_files() {
    log "📁 Testing file existence..."
    
    local required_files=(
        "$ENV_FILE"
        "$COMPOSE_FILE"
        "$PROJECT_ROOT/deploy-startkitv1-clean.sh"
        "$PROJECT_ROOT/api/package.json"
        "$PROJECT_ROOT/site/package.json"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            test_pass "File exists: $(basename "$file")"
        else
            test_fail "File missing: $(basename "$file")"
        fi
        ((TOTAL_TESTS++))
    done
}

# Test environment variables
test_environment() {
    log "🔐 Testing environment variables..."
    
    if [[ ! -f "$ENV_FILE" ]]; then
        test_fail "Environment file not found"
        return 1
    fi
    
    # Source environment file
    source "$ENV_FILE"
    
    # Required variables
    local required_vars=(
        "NODE_ENV"
        "DATABASE_URL"
        "REDIS_URL"
        "JWT_SECRET"
        "POSTGRES_PASSWORD"
        "MINIO_ROOT_PASSWORD"
    )
    
    for var in "${required_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            test_pass "Environment variable set: $var"
        else
            test_fail "Environment variable missing: $var"
        fi
        ((TOTAL_TESTS++))
    done
    
    # Test password strength
    local password_vars=("POSTGRES_PASSWORD" "REDIS_PASSWORD" "JWT_SECRET" "MINIO_ROOT_PASSWORD")
    
    for var in "${password_vars[@]}"; do
        local password="${!var:-}"
        if [[ ${#password} -ge 16 ]]; then
            test_pass "Password strength OK: $var (${#password} chars)"
        else
            test_fail "Password too weak: $var (${#password} chars)"
        fi
        ((TOTAL_TESTS++))
    done
}

# Test Docker services
test_docker_services() {
    log "🐳 Testing Docker services..."
    
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        test_fail "Docker daemon not running"
        return 1
    fi
    
    test_pass "Docker daemon running"
    ((TOTAL_TESTS++))
    
    # Check if Docker Compose file is valid
    if docker-compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
        test_pass "Docker Compose file valid"
    else
        test_fail "Docker Compose file invalid"
    fi
    ((TOTAL_TESTS++))
    
    # Check if services are running
    local services=("katacore-api" "katacore-site" "katacore-postgres" "katacore-redis" "katacore-minio" "katacore-pgadmin")
    
    for service in "${services[@]}"; do
        if docker ps --filter "name=$service" --filter "status=running" | grep -q "$service"; then
            test_pass "Service running: $service"
        else
            test_fail "Service not running: $service"
        fi
        ((TOTAL_TESTS++))
    done
}

# Test service health
test_service_health() {
    log "🏥 Testing service health..."
    
    # Wait for services to be ready
    info "Waiting for services to initialize..."
    sleep 10
    
    # Test service endpoints
    local endpoints=(
        "localhost:3000"
        "localhost:3001"
        "localhost:9000"
        "localhost:5050"
    )
    
    for endpoint in "${endpoints[@]}"; do
        if curl -sf "http://$endpoint" > /dev/null 2>&1; then
            test_pass "Service health OK: $endpoint"
        else
            test_fail "Service health FAIL: $endpoint"
        fi
        ((TOTAL_TESTS++))
    done
}

# Test database connections
test_database_connections() {
    log "🗄️  Testing database connections..."
    
    # Source environment
    source "$ENV_FILE"
    
    # Test PostgreSQL
    if docker-compose -f "$COMPOSE_FILE" exec -T postgres pg_isready -U "$POSTGRES_USER" -d "$POSTGRES_DB" > /dev/null 2>&1; then
        test_pass "PostgreSQL connection OK"
    else
        test_fail "PostgreSQL connection FAIL"
    fi
    ((TOTAL_TESTS++))
    
    # Test Redis
    if docker-compose -f "$COMPOSE_FILE" exec -T redis redis-cli ping | grep -q "PONG"; then
        test_pass "Redis connection OK"
    else
        test_fail "Redis connection FAIL"
    fi
    ((TOTAL_TESTS++))
}

# Test API endpoints
test_api_endpoints() {
    log "🚀 Testing API endpoints..."
    
    # Basic health check
    if curl -sf "http://localhost:3001/health" > /dev/null 2>&1; then
        test_pass "API health endpoint OK"
    else
        test_fail "API health endpoint FAIL"
    fi
    ((TOTAL_TESTS++))
    
    # Test API response
    local response=$(curl -s "http://localhost:3001/health" 2>/dev/null || echo "")
    if [[ -n "$response" ]]; then
        test_pass "API returns response"
    else
        test_fail "API no response"
    fi
    ((TOTAL_TESTS++))
}

# Test frontend access
test_frontend_access() {
    log "🌐 Testing frontend access..."
    
    # Test site accessibility
    if curl -sf "http://localhost:3000" > /dev/null 2>&1; then
        test_pass "Frontend accessible"
    else
        test_fail "Frontend not accessible"
    fi
    ((TOTAL_TESTS++))
    
    # Test if site returns HTML
    local response=$(curl -s "http://localhost:3000" 2>/dev/null || echo "")
    if [[ "$response" == *"<html"* ]] || [[ "$response" == *"<HTML"* ]]; then
        test_pass "Frontend returns HTML"
    else
        test_fail "Frontend doesn't return HTML"
    fi
    ((TOTAL_TESTS++))
}

# Test MinIO functionality
test_minio_functionality() {
    log "📦 Testing MinIO functionality..."
    
    # Test MinIO health
    if curl -sf "http://localhost:9000/minio/health/live" > /dev/null 2>&1; then
        test_pass "MinIO health OK"
    else
        test_fail "MinIO health FAIL"
    fi
    ((TOTAL_TESTS++))
    
    # Test MinIO console
    if curl -sf "http://localhost:9001" > /dev/null 2>&1; then
        test_pass "MinIO console accessible"
    else
        test_fail "MinIO console not accessible"
    fi
    ((TOTAL_TESTS++))
}

# Test pgAdmin functionality
test_pgadmin_functionality() {
    log "🔍 Testing pgAdmin functionality..."
    
    # Test pgAdmin health
    if curl -sf "http://localhost:5050/misc/ping" > /dev/null 2>&1; then
        test_pass "pgAdmin health OK"
    else
        test_fail "pgAdmin health FAIL"
    fi
    ((TOTAL_TESTS++))
    
    # Test pgAdmin accessibility
    if curl -sf "http://localhost:5050" > /dev/null 2>&1; then
        test_pass "pgAdmin accessible"
    else
        test_fail "pgAdmin not accessible"
    fi
    ((TOTAL_TESTS++))
}

# Test network connectivity
test_network_connectivity() {
    log "🌐 Testing network connectivity..."
    
    # Test if services can communicate
    if docker-compose -f "$COMPOSE_FILE" exec -T api curl -sf "http://postgres:5432" > /dev/null 2>&1; then
        test_pass "API can reach PostgreSQL"
    else
        test_fail "API cannot reach PostgreSQL"
    fi
    ((TOTAL_TESTS++))
    
    if docker-compose -f "$COMPOSE_FILE" exec -T api curl -sf "http://redis:6379" > /dev/null 2>&1; then
        test_pass "API can reach Redis"
    else
        test_fail "API cannot reach Redis"
    fi
    ((TOTAL_TESTS++))
}

# Test security configuration
test_security_config() {
    log "🔒 Testing security configuration..."
    
    # Source environment
    source "$ENV_FILE"
    
    # Test CORS configuration
    if [[ -n "${CORS_ORIGIN:-}" ]]; then
        test_pass "CORS origin configured"
    else
        test_fail "CORS origin not configured"
    fi
    ((TOTAL_TESTS++))
    
    # Test JWT secret
    if [[ ${#JWT_SECRET} -ge 32 ]]; then
        test_pass "JWT secret strength OK"
    else
        test_fail "JWT secret too weak"
    fi
    ((TOTAL_TESTS++))
    
    # Test encryption key
    if [[ ${#ENCRYPTION_KEY} -ge 32 ]]; then
        test_pass "Encryption key strength OK"
    else
        test_fail "Encryption key too weak"
    fi
    ((TOTAL_TESTS++))
}

# Test deployment configuration
test_deployment_config() {
    log "⚙️  Testing deployment configuration..."
    
    # Source environment
    source "$ENV_FILE"
    
    # Test production mode
    if [[ "$NODE_ENV" == "production" ]]; then
        test_pass "Production mode enabled"
    else
        test_fail "Not in production mode"
    fi
    ((TOTAL_TESTS++))
    
    # Test restart policy
    if [[ "${RESTART_POLICY:-}" == "unless-stopped" ]]; then
        test_pass "Restart policy configured"
    else
        test_fail "Restart policy not configured"
    fi
    ((TOTAL_TESTS++))
}

# Performance tests
test_performance() {
    log "⚡ Testing performance..."
    
    # Test API response time
    local response_time=$(curl -o /dev/null -s -w '%{time_total}' "http://localhost:3001/health" 2>/dev/null || echo "999")
    if (( $(echo "$response_time < 2.0" | bc -l) )); then
        test_pass "API response time OK (${response_time}s)"
    else
        test_fail "API response time slow (${response_time}s)"
    fi
    ((TOTAL_TESTS++))
    
    # Test frontend response time
    local frontend_time=$(curl -o /dev/null -s -w '%{time_total}' "http://localhost:3000" 2>/dev/null || echo "999")
    if (( $(echo "$frontend_time < 3.0" | bc -l) )); then
        test_pass "Frontend response time OK (${frontend_time}s)"
    else
        test_fail "Frontend response time slow (${frontend_time}s)"
    fi
    ((TOTAL_TESTS++))
}

# Show test summary
show_test_summary() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                              TEST SUMMARY                                   ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}📊 Test Results:${NC}"
    echo -e "   Total Tests: $TOTAL_TESTS"
    echo -e "   ${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "   ${RED}Failed: $FAILED_TESTS${NC}"
    echo ""
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "${CYAN}Success Rate: ${success_rate}%${NC}"
    echo ""
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}🎉 ALL TESTS PASSED! Deployment is healthy.${NC}"
    else
        echo -e "${RED}❌ Some tests failed. Check the deployment.${NC}"
    fi
    echo ""
}

# Main test function
main() {
    show_banner
    
    # Check if deployment exists
    if [[ ! -f "$ENV_FILE" ]]; then
        error "No deployment found. Run deployment first."
        exit 1
    fi
    
    # Run test suites
    test_files
    test_environment
    test_docker_services
    test_service_health
    test_database_connections
    test_api_endpoints
    test_frontend_access
    test_minio_functionality
    test_pgadmin_functionality
    test_network_connectivity
    test_security_config
    test_deployment_config
    test_performance
    
    # Show summary
    show_test_summary
    
    # Exit with appropriate code
    if [[ $FAILED_TESTS -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"
