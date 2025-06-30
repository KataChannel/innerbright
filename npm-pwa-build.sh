#!/bin/bash

# NPM PWA Build Script
# Fallback for Bun snap permission issues

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 NPM PWA Build${NC}"
echo -e "${BLUE}=================${NC}"

# Navigate to site directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SITE_DIR="$SCRIPT_DIR/site"

echo -e "\n${YELLOW}📂 Navigating to site directory...${NC}"
cd "$SITE_DIR"
echo -e "${GREEN}✅ In directory: $(pwd)${NC}"

# Clean previous build
echo -e "\n${YELLOW}🧹 Cleaning previous build...${NC}"
rm -rf .next/ public/sw.js public/workbox-*.js

# Install dependencies
echo -e "\n${YELLOW}📦 Installing dependencies with npm...${NC}"
if npm install; then
    echo -e "${GREEN}✅ Dependencies installed${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

# Build with npx next build directly
echo -e "\n${YELLOW}🏗️ Building with npx next build...${NC}"
if npx next build; then
    echo -e "${GREEN}✅ Build successful${NC}"
    
    # Check results
    echo -e "\n${BLUE}📊 Build Results:${NC}"
    if [ -f ".next/BUILD_ID" ]; then
        echo -e "${GREEN}✅ .next directory created${NC}"
        BUILD_ID=$(cat .next/BUILD_ID)
        echo -e "${GREEN}   Build ID: ${BUILD_ID}${NC}"
    else
        echo -e "${RED}❌ .next directory missing${NC}"
    fi
    
    if [ -f "public/sw.js" ]; then
        echo -e "${GREEN}✅ Service Worker created${NC}"
        SW_SIZE=$(stat -f%z "public/sw.js" 2>/dev/null || stat -c%s "public/sw.js" 2>/dev/null || echo "unknown")
        echo -e "${GREEN}   Size: ${SW_SIZE} bytes${NC}"
        echo -e "${GREEN}   First few lines:${NC}"
        head -5 "public/sw.js" | sed 's/^/      /'
    else
        echo -e "${RED}❌ Service Worker missing${NC}"
    fi
    
    # Check for workbox files
    WORKBOX_FILES=$(ls public/workbox-*.js 2>/dev/null | wc -l)
    if [ "$WORKBOX_FILES" -gt 0 ]; then
        echo -e "${GREEN}✅ Found $WORKBOX_FILES Workbox files${NC}"
        ls public/workbox-*.js 2>/dev/null | sed 's/^/   /'
    else
        echo -e "${YELLOW}⚠️  No Workbox files found${NC}"
    fi
    
    # Check manifest files
    if [ -f "public/manifest.json" ]; then
        echo -e "${GREEN}✅ manifest.json exists${NC}"
    else
        echo -e "${RED}❌ manifest.json missing${NC}"
    fi
    
    if [ -f "public/manifest.webmanifest" ]; then
        echo -e "${GREEN}✅ manifest.webmanifest exists${NC}"
    else
        echo -e "${RED}❌ manifest.webmanifest missing${NC}"
    fi
    
    echo -e "\n${GREEN}🎉 PWA build completed successfully!${NC}"
    echo -e "${YELLOW}📝 Next steps:${NC}"
    echo -e "   1. Test PWA locally: npm start"
    echo -e "   2. Deploy to production server"
    echo -e "   3. Test PWA installation on mobile"
    
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi
