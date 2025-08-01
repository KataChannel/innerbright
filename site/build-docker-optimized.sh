#!/bin/bash

# =============================================================================
# Optimized Build Script for Docker Deployment
# Memory and CPU optimized for cloud servers
# =============================================================================

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Configuration
MEMORY_LIMIT=${MEMORY_LIMIT:-2048}
CPU_CORES=${CPU_CORES:-2}
SKIP_ANALYZE=${SKIP_ANALYZE:-true}

echo -e "${BLUE}🐳 Docker-Optimized Build Process${NC}"

# Pre-build cleanup
echo -e "${YELLOW}🧹 Pre-build cleanup...${NC}"
rm -rf .next .swc node_modules/.cache dist

# Install dependencies with optimizations
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
if command -v bun >/dev/null 2>&1; then
    # Use Bun for faster installs
    bun install --frozen-lockfile --no-save
else
    # Optimize npm for Docker builds
    npm ci --only=production --no-audit --no-fund
fi

# Generate Prisma client
if [ -f "prisma/schema.prisma" ]; then
    echo -e "${YELLOW}🗄️  Generating Prisma client...${NC}"
    if command -v bun >/dev/null 2>&1; then
        bunx prisma generate
    else
        npx prisma generate
    fi
fi

# Build with Docker-specific optimizations
echo -e "${YELLOW}🏗️  Building for Docker deployment...${NC}"

export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export DISABLE_PWA_BUILD=true
export DOCKER_BUILD=true
export SKIP_ENV_VALIDATION=true
export NODE_OPTIONS="--max-old-space-size=${MEMORY_LIMIT}"

# Additional Docker optimizations
export NEXT_OPTIMIZE_FONTS=false
export NEXT_OPTIMIZE_IMAGES=false
export NEXT_SHARP=false
export NEXT_BUNDLE_ANALYZE=${SKIP_ANALYZE}

# Build the application
if command -v bun >/dev/null 2>&1; then
    bun run build:docker-safe
else
    npm run build:docker-safe
fi

# Post-build optimization
echo -e "${YELLOW}⚡ Post-build optimization...${NC}"

# Remove development artifacts from standalone
if [ -d ".next/standalone" ]; then
    cd .next/standalone
    
    # Remove source maps and type definitions
    find . -name "*.map" -delete 2>/dev/null || true
    find . -name "*.d.ts" -delete 2>/dev/null || true
    
    # Remove test files
    find . -name "*.test.*" -delete 2>/dev/null || true
    find . -name "*.spec.*" -delete 2>/dev/null || true
    find . -type d -name "__tests__" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name "test" -exec rm -rf {} + 2>/dev/null || true
    
    # Remove documentation and examples
    find . -name "README*" -delete 2>/dev/null || true
    find . -name "CHANGELOG*" -delete 2>/dev/null || true
    find . -name "*.md" -delete 2>/dev/null || true
    find . -type d -name "examples" -exec rm -rf {} + 2>/dev/null || true
    find . -type d -name "docs" -exec rm -rf {} + 2>/dev/null || true
    
    # Remove development dependencies
    find . -name ".eslintrc*" -delete 2>/dev/null || true
    find . -name "tsconfig*" -delete 2>/dev/null || true
    find . -name "*.config.*" -delete 2>/dev/null || true
    
    cd ../..
fi

# Optimize static assets
if [ -d ".next/static" ]; then
    echo -e "${YELLOW}🎨 Optimizing static assets...${NC}"
    
    # Remove source maps from static files
    find .next/static -name "*.map" -delete 2>/dev/null || true
fi

echo -e "${GREEN}✅ Docker build optimization completed!${NC}"
echo -e "${BLUE}📊 Final build sizes:${NC}"
echo "Standalone: $(du -sh .next/standalone 2>/dev/null | cut -f1)"
echo "Static: $(du -sh .next/static 2>/dev/null | cut -f1)"
echo "Total: $(du -sh .next 2>/dev/null | cut -f1)"

# Create Docker build
echo -e "${YELLOW}🐳 Building Docker image...${NC}"
docker build -t innerbright-site:latest . --build-arg BUILDKIT_INLINE_CACHE=1

echo -e "${GREEN}🎉 Docker build completed successfully!${NC}"
docker images innerbright-site:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
