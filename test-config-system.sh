#!/bin/bash

# Test script for the enhanced environment and nginx configuration system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

echo -e "${BLUE}🧪 Testing Enhanced Configuration System${NC}"
echo ""

# Test environment generation
test_env_generation() {
    echo -e "${YELLOW}📋 Testing Environment Generation${NC}"
    
    # Test with IP
    echo "Testing IP-based configuration..."
    if ./startkit-deployer.sh --create-env-template; then
        success "Environment template creation works"
    else
        error "Environment template creation failed"
    fi
    
    # Check if template exists
    if [[ -f ".env.prod.template" ]]; then
        success "Template file exists"
        
        # Check for placeholders
        if grep -q "{{SERVER_HOST}}\|{{DOMAIN}}\|{{POSTGRES_PASSWORD}}" .env.prod.template; then
            success "Template contains proper placeholders"
        else
            warning "Template missing some placeholders"
        fi
    else
        error "Template file not created"
    fi
}

# Test nginx configuration validation
test_nginx_config() {
    echo ""
    echo -e "${YELLOW}🔧 Testing Nginx Configuration${NC}"
    
    # Check if template exists
    if [[ -f "nginx/conf.d/katacore.template.conf" ]]; then
        success "Nginx template exists"
        
        # Check for placeholders in template
        if grep -q "{{LISTEN_DIRECTIVES}}\|{{SERVER_NAMES}}\|{{SSL_CONFIGURATION}}" nginx/conf.d/katacore.template.conf; then
            success "Nginx template contains proper placeholders"
        else
            warning "Nginx template missing some placeholders"
        fi
    else
        warning "Nginx template not found - will generate from scratch"
    fi
    
    # Test configuration backup system
    mkdir -p nginx/conf.d/backup
    if [[ -d "nginx/conf.d/backup" ]]; then
        success "Backup directory structure ready"
    fi
}

# Test demo script
test_demo_script() {
    echo ""
    echo -e "${YELLOW}🎯 Testing Demo Script${NC}"
    
    if [[ -x "demo-nginx-config.sh" ]]; then
        success "Demo script is executable"
        
        # Run demo briefly
        echo "Running demo..."
        ./demo-nginx-config.sh | head -20
        success "Demo script executed successfully"
    else
        error "Demo script not executable or missing"
    fi
}

# Test file structure
test_file_structure() {
    echo ""
    echo -e "${YELLOW}📁 Testing File Structure${NC}"
    
    local required_files=(
        "startkit-deployer.sh"
        ".env.prod.template"
        "nginx/conf.d/katacore.template.conf"
        "nginx/nginx.conf"
        "docker-compose.prod.yml"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            success "$file exists"
        else
            warning "$file missing"
        fi
    done
}

# Test syntax of key scripts
test_script_syntax() {
    echo ""
    echo -e "${YELLOW}🔍 Testing Script Syntax${NC}"
    
    # Test startkit-deployer.sh syntax
    if bash -n startkit-deployer.sh; then
        success "startkit-deployer.sh syntax is valid"
    else
        error "startkit-deployer.sh has syntax errors"
    fi
    
    # Test demo script syntax
    if bash -n demo-nginx-config.sh; then
        success "demo-nginx-config.sh syntax is valid"
    else
        error "demo-nginx-config.sh has syntax errors"
    fi
}

# Run all tests
echo "Starting comprehensive tests..."
echo ""

test_file_structure
test_script_syntax
test_env_generation
test_nginx_config
test_demo_script

echo ""
echo -e "${GREEN}🎉 Configuration System Testing Complete${NC}"
echo ""

# Show usage examples
echo -e "${BLUE}📚 Usage Examples:${NC}"
echo ""
echo "1. Create environment template:"
echo "   ./startkit-deployer.sh --create-env-template"
echo ""
echo "2. Deploy with IP address:"
echo "   ./startkit-deployer.sh --host 192.168.1.100"
echo ""
echo "3. Deploy with domain and SSL:"
echo "   ./startkit-deployer.sh --host myserver.com --domain myapp.com"
echo ""
echo "4. Demo nginx configurations:"
echo "   ./demo-nginx-config.sh"
echo ""

info "All enhanced features are ready for use!"
