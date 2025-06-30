#!/bin/bash

# PWA Test Script
# Test PWA functionality before deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🧪 PWA Test Script${NC}"
echo -e "${BLUE}==================${NC}"

# Check if we're in the right directory
if [ ! -f "site/next.config.ts" ]; then
    echo -e "${RED}❌ Error: Run this script from the project root${NC}"
    exit 1
fi

cd site

# Check PWA configuration
echo -e "\n${YELLOW}📋 Checking PWA Configuration...${NC}"

# Check next.config.ts
if grep -q "withPWA" next.config.ts; then
    echo -e "${GREEN}✅ next-pwa is configured${NC}"
else
    echo -e "${RED}❌ next-pwa not found in config${NC}"
fi

# Check manifest files
if [ -f "public/manifest.json" ]; then
    echo -e "${GREEN}✅ manifest.json exists${NC}"
    
    # Check scope
    if grep -q '"scope": "/"' public/manifest.json; then
        echo -e "${GREEN}✅ Correct scope in manifest.json${NC}"
    else
        echo -e "${RED}❌ Incorrect scope in manifest.json${NC}"
    fi
    
    # Check start_url
    if grep -q '"start_url": "/"' public/manifest.json; then
        echo -e "${GREEN}✅ Correct start_url in manifest.json${NC}"
    else
        echo -e "${RED}❌ Incorrect start_url in manifest.json${NC}"
    fi
else
    echo -e "${RED}❌ manifest.json not found${NC}"
fi

# Check icons
echo -e "\n${YELLOW}🎨 Checking PWA Icons...${NC}"
ICON_SIZES=("72x72" "96x96" "128x128" "144x144" "152x152" "192x192" "384x384" "512x512")
MISSING_ICONS=0

for size in "${ICON_SIZES[@]}"; do
    if [ -f "public/icons/icon-${size}.png" ]; then
        echo -e "${GREEN}✅ Icon ${size} found${NC}"
    else
        echo -e "${RED}❌ Icon ${size} missing${NC}"
        ((MISSING_ICONS++))
    fi
done

if [ $MISSING_ICONS -eq 0 ]; then
    echo -e "${GREEN}✅ All required icons present${NC}"
else
    echo -e "${YELLOW}⚠️  ${MISSING_ICONS} icons missing${NC}"
fi

# Test build
echo -e "\n${YELLOW}🏗️  Testing PWA Build...${NC}"
if [ -d ".next" ]; then
    echo -e "${YELLOW}Cleaning previous build...${NC}"
    rm -rf .next
fi

echo -e "${YELLOW}Building project...${NC}"
if npx next build > build.log 2>&1; then
    echo -e "${GREEN}✅ Build successful${NC}"
    
    # Check for PWA files
    if [ -f "public/sw.js" ]; then
        SW_SIZE=$(stat -c%s "public/sw.js")
        echo -e "${GREEN}✅ Service Worker generated (${SW_SIZE} bytes)${NC}"
    else
        echo -e "${RED}❌ Service Worker not generated${NC}"
    fi
    
    if ls public/workbox-*.js 1> /dev/null 2>&1; then
        echo -e "${GREEN}✅ Workbox files generated${NC}"
    else
        echo -e "${YELLOW}⚠️  Workbox files not found${NC}"
    fi
    
else
    echo -e "${RED}❌ Build failed${NC}"
    echo -e "${YELLOW}Build log:${NC}"
    tail -20 build.log
    exit 1
fi

# Test server start
echo -e "\n${YELLOW}🚀 Testing Server Start...${NC}"
echo -e "${YELLOW}Starting server...${NC}"
timeout 30 bun run start > server.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 10

# Test endpoints
echo -e "\n${YELLOW}🔗 Testing Endpoints...${NC}"

# Test main page
if curl -f -s http://localhost:3000 > /dev/null; then
    echo -e "${GREEN}✅ Main page accessible${NC}"
else
    echo -e "${RED}❌ Main page not accessible${NC}"
fi

# Test service worker
if curl -f -s http://localhost:3000/sw.js > /dev/null; then
    echo -e "${GREEN}✅ Service Worker endpoint accessible${NC}"
    
    # Check service worker content
    SW_CONTENT=$(curl -s http://localhost:3000/sw.js | head -c 100)
    if [[ $SW_CONTENT == *"workbox"* ]] || [[ $SW_CONTENT == *"self.addEventListener"* ]]; then
        echo -e "${GREEN}✅ Service Worker appears valid${NC}"
    else
        echo -e "${YELLOW}⚠️  Service Worker content may be invalid${NC}"
    fi
else
    echo -e "${RED}❌ Service Worker endpoint not accessible${NC}"
fi

# Test manifest
if curl -f -s http://localhost:3000/manifest.json > /dev/null; then
    echo -e "${GREEN}✅ Manifest endpoint accessible${NC}"
    
    # Validate manifest JSON
    if curl -s http://localhost:3000/manifest.json | jq . > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Manifest is valid JSON${NC}"
    else
        echo -e "${YELLOW}⚠️  Manifest JSON may be invalid${NC}"
    fi
else
    echo -e "${RED}❌ Manifest endpoint not accessible${NC}"
fi

# Test icon
if curl -f -s http://localhost:3000/icons/icon-192x192.png > /dev/null; then
    echo -e "${GREEN}✅ PWA icons accessible${NC}"
else
    echo -e "${RED}❌ PWA icons not accessible${NC}"
fi

# Cleanup
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# Summary
echo -e "\n${BLUE}📊 Test Summary${NC}"
echo -e "${BLUE}===============${NC}"

if [ -f "public/sw.js" ] && [ -f "public/manifest.json" ]; then
    echo -e "${GREEN}✅ PWA files generated successfully${NC}"
    echo -e "${GREEN}✅ Ready for deployment${NC}"
    
    echo -e "\n${YELLOW}📋 Next Steps:${NC}"
    echo -e "1. Run deployment script: ${GREEN}../fix-pwa-deployment.sh${NC}"
    echo -e "2. Deploy to server with HTTPS enabled"
    echo -e "3. Test PWA installation on mobile device"
    echo -e "4. Verify service worker registration in DevTools"
    
else
    echo -e "${RED}❌ PWA configuration incomplete${NC}"
    echo -e "${YELLOW}Check the errors above and fix configuration${NC}"
fi

# Cleanup log files
rm -f build.log server.log

echo -e "\n${BLUE}🎉 PWA Test completed!${NC}"
