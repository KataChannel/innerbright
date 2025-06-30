#!/bin/bash

# Fix PWA Deployment Script
# Khắc phục vấn đề PWA scope: / bị đứng trên cloud server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 PWA Deployment Fix Script${NC}"
echo -e "${BLUE}==============================${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

echo -e "\n${YELLOW}📝 Checking PWA configuration...${NC}"

# Check if we're in the right directory
if [ ! -f "site/next.config.ts" ]; then
    echo -e "${RED}❌ Error: site/next.config.ts not found!${NC}"
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found project structure${NC}"

# 1. Verify manifest files
echo -e "\n${YELLOW}🔍 Verifying manifest files...${NC}"
if [ -f "site/public/manifest.json" ] && [ -f "site/public/manifest.webmanifest" ]; then
    echo -e "${GREEN}✅ Manifest files found${NC}"
    
    # Check scope in manifest.json
    if grep -q '"scope": "/"' site/public/manifest.json; then
        echo -e "${GREEN}✅ Scope corrected in manifest.json${NC}"
    else
        echo -e "${RED}❌ Scope still needs fixing in manifest.json${NC}"
    fi
else
    echo -e "${RED}❌ Manifest files missing${NC}"
fi

# 2. Check service worker
echo -e "\n${YELLOW}🔍 Checking service worker...${NC}"
if [ -f "site/public/sw.js" ]; then
    echo -e "${GREEN}✅ Service worker found${NC}"
    
    # Check service worker size (should not be empty)
    SW_SIZE=$(stat -c%s "site/public/sw.js" 2>/dev/null || echo "0")
    if [ "$SW_SIZE" -gt 1000 ]; then
        echo -e "${GREEN}✅ Service worker appears to be properly generated (${SW_SIZE} bytes)${NC}"
    else
        echo -e "${YELLOW}⚠️  Service worker seems small (${SW_SIZE} bytes) - may need regeneration${NC}"
    fi
else
    echo -e "${RED}❌ Service worker not found${NC}"
fi

# 3. Rebuild PWA assets
echo -e "\n${YELLOW}🔨 Rebuilding PWA assets...${NC}"

# Get absolute path and change directory safely
SITE_DIR="$SCRIPT_DIR/site"
if [ ! -d "$SITE_DIR" ]; then
    echo -e "${RED}❌ Site directory not found: $SITE_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Changing to site directory: $SITE_DIR${NC}"
cd "$SITE_DIR" || {
    echo -e "${RED}❌ Cannot access site directory${NC}"
    exit 1
}

# Verify we can read the current directory
if ! pwd > /dev/null 2>&1; then
    echo -e "${RED}❌ Cannot read current directory${NC}"
    echo -e "${YELLOW}Trying to fix permissions...${NC}"
    chmod +rx . || true
    chmod +rx .. || true
fi

