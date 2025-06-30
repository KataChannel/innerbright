#!/bin/bash

# Simple PWA Build Test
set -e

echo "🔧 Simple PWA Build Test"
echo "======================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n${YELLOW}Step 1: Navigate to site directory${NC}"
cd /chikiet/Innerbright/innerbright/site
echo "Current directory: $(pwd)"
echo "Directory contents:"
ls -la | head -10

echo -e "\n${YELLOW}Step 2: Check package.json${NC}"
if [ -f "package.json" ]; then
    echo -e "${GREEN}✅ package.json found${NC}"
    echo "Build script:"
    grep '"build"' package.json || echo "No build script found"
else
    echo -e "${RED}❌ package.json not found${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Step 3: Check node_modules${NC}"
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✅ node_modules exists${NC}"
    echo "node_modules size: $(du -sh node_modules | cut -f1)"
else
    echo -e "${RED}❌ node_modules not found${NC}"
    echo "Installing dependencies..."
    if command -v bun >/dev/null 2>&1; then
        bun install
    else
        npm install
    fi
fi

echo -e "\n${YELLOW}Step 4: Check Bun availability${NC}"
if command -v bun >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Bun available${NC}"
    echo "Bun version: $(bun --version)"
else
    echo -e "${RED}❌ Bun not available${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Step 5: Clean previous build${NC}"
rm -rf .next/ || true
rm -f public/sw.js || true
rm -f public/workbox-*.js || true
echo "Cleaned build artifacts"

echo -e "\n${YELLOW}Step 6: Test directory access${NC}"
if pwd > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Can read current directory${NC}"
else
    echo -e "${RED}❌ Cannot read current directory${NC}"
    exit 1
fi

echo -e "\n${YELLOW}Step 7: Try build in current directory${NC}"
echo "Running: bun run build"
if bun run build; then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    echo -e "\n${YELLOW}Trying alternative: copy to temp and build${NC}"
    
    # Create temp directory
    TEMP_DIR="/tmp/innerbright-build-$(date +%s)"
    echo "Creating temp directory: $TEMP_DIR"
    
    # Copy to temp
    cp -r . "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    echo "Building in temp directory..."
    if bun run build; then
        echo -e "${GREEN}✅ Build successful in temp${NC}"
        
        # Copy back
        echo "Copying build back to original location..."
        cp -r .next /chikiet/Innerbright/innerbright/site/
        cp public/sw.js /chikiet/Innerbright/innerbright/site/public/ 2>/dev/null || true
        cp public/workbox-*.js /chikiet/Innerbright/innerbright/site/public/ 2>/dev/null || true
        
        # Cleanup
        cd /
        rm -rf "$TEMP_DIR"
        
        echo -e "${GREEN}✅ Build completed via temp directory${NC}"
    else
        echo -e "${RED}❌ Build failed even in temp directory${NC}"
        cd /
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

echo -e "\n${YELLOW}Step 8: Check generated files${NC}"
cd /chikiet/Innerbright/innerbright/site

if [ -d ".next" ]; then
    echo -e "${GREEN}✅ .next directory created${NC}"
    echo ".next size: $(du -sh .next | cut -f1)"
else
    echo -e "${RED}❌ .next directory not created${NC}"
fi

if [ -f "public/sw.js" ]; then
    SW_SIZE=$(stat -c%s "public/sw.js")
    echo -e "${GREEN}✅ Service worker created (${SW_SIZE} bytes)${NC}"
else
    echo -e "${RED}❌ Service worker not created${NC}"
fi

if ls public/workbox-*.js 1> /dev/null 2>&1; then
    echo -e "${GREEN}✅ Workbox files created${NC}"
else
    echo -e "${YELLOW}⚠️  Workbox files not found${NC}"
fi

echo -e "\n${GREEN}🎉 PWA Build Test Completed!${NC}"
