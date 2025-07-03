#!/bin/bash

# 🧪 KataCore StartKit v1 - Test Suite
# Comprehensive testing for deployment system

set -e

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test functions
test_start() {
    ((TESTS_TOTAL++))
    echo -e "${BLUE}🧪 Testing: $1${NC}"
}

test_pass() {
    ((TESTS_PASSED++))
    echo -e "${GREEN}✅ PASS: $1${NC}"
}

test_fail() {
    ((TESTS_FAILED++))
    echo -e "${RED}❌ FAIL: $1${NC}"
}

test_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Test deployment script exists and is executable
test_deployment_script() {
    test_start "Deployment script availability"
    
    if [[ -f "deploy-startkitv1.sh" ]]; then
        test_pass "deploy-startkitv1.sh exists"
    else
        test_fail "deploy-startkitv1.sh not found"
        return 1
    fi
    
    if [[ -x "deploy-startkitv1.sh" ]]; then
        test_pass "deploy-startkitv1.sh is executable"
    else
        test_fail "deploy-startkitv1.sh is not executable"
    fi
}

# Test environment template
test_environment_template() {
    test_start "Environment template"
    
    if [[ -f ".env.startkitv1" ]]; then
        test_pass ".env.startkitv1 template exists"
    else
        test_fail ".env.startkitv1 template not found"
        return 1
    fi
    
    # Check for required placeholders
    local placeholders=(
        "__SECURE_POSTGRES_PASSWORD__"
        "__SECURE_REDIS_PASSWORD__" 
        "__SECURE_MINIO_PASSWORD__"
        "__SECURE_PGADMIN_PASSWORD__"
        "__SECURE_JWT_SECRET__"
    )
    
    for placeholder in "${placeholders[@]}"; do
        if grep -q "$placeholder" ".env.startkitv1"; then
            test_pass "Found placeholder: $placeholder"
        else
            test_fail "Missing placeholder: $placeholder"
        fi
    done
}

# Test Docker Compose configuration
test_docker_compose() {
    test_start "Docker Compose configuration"
    
    if [[ -f "docker-compose.startkitv1.yml" ]]; then
        test_pass "docker-compose.startkitv1.yml exists"
    else
        test_fail "docker-compose.startkitv1.yml not found"
        return 1
    fi
    
    # Check required services
    local services=("api" "site" "postgres" "redis" "minio" "pgadmin")
    
    for service in "${services[@]}"; do
        if grep -q "^[[:space:]]*${service}:" "docker-compose.startkitv1.yml"; then
            test_pass "Service defined: $service"
        else
            test_fail "Service missing: $service"
        fi
    done
}

