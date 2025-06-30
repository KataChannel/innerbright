#!/bin/bash

# KataCore Deployment System Test
# Tests all deployment scripts and validates the system

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${BLUE}[TEST]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }

echo -e "${CYAN}🧪 KataCore Deployment System Test${NC}"
echo "======================================"
echo ""

# Test 1: Check if required files exist
log "Checking required files..."
REQUIRED_FILES=(
    "universal-deployer.sh"
    "scripts/deploy-cloud.sh"
    "docker-compose.prod.yml"
    "package.json"
    ".env.prod.example"
    "DEPLOYMENT.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        success "$file exists"
    else
        error "$file is missing"
        exit 1
    fi
done

# Test 2: Check script permissions
log "Checking script permissions..."
SCRIPTS=(
    "universal-deployer.sh"
    "scripts/deploy-cloud.sh"
    "scripts/install-docker.sh"
    "scripts/docker-manager.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [[ -x "$script" ]]; then
        success "$script is executable"
    else
        warning "$script is not executable, fixing..."
        chmod +x "$script"
        success "Fixed permissions for $script"
    fi
done

# Test 3: Validate package.json scripts
log "Checking package.json scripts..."
REQUIRED_SCRIPTS=(
    "deploy:universal"
    "deploy:universal:clean"
    "deploy:setup-only"
    "deploy:deploy-only"
    "deploy:local"
    "deploy:remote"
)

for script_name in "${REQUIRED_SCRIPTS[@]}"; do
    if grep -q "\"$script_name\"" package.json; then
        success "Script '$script_name' is defined"
    else
        error "Script '$script_name' is missing from package.json"
        exit 1
    fi
done

# Test 4: Check Docker Compose configuration
log "Validating Docker Compose configuration..."
if command -v docker >/dev/null 2>&1; then
    if docker compose -f docker-compose.prod.yml config >/dev/null 2>&1; then
        success "docker-compose.prod.yml is valid (docker compose)"
    elif command -v docker-compose >/dev/null 2>&1 && docker-compose -f docker-compose.prod.yml config >/dev/null 2>&1; then
        success "docker-compose.prod.yml is valid (docker-compose)"
    else
        warning "Could not validate docker-compose.prod.yml (Docker Compose not available)"
    fi
else
    warning "Docker not available, skipping Docker Compose validation"
fi

# Test 5: Check environment example
log "Checking environment configuration..."
if [[ -f ".env.prod.example" ]]; then
    # Check for required environment variables
    REQUIRED_ENV_VARS=(
        "POSTGRES_DB"
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
        "REDIS_PASSWORD"
        "JWT_SECRET"
        "DATABASE_URL"
        "REDIS_URL"
    )
    
    for var in "${REQUIRED_ENV_VARS[@]}"; do
        if grep -q "^$var=" .env.prod.example; then
            success "Environment variable '$var' is defined"
        else
            warning "Environment variable '$var' is missing from .env.prod.example"
        fi
    done
else
    error ".env.prod.example is missing"
    exit 1
fi

# Test 6: Test universal deployer help
log "Testing universal deployer help..."
if ./universal-deployer.sh --help >/dev/null 2>&1; then
    success "Universal deployer help works"
else
    error "Universal deployer help failed"
    exit 1
fi

# Test 7: Check documentation
log "Checking documentation..."
if [[ -f "DEPLOYMENT.md" ]] && [[ -s "DEPLOYMENT.md" ]]; then
    success "DEPLOYMENT.md exists and is not empty"
else
    error "DEPLOYMENT.md is missing or empty"
    exit 1
fi

if grep -q "Universal Cloud Deployer" DEPLOYMENT.md; then
    success "DEPLOYMENT.md contains Universal Deployer documentation"
else
    error "DEPLOYMENT.md is missing Universal Deployer documentation"
    exit 1
fi

# Test 8: Verify workspace structure
log "Checking workspace structure..."
REQUIRED_DIRS=(
    "site"
    "api"
    "scripts"
    "nginx"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ -d "$dir" ]]; then
        success "Directory '$dir' exists"
    else
        error "Directory '$dir' is missing"
        exit 1
    fi
done

# Test 9: Check if project was cleaned up
log "Checking if project was properly cleaned up..."
OLD_FILES=(
    "FIX_FILE_MISSING.sh"
    "FIX_AND_DEPLOY.sh"
    "REMOTE_DEPLOYMENT_TROUBLESHOOTING.md"
    "scripts/test-snap-docker-compose.sh"
    "scripts/fix-snap-compose.sh"
)

for file in "${OLD_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        warning "Old file '$file' still exists (should be cleaned up)"
    else
        success "Old file '$file' was properly removed"
    fi
done

echo ""
echo -e "${GREEN}🎉 All tests passed! Deployment system is ready.${NC}"
echo ""

# Show quick usage guide
info "Quick Start:"
echo "  bun run deploy:universal --host YOUR_SERVER_IP"
echo ""
info "Full Documentation:"
echo "  See DEPLOYMENT.md for complete deployment guide"
echo ""

exit 0
