#!/bin/bash

# Test script for KataCore deployment functionality
# This script tests the password generation and environment setup

set -e

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test functions
test_password_generation() {
    echo -e "${BLUE}Testing password generation...${NC}"
    
    # Test OpenSSL availability
    if command -v openssl >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OpenSSL available${NC}"
        
        # Test password generation
        local test_password=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-24)
        if [[ ${#test_password} -eq 24 ]]; then
            echo -e "${GREEN}✅ Password generation working (length: ${#test_password})${NC}"
        else
            echo -e "${RED}❌ Password generation failed (length: ${#test_password})${NC}"
        fi
        
        # Test JWT secret generation
        local test_jwt=$(openssl rand -base64 64 | tr -d '\n')
        if [[ ${#test_jwt} -ge 64 ]]; then
            echo -e "${GREEN}✅ JWT secret generation working (length: ${#test_jwt})${NC}"
        else
            echo -e "${RED}❌ JWT secret generation failed (length: ${#test_jwt})${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  OpenSSL not available, fallback methods will be used${NC}"
    fi
}

test_environment_setup() {
    echo -e "${BLUE}Testing environment setup...${NC}"
    
    # Check if .env.example exists
    if [[ -f ".env.example" ]]; then
        echo -e "${GREEN}✅ .env.example file exists${NC}"
        
        # Check for placeholders
        local placeholders=$(grep -o "__SECURE_[^_]*__" .env.example 2>/dev/null | sort -u || true)
        if [[ -n "$placeholders" ]]; then
            echo -e "${GREEN}✅ Found placeholders to replace:${NC}"
            echo "$placeholders" | sed 's/^/    /'
        else
            echo -e "${YELLOW}⚠️  No placeholders found in .env.example${NC}"
        fi
    else
        echo -e "${RED}❌ .env.example file not found${NC}"
    fi
}

test_docker_availability() {
    echo -e "${BLUE}Testing Docker availability...${NC}"
    
    if command -v docker >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker available${NC}"
        
        if docker info >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Docker daemon running${NC}"
        else
            echo -e "${RED}❌ Docker daemon not running${NC}"
        fi
    else
        echo -e "${RED}❌ Docker not available${NC}"
    fi
    
    if command -v docker-compose >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker Compose available${NC}"
    else
        echo -e "${RED}❌ Docker Compose not available${NC}"
    fi
}

test_git_availability() {
    echo -e "${BLUE}Testing Git availability...${NC}"
    
    if command -v git >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Git available${NC}"
        
        # Check if this is a git repository
        if [[ -d ".git" ]]; then
            echo -e "${GREEN}✅ Git repository detected${NC}"
            
            # Check git configuration
            local git_user=$(git config user.name 2>/dev/null || echo "")
            local git_email=$(git config user.email 2>/dev/null || echo "")
            
            if [[ -n "$git_user" ]] && [[ -n "$git_email" ]]; then
                echo -e "${GREEN}✅ Git user configured: $git_user <$git_email>${NC}"
            else
                echo -e "${YELLOW}⚠️  Git user not configured${NC}"
            fi
            
            # Check for remote
            if git remote -v | grep -q "origin"; then
                echo -e "${GREEN}✅ Remote origin configured${NC}"
            else
                echo -e "${YELLOW}⚠️  No remote origin configured${NC}"
            fi
        else
            echo -e "${YELLOW}⚠️  Not a git repository${NC}"
        fi
    else
        echo -e "${RED}❌ Git not available${NC}"
    fi
}

test_deployment_script() {
    echo -e "${BLUE}Testing deployment script...${NC}"
    
    if [[ -f "deploy-simple.sh" ]]; then
        echo -e "${GREEN}✅ deploy-simple.sh exists${NC}"
        
        if [[ -x "deploy-simple.sh" ]]; then
            echo -e "${GREEN}✅ deploy-simple.sh is executable${NC}"
        else
            echo -e "${YELLOW}⚠️  deploy-simple.sh not executable (run: chmod +x deploy-simple.sh)${NC}"
        fi
        
        # Test dry run
        echo -e "${BLUE}Testing dry run...${NC}"
        if ./deploy-simple.sh --dry-run --verbose >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Dry run completed successfully${NC}"
        else
            echo -e "${RED}❌ Dry run failed${NC}"
        fi
    else
        echo -e "${RED}❌ deploy-simple.sh not found${NC}"
    fi
}

# Main execution
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🧪 KataCore Deployment Test Suite                       ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    test_password_generation
    echo ""
    test_environment_setup
    echo ""
    test_docker_availability
    echo ""
    test_git_availability
    echo ""
    test_deployment_script
    echo ""
    
    echo -e "${GREEN}🎉 Test suite completed!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. Run: ${YELLOW}./deploy-simple.sh --dry-run${NC} to preview deployment"
    echo -e "  2. Run: ${YELLOW}./deploy-simple.sh${NC} to deploy with auto-generated passwords"
    echo -e "  3. Run: ${YELLOW}./deploy-simple.sh --autopush${NC} to deploy with git autopush"
    echo ""
}

main "$@"