# Test password generation
test_password_generation() {
    test_start "Password generation functionality"
    
    # Test OpenSSL availability
    if command -v openssl >/dev/null 2>&1; then
        test_pass "OpenSSL available for secure password generation"
        
        # Test password generation
        local test_password=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-24)
        if [[ ${#test_password} -eq 24 ]]; then
            test_pass "Password generation working (length: ${#test_password})"
        else
            test_fail "Password generation failed (length: ${#test_password})"
        fi
        
        # Test JWT secret generation
        local test_jwt=$(openssl rand -base64 64 | tr -d '\n')
        if [[ ${#test_jwt} -ge 64 ]]; then
            test_pass "JWT secret generation working (length: ${#test_jwt})"
        else
            test_fail "JWT secret generation failed (length: ${#test_jwt})"
        fi
    else
        test_info "OpenSSL not available, fallback methods will be used"
        
        # Test fallback method
        local charset="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local test_password=$(LC_ALL=C tr -dc "${charset}" < /dev/urandom | head -c16 2>/dev/null || echo "fallback_password_123")
        
        if [[ ${#test_password} -ge 10 ]]; then
            test_pass "Fallback password generation working"
        else
            test_fail "Fallback password generation failed"
        fi
    fi
}

# Test Docker availability
test_docker_availability() {
    test_start "Docker availability"
    
    if command -v docker >/dev/null 2>&1; then
        test_pass "Docker is installed"
        
        # Test Docker daemon
        if docker ps >/dev/null 2>&1; then
            test_pass "Docker daemon is running"
        else
            test_fail "Docker daemon is not running or accessible"
        fi
    else
        test_fail "Docker is not installed"
    fi
    
    if command -v docker-compose >/dev/null 2>&1; then
        test_pass "Docker Compose is installed"
    else
        test_info "Docker Compose not found (may use 'docker compose' instead)"
    fi
}

# Test Git availability
test_git_availability() {
    test_start "Git availability"
    
    if command -v git >/dev/null 2>&1; then
        test_pass "Git is installed"
        
        # Check if we're in a git repository
        if git rev-parse --git-dir >/dev/null 2>&1; then
            test_pass "Currently in a git repository"
            
            # Check git configuration
            if git config user.name >/dev/null 2>&1 && git config user.email >/dev/null 2>&1; then
                test_pass "Git user configuration is set"
            else
                test_info "Git user configuration not set (needed for autopush)"
            fi
        else
            test_info "Not in a git repository (autopush will be skipped)"
        fi
    else
        test_fail "Git is not installed"
    fi
}

# Test deployment script help
test_deployment_help() {
    test_start "Deployment script help functionality"
    
    if ./deploy-startkitv1.sh --help >/dev/null 2>&1; then
        test_pass "Help command works"
    else
        test_fail "Help command failed"
    fi
}

# Test dry run functionality
test_dry_run() {
    test_start "Dry run functionality"
    
    # Test dry run with required parameters
    if ./deploy-startkitv1.sh deploy --ip 127.0.0.1 --dry-run --verbose >/dev/null 2>&1; then
        test_pass "Dry run execution successful"
    else
        test_fail "Dry run execution failed"
    fi
}

# Test system requirements
test_system_requirements() {
    test_start "System requirements"
    
    # Check curl
    if command -v curl >/dev/null 2>&1; then
        test_pass "curl is available"
    else
        test_fail "curl is required but not installed"
    fi
    
    # Check essential tools
    local tools=("sed" "grep" "awk")
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            test_pass "$tool is available"
        else
            test_fail "$tool is required but not installed"
        fi
    done
}

# Main test execution
show_banner() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                 🧪 KataCore StartKit v1 - Test Suite                        ║
║                                                                              ║
║                    Comprehensive Deployment Testing                         ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

show_summary() {
    echo ""
    echo -e "${BLUE}📊 Test Summary:${NC}"
    echo -e "  Total Tests: $TESTS_TOTAL"
    echo -e "  ${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "  ${RED}Failed: $TESTS_FAILED${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed! System is ready for deployment.${NC}"
        echo ""
        echo -e "${BLUE}💡 Next Steps:${NC}"
        echo -e "  1. Simple deployment: ${YELLOW}./deploy-startkitv1.sh deploy --ip <YOUR_IP>${NC}"
        echo -e "  2. Full deployment: ${YELLOW}sudo ./deploy-startkitv1.sh full-deploy --domain <YOUR_DOMAIN>${NC}"
        echo -e "  3. With options: ${YELLOW}./deploy-startkitv1.sh deploy --ip <IP> --autopush --verbose${NC}"
    else
        echo -e "${RED}⚠️  Some tests failed. Please address the issues before deployment.${NC}"
        exit 1
    fi
}

# Run all tests
main() {
    show_banner
    
    test_deployment_script
    echo ""
    test_environment_template
    echo ""
    test_docker_compose
    echo ""
    test_password_generation
    echo ""
    test_docker_availability
    echo ""
    test_git_availability
    echo ""
    test_deployment_help
    echo ""
    test_dry_run
    echo ""
    test_system_requirements
    
    show_summary
}

main "$@"
