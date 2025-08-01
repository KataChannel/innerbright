#!/bin/bash

# =============================================================================
# Ultra-Optimized Next.js Standalone Build Script
# Tối ưu hóa cho deploy Docker trên cloud server
# =============================================================================

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Configuration
BUILD_MEMORY=${BUILD_MEMORY:-4096}
SKIP_PWA=${SKIP_PWA:-true}
CLOUD_OPTIMIZED=${CLOUD_OPTIMIZED:-true}

echo -e "${BLUE}🚀 Building Next.js Standalone for Cloud Deployment${NC}"
echo -e "${YELLOW}📋 Configuration:${NC}"
echo -e "   Memory Limit: ${BUILD_MEMORY}MB"
echo -e "   Skip PWA: ${SKIP_PWA}"
echo -e "   Cloud Optimized: ${CLOUD_OPTIMIZED}"
echo ""

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf .next
rm -rf .swc
rm -rf node_modules/.cache
rm -rf dist

# Ensure dependencies are installed
echo -e "${YELLOW}📦 Installing dependencies...${NC}"
if command -v bun >/dev/null 2>&1; then
    bun install --frozen-lockfile
else
    npm ci
fi

# Generate Prisma client if schema exists
if [ -f "prisma/schema.prisma" ]; then
    echo -e "${YELLOW}🗄️  Generating Prisma client...${NC}"
    if command -v bun >/dev/null 2>&1; then
        bunx prisma generate
    else
        npx prisma generate
    fi
fi

# Build with optimized settings
echo -e "${YELLOW}🏗️  Building Next.js application...${NC}"

# Set build environment variables
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export DISABLE_PWA_BUILD=${SKIP_PWA}
export DOCKER_BUILD=true
export SKIP_ENV_VALIDATION=true
export NODE_OPTIONS="--max-old-space-size=${BUILD_MEMORY}"

# Additional optimizations for cloud deployment
export NEXT_OPTIMIZE_FONTS=true
export NEXT_OPTIMIZE_IMAGES=false
export NEXT_SHARP=false

# Build the application
if command -v bun >/dev/null 2>&1; then
    echo -e "${BLUE}🟡 Using Bun for build...${NC}"
    bun run build:cloud-optimized
else
    echo -e "${BLUE}📦 Using npm for build...${NC}"
    npm run build:cloud-optimized
fi

# Verify build output
echo -e "${YELLOW}🔍 Verifying build output...${NC}"

if [ ! -d ".next/standalone" ]; then
    echo -e "${RED}❌ Error: Standalone output not found!${NC}"
    echo -e "${YELLOW}💡 Make sure next.config.ts has: output: 'standalone'${NC}"
    exit 1
fi

if [ ! -d ".next/static" ]; then
    echo -e "${RED}❌ Error: Static assets not found!${NC}"
    exit 1
fi

# Show build results
echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo -e "${BLUE}📊 Build artifacts:${NC}"
ls -la .next/

echo -e "${BLUE}📈 Build size analysis:${NC}"
echo "Standalone app: $(du -sh .next/standalone 2>/dev/null | cut -f1)"
echo "Static assets: $(du -sh .next/static 2>/dev/null | cut -f1)"
echo "Public files: $(du -sh public 2>/dev/null | cut -f1)"
echo "Total size: $(du -sh .next public 2>/dev/null | tail -1 | cut -f1)"

# Optimize standalone bundle
echo -e "${YELLOW}⚡ Optimizing standalone bundle...${NC}"

# Remove unnecessary files from standalone
cd .next/standalone
find . -name "*.map" -delete 2>/dev/null || true
find . -name "*.d.ts" -delete 2>/dev/null || true
find . -name "test" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "tests" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "__tests__" -type d -exec rm -rf {} + 2>/dev/null || true
find . -name "*.spec.js" -delete 2>/dev/null || true
find . -name "*.test.js" -delete 2>/dev/null || true

cd ../..

echo -e "${GREEN}🎉 Standalone build optimization completed!${NC}"
echo -e "${BLUE}📦 Optimized size: $(du -sh .next/standalone 2>/dev/null | cut -f1)${NC}"

# Create deployment info file
cat > .next/BUILD_INFO << EOF
BUILD_DATE=$(date -u +"%Y-%m-%d %H:%M:%S UTC")
BUILD_TYPE=standalone
NODE_ENV=production
MEMORY_LIMIT=${BUILD_MEMORY}MB
PWA_DISABLED=${SKIP_PWA}
CLOUD_OPTIMIZED=${CLOUD_OPTIMIZED}
BUILD_SIZE=$(du -sh .next 2>/dev/null | cut -f1)
EOF

echo -e "${BLUE}📋 Build info saved to .next/BUILD_INFO${NC}"
echo -e "${GREEN}🚀 Ready for Docker deployment!${NC}"