# Check if we have package.json
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ package.json not found in site directory${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Successfully accessed site directory${NC}"

# Clean previous build
echo -e "${YELLOW}🧹 Cleaning previous build...${NC}"
rm -rf .next/ || true
rm -f public/sw.js || true
rm -f public/workbox-*.js || true

# Check Bun installation and setup
echo -e "${YELLOW}🔧 Checking Bun setup...${NC}"
if command -v bun >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Bun available: $(bun --version)${NC}"
    
    # Check if Bun is from snap (may cause issues)
    BUN_PATH=$(which bun)
    if [[ "$BUN_PATH" == *"/snap/"* ]]; then
        echo -e "${YELLOW}⚠️  Warning: Bun is installed via snap, may cause permission issues${NC}"
    fi
else
    echo -e "${RED}❌ Bun not found${NC}"
    exit 1
fi

# Install dependencies with Bun
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies with Bun...${NC}"
    if ! bun install; then
        echo -e "${RED}❌ Failed to install dependencies with Bun${NC}"
        echo -e "${YELLOW}Trying with force reinstall...${NC}"
        rm -rf node_modules bun.lock
        bun install --force || {
            echo -e "${RED}❌ Bun installation failed completely${NC}"
            exit 1
        }
    fi
    echo -e "${GREEN}✅ Dependencies installed successfully${NC}"
else
    echo -e "${GREEN}✅ Dependencies already installed${NC}"
    echo -e "${YELLOW}Updating dependencies...${NC}"
    bun install
fi

# Generate Prisma client using Bun
echo -e "${YELLOW}🔧 Generating Prisma client with Bun...${NC}"
if ! bun run prisma:generate; then
    echo -e "${YELLOW}⚠️  Prisma generate failed, trying direct command...${NC}"
    bun prisma generate || echo -e "${YELLOW}⚠️  Prisma generate skipped${NC}"
fi

# Set optimal environment for Bun build
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1
export BUN_CONFIG_VERBOSE_INSTALL=true

# Build project with Bun and PWA
echo -e "${YELLOW}🏗️  Building project with Bun and PWA...${NC}"
echo -e "${YELLOW}Current directory: $(pwd)${NC}"
echo -e "${YELLOW}Using Bun version: $(bun --version)${NC}"
echo -e "${YELLOW}Bun path: $(which bun)${NC}"

# Try direct Bun build first
if bun run build; then
    echo -e "${GREEN}✅ Build successful with Bun${NC}"
else
    echo -e "${RED}❌ Build failed with Bun in current directory${NC}"
    echo -e "${YELLOW}Trying alternative Bun build method...${NC}"
    
    # Method 1: Try with explicit working directory
    if bun --cwd="$(pwd)" run build; then
        echo -e "${GREEN}✅ Build successful with explicit working directory${NC}"
    else
        echo -e "${YELLOW}Trying temp directory method with Bun...${NC}"
        
        # Method 2: Copy to temp directory (for permission issues)
        TEMP_DIR="/tmp/innerbright-build-$(date +%s)"
        echo -e "${YELLOW}Creating temp directory: $TEMP_DIR${NC}"
        
        # Copy all files to temp
        cp -r . "$TEMP_DIR"
        ORIGINAL_DIR="$(pwd)"
        cd "$TEMP_DIR"
        
        echo -e "${YELLOW}Building in temp directory with Bun...${NC}"
        if bun install && bun run build; then
            echo -e "${GREEN}✅ Build successful in temp directory${NC}"
            
            # Copy back the built files
            echo -e "${YELLOW}Copying build results back...${NC}"
            cp -r .next "$ORIGINAL_DIR/"
            cp public/sw.js "$ORIGINAL_DIR/public/" 2>/dev/null || true
            cp public/workbox-*.js "$ORIGINAL_DIR/public/" 2>/dev/null || true
            
            cd "$ORIGINAL_DIR"
            rm -rf "$TEMP_DIR"
            echo -e "${GREEN}✅ Build completed successfully${NC}"
        else
            echo -e "${RED}❌ Build failed even in temp directory${NC}"
            cd "$ORIGINAL_DIR"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    fi
fi

# 4. Check generated PWA files
echo -e "\n${YELLOW}🔍 Checking generated PWA files...${NC}"
if [ -f "public/sw.js" ]; then
    SW_SIZE=$(stat -c%s "public/sw.js")
    echo -e "${GREEN}✅ Service worker generated (${SW_SIZE} bytes)${NC}"
else
    echo -e "${RED}❌ Service worker not generated${NC}"
fi

if ls public/workbox-*.js 1> /dev/null 2>&1; then
    echo -e "${GREEN}✅ Workbox files generated${NC}"
else
    echo -e "${YELLOW}⚠️  Workbox files not found${NC}"
fi

cd ..

# 5. Update nginx configuration if needed
echo -e "\n${YELLOW}🔧 Checking nginx configuration...${NC}"
if grep -q "sw\.js" nginx.conf; then
    echo -e "${GREEN}✅ Nginx configured for service worker${NC}"
else
    echo -e "${YELLOW}⚠️  Nginx may need service worker configuration${NC}"
fi

# 6. Test build locally
echo -e "\n${YELLOW}🧪 Testing build locally...${NC}"

# Ensure we're in the site directory
if [ "$(basename $(pwd))" != "site" ]; then
    cd "$SITE_DIR" || {
        echo -e "${RED}❌ Cannot access site directory for testing${NC}"
        exit 1
    }
fi

# Check if build exists
if [ ! -d ".next" ]; then
    echo -e "${RED}❌ Build directory not found${NC}"
    exit 1
fi

# Start the application with Bun for testing
echo -e "${YELLOW}Starting application with Bun for testing...${NC}"
export PORT=3000

# Kill any existing process on port 3000
pkill -f "bun.*start\|next.*start" 2>/dev/null || true
sleep 2

# Start server with Bun
if bun run start > ../server.log 2>&1 &
then
    SERVER_PID=$!
    echo -e "${GREEN}✅ Server started with Bun (PID: $SERVER_PID)${NC}"
else
    echo -e "${RED}❌ Failed to start server with Bun${NC}"
    exit 1
fi

# Wait a moment for server to start
echo -e "${YELLOW}Waiting for server to start...${NC}"
sleep 10

# Test if server responds
LOCALHOST_TEST=false
if command -v curl >/dev/null 2>&1; then
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Local server responds${NC}"
        LOCALHOST_TEST=true
        
        # Test service worker endpoint
        if curl -f http://localhost:3000/sw.js > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Service worker endpoint accessible${NC}"
        else
            echo -e "${RED}❌ Service worker endpoint not accessible${NC}"
        fi
        
        # Test manifest
        if curl -f http://localhost:3000/manifest.json > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Manifest endpoint accessible${NC}"
        else
            echo -e "${RED}❌ Manifest endpoint not accessible${NC}"
        fi
    else
        echo -e "${RED}❌ Local server not responding${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  curl not available, skipping endpoint tests${NC}"
fi

# Kill test server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# Clean up log file
rm -f ../server.log

cd "$SCRIPT_DIR"

# 7. Deployment instructions
echo -e "\n${BLUE}📋 PWA Deployment Instructions:${NC}"
echo -e "${GREEN}1. Upload the built files to your server${NC}"
echo -e "${GREEN}2. Update nginx configuration:${NC}"
echo -e "   ${YELLOW}sudo cp nginx.conf /etc/nginx/sites-available/innerbright${NC}"
echo -e "   ${YELLOW}sudo nginx -t && sudo systemctl reload nginx${NC}"
echo -e "${GREEN}3. Ensure HTTPS is enabled (PWA requires HTTPS in production)${NC}"
echo -e "${GREEN}4. Clear browser cache and test PWA installation${NC}"

echo -e "\n${BLUE}🔧 Additional PWA Troubleshooting:${NC}"
echo -e "${YELLOW}If PWA still doesn't work:${NC}"
echo -e "1. Check browser DevTools > Application > Service Workers"
echo -e "2. Verify manifest in DevTools > Application > Manifest"
echo -e "3. Test on HTTPS (PWA requires secure context)"
echo -e "4. Clear all browser data and try again"
echo -e "5. Check nginx logs: ${YELLOW}sudo tail -f /var/log/nginx/error.log${NC}"

echo -e "\n${GREEN}✅ PWA Fix Script completed!${NC}"
echo -e "${BLUE}Next steps: Deploy to server and test PWA functionality${NC}"
