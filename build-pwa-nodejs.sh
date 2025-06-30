#!/bin/bash

# PWA Build using Node.js instead of Bun
# Fix for Bun snap permissions issue

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 PWA Build using Node.js${NC}"
echo -e "${BLUE}=========================${NC}"

echo -e "\n${YELLOW}🔍 Checking available tools...${NC}"

# Check Node.js
if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Node.js available: $(node --version)${NC}"
else
    echo -e "${RED}❌ Node.js not available${NC}"
    exit 1
fi

# Check npm
if command -v npm >/dev/null 2>&1; then
    echo -e "${GREEN}✅ npm available: $(npm --version)${NC}"
else
    echo -e "${RED}❌ npm not available${NC}"
    exit 1
fi

# Navigate to site directory
cd /chikiet/Innerbright/innerbright/site
echo -e "\n${YELLOW}📂 Working in: $(pwd)${NC}"

# Clean previous build
echo -e "\n${YELLOW}🧹 Cleaning previous build...${NC}"
rm -rf .next/ || true
rm -f public/sw.js || true
rm -f public/workbox-*.js || true

# Install/update dependencies with npm
echo -e "\n${YELLOW}📦 Installing dependencies with npm...${NC}"
npm install

# Generate Prisma client
echo -e "\n${YELLOW}🔧 Generating Prisma client...${NC}"
if [ -f "package.json" ] && grep -q "prisma:generate" package.json; then
    npm run prisma:generate || echo -e "${YELLOW}⚠️  Prisma generate skipped${NC}"
else
    echo -e "${YELLOW}⚠️  No Prisma generate script found${NC}"
fi

# Build with npm
echo -e "\n${YELLOW}🏗️  Building with npm...${NC}"
export NODE_ENV=production
export NEXT_TELEMETRY_DISABLED=1

if npm run build; then
    echo -e "${GREEN}✅ Build successful with npm${NC}"
else
    echo -e "${RED}❌ Build failed with npm${NC}"
    exit 1
fi

# Check generated files
echo -e "\n${YELLOW}🔍 Checking generated PWA files...${NC}"

if [ -d ".next" ]; then
    echo -e "${GREEN}✅ Next.js build directory created${NC}"
    echo "Build size: $(du -sh .next | cut -f1)"
else
    echo -e "${RED}❌ Next.js build directory not created${NC}"
fi

if [ -f "public/sw.js" ]; then
    SW_SIZE=$(stat -c%s "public/sw.js")
    echo -e "${GREEN}✅ Service worker generated (${SW_SIZE} bytes)${NC}"
else
    echo -e "${RED}❌ Service worker not generated${NC}"
fi

if ls public/workbox-*.js 1> /dev/null 2>&1; then
    echo -e "${GREEN}✅ Workbox files generated${NC}"
    ls -la public/workbox-*.js
else
    echo -e "${YELLOW}⚠️  Workbox files not found${NC}"
fi

# Test the build
echo -e "\n${YELLOW}🧪 Testing the build...${NC}"
echo -e "${YELLOW}Starting server...${NC}"

# Start server for testing
npm run start > ../build-test.log 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 10

# Test endpoints
if command -v curl >/dev/null 2>&1; then
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Server responding${NC}"
        
        if curl -f http://localhost:3000/sw.js > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Service worker endpoint working${NC}"
        else
            echo -e "${RED}❌ Service worker endpoint not working${NC}"
        fi
        
        if curl -f http://localhost:3000/manifest.json > /dev/null 2>&1; then
            echo -e "${GREEN}✅ Manifest endpoint working${NC}"
        else
            echo -e "${RED}❌ Manifest endpoint not working${NC}"
        fi
    else
        echo -e "${RED}❌ Server not responding${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  curl not available for testing${NC}"
fi

# Stop test server
kill $SERVER_PID 2>/dev/null || true
wait $SERVER_PID 2>/dev/null || true

# Clean up log
rm -f ../build-test.log

echo -e "\n${GREEN}🎉 PWA Build with Node.js completed!${NC}"

echo -e "\n${BLUE}📋 Next Steps:${NC}"
echo -e "${GREEN}1. Deploy the build to your server${NC}"
echo -e "${GREEN}2. Update nginx configuration for PWA support${NC}"
echo -e "${GREEN}3. Ensure HTTPS is enabled${NC}"
echo -e "${GREEN}4. Test PWA installation on mobile${NC}"

echo -e "\n${YELLOW}💡 Note: If you prefer Bun, consider installing the official version instead of snap:${NC}"
echo -e "   ${YELLOW}curl -fsSL https://bun.sh/install | bash${NC}"
