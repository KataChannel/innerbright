#!/bin/bash

# Environment Variables Validation Script for KataCore
# Validates .env files for completeness and security

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
error() { echo -e "${RED}❌ $1${NC}"; }

log "🔍 Validating environment configuration..."

# Check if .env.prod exists
if [[ ! -f ".env.prod" ]]; then
    if [[ -f ".env.prod.example" ]]; then
        warning ".env.prod not found, but .env.prod.example exists"
        echo "   Run: cp .env.prod.example .env.prod"
        echo "   Then edit .env.prod with your actual values"
    else
        error ".env.prod and .env.prod.example not found"
        echo "   Run: bun run env:create-template"
    fi
    exit 1
fi

# Required variables for production
REQUIRED_VARS=(
    "POSTGRES_PASSWORD"
    "REDIS_PASSWORD"
    "JWT_SECRET"
    "MINIO_ROOT_PASSWORD"
    "PGADMIN_PASSWORD"
    "DOMAIN"
    "DATABASE_URL"
    "REDIS_URL"
    "NEXT_PUBLIC_API_URL"
)

# Check for required variables
MISSING_VARS=()
WEAK_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if ! grep -q "^${var}=" .env.prod; then
        MISSING_VARS+=("$var")
    else
        value=$(grep "^${var}=" .env.prod | cut -d'=' -f2-)
        
        # Check for placeholder values
        if [[ "$value" == *"your_"* ]] || [[ "$value" == *"yourdomain"* ]] || [[ "$value" == *"yourcompany"* ]]; then
            WEAK_VARS+=("$var")
        fi
        
        # Check password strength
        if [[ "$var" == *"PASSWORD"* ]] && [[ ${#value} -lt 12 ]]; then
            WEAK_VARS+=("$var (too short)")
        fi
    fi
done

# Report results
if [[ ${#MISSING_VARS[@]} -eq 0 && ${#WEAK_VARS[@]} -eq 0 ]]; then
    success "All environment variables are properly configured"
else
    if [[ ${#MISSING_VARS[@]} -gt 0 ]]; then
        error "Missing required variables:"
        for var in "${MISSING_VARS[@]}"; do
            echo "   - $var"
        done
    fi
    
    if [[ ${#WEAK_VARS[@]} -gt 0 ]]; then
        warning "Variables with placeholder or weak values:"
        for var in "${WEAK_VARS[@]}"; do
            echo "   - $var"
        done
    fi
    
    echo ""
    echo "💡 To fix these issues:"
    echo "   1. Copy values from .env.prod.example if needed"
    echo "   2. Generate secure passwords: openssl rand -hex 16"
    echo "   3. Update domain-specific values"
    echo "   4. Ensure JWT_SECRET is at least 32 characters"
    
    exit 1
fi

# Additional security checks
log "🔒 Performing security checks..."

# Check file permissions
PERM=$(stat -c "%a" .env.prod 2>/dev/null || stat -f "%OLp" .env.prod 2>/dev/null || echo "unknown")
if [[ "$PERM" != "600" && "$PERM" != "644" ]]; then
    warning ".env.prod has permissive permissions ($PERM)"
    echo "   Consider: chmod 600 .env.prod"
fi

# Check for common issues
if grep -q "localhost" .env.prod; then
    warning "Found 'localhost' in .env.prod - may cause issues in containerized environment"
fi

if grep -q "127.0.0.1" .env.prod; then
    warning "Found '127.0.0.1' in .env.prod - may cause issues in containerized environment"
fi

success "Environment validation completed"
