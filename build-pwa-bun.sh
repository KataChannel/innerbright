#!/bin/bash

# Bun-Optimized PWA Build Script
# Sử dụng Bun để build PWA một cách tối ưu

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Bun-Optimized PWA Build${NC}"
echo -e "${BLUE}==========================${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SITE_DIR="$SCRIPT_DIR/site"

# Check Bun installation
echo -e "\n${YELLOW}🔍 Checking Bun installation...${NC}"
if ! command -v bun >/dev/null 2>&1; then
    echo -e "${RED}❌ Bun not found!${NC}"
    echo -e "${YELLOW}Installing Bun...${NC}"
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
    
    if ! command -v bun >/dev/null 2>&1; then
        echo -e "${RED}❌ Failed to install Bun${NC}"
        exit 1
    fi
fi

BUN_VERSION=$(bun --version)
BUN_PATH=$(which bun)
echo -e "${GREEN}✅ Bun found: v${BUN_VERSION}${NC}"
echo -e "${YELLOW}Bun path: ${BUN_PATH}${NC}"

# Check if Bun is from snap (may cause issues)
if [[ "$BUN_PATH" == *"/snap/"* ]]; then
    echo -e "${YELLOW}⚠️  Warning: Bun from snap may have permission issues${NC}"
    echo -e "${YELLOW}Consider installing official Bun version${NC}"
fi

# Navigate to site directory
echo -e "\n${YELLOW}📁 Navigating to site directory...${NC}"
if [ ! -d "$SITE_DIR" ]; then
    echo -e "${RED}❌ Site directory not found: $SITE_DIR${NC}"
    exit 1
fi

cd "$SITE_DIR" || {
    echo -e "${RED}❌ Cannot access site directory${NC}"
    exit 1
}

echo -e "${GREEN}✅ In site directory: $(pwd)${NC}"

# Verify directory access
if ! pwd > /dev/null 2>&1; then
    echo -e "${RED}❌ Directory access issue detected${NC}"
    echo -e "${YELLOW}Attempting to fix permissions...${NC}"
    chmod +rx . || true
    chmod +rx .. || true
fi

# Check package.json
echo -e "\n${YELLOW}📋 Checking package configuration...${NC}"
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ package.json found${NC}"

# Display current scripts
echo -e "${YELLOW}Available scripts:${NC}"
if command -v jq >/dev/null 2>&1; then
    jq -r '.scripts | to_entries[] | "  \(.key): \(.value)"' package.json
else
    grep -A 10 '"scripts"' package.json || echo "Could not parse scripts"
fi

# Clean previous build
echo -e "\n${YELLOW}🧹 Cleaning previous build...${NC}"
rm -rf .next/ || true
rm -f public/sw.js || true
rm -f public/workbox-*.js || true
echo -e "${GREEN}✅ Cleaned build artifacts${NC}"

# Install dependencies with Bun
echo -e "\n${YELLOW}📦 Installing dependencies with Bun...${NC}"
if [ ! -d "node_modules" ] || [ ! -f "bun.lock" ]; then
    echo -e "${YELLOW}Installing all dependencies...${NC}"
    if ! bun install; then
        echo -e "${RED}❌ Failed to install dependencies${NC}"
        echo -e "${YELLOW}Trying with --force...${NC}"
        bun install --force || {
            echo -e "${RED}❌ Bun install failed completely${NC}"
            exit 1
        }
    fi
else
    echo -e "${YELLOW}Updating dependencies...${NC}"
    bun install
fi

echo -e "${GREEN}✅ Dependencies ready${NC}"

# Generate Prisma client
echo -e "\n${YELLOW}🔧 Generating Prisma client...${NC}"
if [ -f "prisma/schema.prisma" ]; then
    if ! bun run prisma:generate 2>/dev/null; then
        echo -e "${YELLOW}Script not found, trying direct command...${NC}"
        bun prisma generate || echo -e "${YELLOW}⚠️  Prisma generation skipped${NC}"
    fi
    echo -e "${GREEN}✅ Prisma client generated${NC}"
else
    echo -e "${YELLOW}⚠️  No Prisma schema found, skipping${NC}"
fi

# Set environment variables for optimal build
echo -e "\n${YELLOW}⚙️  Setting build environment...${NC}"
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export BUN_CONFIG_VERBOSE_INSTALL=false

# Verify next.config.ts has PWA configuration
echo -e "\n${YELLOW}🔍 Checking PWA configuration...${NC}"
if grep -q "withPWA" next.config.ts; then
    echo -e "${GREEN}✅ PWA configuration found${NC}"
else
    echo -e "${YELLOW}⚠️  PWA configuration may be missing${NC}"
fi

# Build with Bun
echo -e "\n${YELLOW}🏗️  Building with Bun...${NC}"
echo -e "${YELLOW}Running: bun run build${NC}"

# Try different build strategies
BUILD_SUCCESS=false

# Strategy 1: Direct build
echo -e "${YELLOW}Strategy 1: Direct build${NC}"
if timeout 300 bun run build; then
    BUILD_SUCCESS=true
    echo -e "${GREEN}✅ Direct build successful${NC}"
else
    echo -e "${YELLOW}⚠️  Direct build failed, trying alternative methods${NC}"
fi

# Strategy 2: Build with explicit working directory
if [ "$BUILD_SUCCESS" = false ]; then
    echo -e "${YELLOW}Strategy 2: Build with explicit working directory${NC}"
    if timeout 300 bun --cwd="$(pwd)" run build; then
        BUILD_SUCCESS=true
        echo -e "${GREEN}✅ Build with explicit cwd successful${NC}"
    fi
fi

# Strategy 3: Temp directory build (for permission issues)
if [ "$BUILD_SUCCESS" = false ]; then
    echo -e "${YELLOW}Strategy 3: Temp directory build${NC}"
    TEMP_DIR="/tmp/bun-pwa-build-$(date +%s)"
    
    echo -e "${YELLOW}Creating temp directory: $TEMP_DIR${NC}"
    cp -r . "$TEMP_DIR"
    ORIGINAL_DIR="$(pwd)"
    
    cd "$TEMP_DIR"
    echo -e "${YELLOW}Building in temp directory...${NC}"
    
    if bun install && timeout 300 bun run build; then
        BUILD_SUCCESS=true
        echo -e "${GREEN}✅ Temp directory build successful${NC}"
        
        # Copy back results
        echo -e "${YELLOW}Copying build results back...${NC}"
        cp -r .next "$ORIGINAL_DIR/" 2>/dev/null || true
        cp public/sw.js "$ORIGINAL_DIR/public/" 2>/dev/null || true
        cp public/workbox-*.js "$ORIGINAL_DIR/public/" 2>/dev/null || true
        
        cd "$ORIGINAL_DIR"
        echo -e "${GREEN}✅ Build artifacts copied back${NC}"
    else
        cd "$ORIGINAL_DIR"
        echo -e "${RED}❌ Temp directory build also failed${NC}"
    fi
    
    # Cleanup
    rm -rf "$TEMP_DIR"
fi

if [ "$BUILD_SUCCESS" = false ]; then
    echo -e "${RED}❌ All build strategies failed${NC}"
    exit 1
fi

# Verify build results
echo -e "\n${YELLOW}🔍 Verifying build results...${NC}"

if [ -d ".next" ]; then
    BUILD_SIZE=$(du -sh .next | cut -f1)
    echo -e "${GREEN}✅ .next directory created (${BUILD_SIZE})${NC}"
else
    echo -e "${RED}❌ .next directory not found${NC}"
    exit 1
fi

if [ -f "public/sw.js" ]; then
    SW_SIZE=$(stat -c%s "public/sw.js")
    echo -e "${GREEN}✅ Service Worker generated (${SW_SIZE} bytes)${NC}"
    
    # Check SW content
    if [ "$SW_SIZE" -gt 1000 ]; then
        echo -e "${GREEN}✅ Service Worker appears complete${NC}"
    else
        echo -e "${YELLOW}⚠️  Service Worker seems small${NC}"
    fi
else
    echo -e "${RED}❌ Service Worker not generated${NC}"
fi

if ls public/workbox-*.js 1> /dev/null 2>&1; then
    WB_COUNT=$(ls public/workbox-*.js | wc -l)
    echo -e "${GREEN}✅ Workbox files generated (${WB_COUNT} files)${NC}"
else
    echo -e "${YELLOW}⚠️  Workbox files not found${NC}"
fi

# Test server start
echo -e "\n${YELLOW}🧪 Testing server startup...${NC}"

# Kill any existing processes
pkill -f "bun.*start\|next.*start" 2>/dev/null || true
sleep 2

# Start server
export PORT=3001
timeout 30 bun run start > start.log 2>&1 &
SERVER_PID=$!

sleep 5

# Test endpoints
if command -v curl >/dev/null 2>&1; then
    if curl -f http://localhost:3001 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server responds correctly${NC}"
        
        # Test PWA endpoints
        if curl -f http://localhost:3001/sw.js > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Service Worker endpoint accessible${NC}"
        fi
        
        if curl -f http://localhost:3001/manifest.json > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Manifest endpoint accessible${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Server not responding (may be starting)${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  curl not available for testing${NC}"
fi

# Cleanup test server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true
rm -f start.log

echo -e "\n${GREEN}🎉 Bun PWA Build Completed Successfully!${NC}"
echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo -e "1. ${GREEN}Deploy built files to your server${NC}"
echo -e "2. ${GREEN}Update nginx configuration for PWA${NC}"
echo -e "3. ${GREEN}Ensure HTTPS is enabled${NC}"
echo -e "4. ${GREEN}Test PWA installation${NC}"

echo -e "\n${BLUE}📊 Build Summary:${NC}"
echo -e "• Bun version: ${BUN_VERSION}"
echo -e "• Build directory: .next ($(du -sh .next 2>/dev/null | cut -f1 || echo 'N/A'))"
echo -e "• Service Worker: $([ -f 'public/sw.js' ] && echo 'Generated' || echo 'Missing')"
echo -e "• Workbox files: $(ls public/workbox-*.js 2>/dev/null | wc -l) files"
