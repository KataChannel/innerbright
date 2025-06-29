#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 InnerBright - Bun.js Development Server${NC}"
echo -e "${BLUE}=========================================${NC}"

# Ensure bun is in PATH
export PATH="$HOME/.bun/bin:$PATH"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: package.json not found!${NC}"
    echo -e "${YELLOW}Please run this script from the project root directory.${NC}"
    exit 1
fi

# Check if bun is available
if ! command -v bun &> /dev/null; then
    echo -e "${RED}❌ Bun is not installed or not in PATH!${NC}"
    echo -e "${YELLOW}Please run ./migrate-to-bun.sh first${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Bun.js found: $(bun --version)${NC}"

# Try to run the development server
echo -e "${YELLOW}🌟 Starting development server...${NC}"

# First try direct command
if bun run dev; then
    echo -e "${GREEN}✅ Development server started successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Direct execution failed, trying workaround...${NC}"
    
    # Create temporary directory and copy project
    TEMP_DIR="/tmp/innerbright-dev-$(date +%s)"
    echo -e "${YELLOW}📁 Copying project to temporary directory: $TEMP_DIR${NC}"
    
    cp -r . "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    echo -e "${YELLOW}🌟 Starting server from temporary directory...${NC}"
    bun run dev
fi
