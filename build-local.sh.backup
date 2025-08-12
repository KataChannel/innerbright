#!/bin/bash

# Local build script for optimization
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🏗️ Building application locally for server deployment...${NC}"

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf .next
rm -rf node_modules/.cache 2>/dev/null || true

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    if command -v bun &> /dev/null; then
        bun install
    else
        npm install
    fi
fi

# Build the application
echo -e "${GREEN}🔨 Building Next.js application...${NC}"
if command -v bun &> /dev/null; then
    bun run build
else
    npm run build
fi

# Check build results
if [ -d ".next/standalone" ]; then
    echo -e "${GREEN}✅ Standalone build created successfully!${NC}"
    echo -e "${BLUE}📊 Build size:${NC}"
    du -sh .next/standalone
    du -sh .next/static
    echo -e "${GREEN}✅ Ready for server deployment with Dockerfile.prebuilt${NC}"
else
    echo -e "${YELLOW}⚠️ Standalone build not found, using regular build${NC}"
    echo -e "${BLUE}📊 Build size:${NC}"
    du -sh .next
    echo -e "${YELLOW}⚠️ Will use Dockerfile.prebuilt-regular for deployment${NC}"
fi

# Show next steps
echo -e "${BLUE}🚀 Next steps:${NC}"
echo -e "1. Run ${GREEN}./deploy-prebuilt.sh${NC} to deploy to server"
echo -e "2. Or manually commit and push the .next folder to git"

echo -e "${GREEN}✅ Local build completed!${NC}"
