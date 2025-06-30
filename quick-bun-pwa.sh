#!/bin/bash

# Quick Bun PWA Build Script
# Optimized for snap Bun installations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Quick Bun PWA Build${NC}"
echo -e "${BLUE}=====================${NC}"

# Navigate to site directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
SITE_DIR="$SCRIPT_DIR/site"

echo -e "\n${YELLOW}📂 Navigating to site directory...${NC}"
if [ ! -d "$SITE_DIR" ]; then
    echo -e "${RED}❌ Site directory not found${NC}"
    exit 1
fi

cd "$SITE_DIR"
echo -e "${GREEN}✅ In directory: $(pwd)${NC}"

# Check Bun
echo -e "\n${YELLOW}🔧 Checking Bun...${NC}"
if ! command -v bun >/dev/null 2>&1; then
    echo -e "${RED}❌ Bun not found${NC}"
    exit 1
fi

BUN_VERSION=$(bun --version)
BUN_PATH=$(which bun)
echo -e "${GREEN}✅ Bun ${BUN_VERSION} at ${BUN_PATH}${NC}"

# Handle snap Bun issues
if [[ "$BUN_PATH" == *"/snap/"* ]]; then
    echo -e "${YELLOW}⚠️  Snap Bun detected - using temp directory method${NC}"
    
    # Create temp directory
    TEMP_DIR="/tmp/innerbright-pwa-$(date +%s)"
    echo -e "${YELLOW}Creating temp build directory: $TEMP_DIR${NC}"
    
    # Copy project to temp (with proper permissions)
    mkdir -p "$TEMP_DIR"
    cp -r . "$TEMP_DIR/"
    ORIGINAL_DIR="$(pwd)"
    cd "$TEMP_DIR"
    
    echo -e "${YELLOW}Working in temp directory: $(pwd)${NC}"
    echo -e "${YELLOW}Files in temp directory:${NC}"
    ls -la | head -10
fi

# Clean previous build
echo -e "\n${YELLOW}🧹 Cleaning previous build...${NC}"
rm -rf .next/ public/sw.js public/workbox-*.js

# Install/update dependencies
echo -e "\n${YELLOW}📦 Installing dependencies...${NC}"
if bun install; then
    echo -e "${GREEN}✅ Dependencies installed${NC}"
else
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    if [[ "$BUN_PATH" == *"/snap/"* ]]; then
        cd "$ORIGINAL_DIR"
        rm -rf "$TEMP_DIR"
    fi
    exit 1
fi

# Build
echo -e "\n${YELLOW}🏗️ Building with Bun...${NC}"
if bun run build; then
    echo -e "${GREEN}✅ Build successful${NC}"
    
    # If using temp directory, copy back to original location
    if [[ "$BUN_PATH" == *"/snap/"* ]]; then
        echo -e "\n${YELLOW}📦 Copying build back to original location...${NC}"
        cd "$ORIGINAL_DIR"
        
        # Copy build artifacts
        if [ -d "$TEMP_DIR/.next" ]; then
            cp -r "$TEMP_DIR/.next" .
            echo -e "${GREEN}✅ .next directory copied${NC}"
        fi
        
        if [ -f "$TEMP_DIR/public/sw.js" ]; then
            cp "$TEMP_DIR/public/sw.js" public/
            echo -e "${GREEN}✅ Service Worker copied${NC}"
        fi
        
        # Copy workbox files
        cp "$TEMP_DIR"/public/workbox-*.js public/ 2>/dev/null || true
        
        # Cleanup temp directory
        rm -rf "$TEMP_DIR"
        echo -e "${GREEN}✅ Temp directory cleaned up${NC}"
    fi
    
    # Check results
    echo -e "\n${BLUE}📊 Build Results:${NC}"
    if [ -f ".next/BUILD_ID" ]; then
        echo -e "${GREEN}✅ .next directory created${NC}"
    else
        echo -e "${RED}❌ .next directory missing${NC}"
    fi
    
    if [ -f "public/sw.js" ]; then
        echo -e "${GREEN}✅ Service Worker created${NC}"
        SW_SIZE=$(stat -f%z "public/sw.js" 2>/dev/null || stat -c%s "public/sw.js" 2>/dev/null || echo "unknown")
        echo -e "${GREEN}   Size: ${SW_SIZE} bytes${NC}"
    else
        echo -e "${RED}❌ Service Worker missing${NC}"
    fi
    
    # Check for workbox files
    WORKBOX_FILES=$(ls public/workbox-*.js 2>/dev/null | wc -l)
    if [ "$WORKBOX_FILES" -gt 0 ]; then
        echo -e "${GREEN}✅ Found $WORKBOX_FILES Workbox files${NC}"
    else
        echo -e "${YELLOW}⚠️  No Workbox files found${NC}"
    fi
    
    echo -e "\n${GREEN}🎉 PWA build completed successfully!${NC}"
    
else
    echo -e "${RED}❌ Build failed${NC}"
    if [[ "$BUN_PATH" == *"/snap/"* ]]; then
        cd "$ORIGINAL_DIR"
        rm -rf "$TEMP_DIR"
    fi
    exit 1
fi
