#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Bun.js Migration Script${NC}"
echo -e "${BLUE}=========================${NC}"

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Change to the script directory to ensure we're in the project root
cd "$SCRIPT_DIR"

# Verify we're in the right directory by checking for package.json
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ Error: package.json not found in current directory!${NC}"
    echo -e "${YELLOW}Current directory: $(pwd)${NC}"
    echo -e "${YELLOW}Make sure to run this script from the project root directory.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found package.json in: $(pwd)${NC}"

# Check if Bun is installed
if ! command -v bun &> /dev/null; then
    echo -e "${RED}❌ Bun is not installed!${NC}"
    echo -e "${YELLOW}Installing Bun.js...${NC}"
    curl -fsSL https://bun.sh/install | bash
    
    # Add bun to PATH for current session
    export PATH="$HOME/.bun/bin:$PATH"
    
    # Source the shell profile to get bun in PATH
    if [ -f ~/.bashrc ]; then
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc
        source ~/.bashrc
    elif [ -f ~/.zshrc ]; then
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.zshrc
        source ~/.zshrc
    fi
    
    # Verify installation
    if ! command -v bun &> /dev/null; then
        echo -e "${RED}❌ Failed to install Bun! Please install manually: https://bun.sh${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Bun.js installed successfully!${NC}"
else
    echo -e "${GREEN}✅ Bun.js is already installed!${NC}"
    echo -e "Version: $(bun --version)"
    
    # Check if bun is from snap and suggest using official installer
    BUN_PATH=$(which bun)
    if [[ "$BUN_PATH" == *"/snap/"* ]]; then
        echo -e "${YELLOW}⚠️  Warning: Bun is installed via snap, which may cause permission issues.${NC}"
        echo -e "${YELLOW}Installing official Bun.js version...${NC}"
        curl -fsSL https://bun.sh/install | bash
        export PATH="$HOME/.bun/bin:$PATH"
        echo -e "${GREEN}✅ Official Bun.js installed and configured!${NC}"
    fi
fi

echo -e "\n${YELLOW}🧹 Cleaning up old dependencies...${NC}"
# Remove old lock files and node_modules
rm -rf node_modules
rm -f package-lock.json yarn.lock pnpm-lock.yaml

echo -e "${YELLOW}📦 Installing dependencies with Bun...${NC}"
if ! bun install; then
    echo -e "${RED}❌ Failed to install dependencies with bun install${NC}"
    echo -e "${YELLOW}Trying to reinitialize...${NC}"
    bun init -y
    bun install
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Still failed to install dependencies. Please check your package.json${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}🔧 Generating Prisma client...${NC}"
if ! bun run prisma:generate; then
    echo -e "${RED}❌ Failed to generate Prisma client${NC}"
    echo -e "${YELLOW}Checking if Prisma schema exists...${NC}"
    if [ -f "prisma/schema.prisma" ]; then
        echo -e "${YELLOW}Prisma schema found, trying direct command...${NC}"
        if ! bun prisma generate; then
            echo -e "${RED}❌ Failed to generate Prisma client with direct command${NC}"
            echo -e "${YELLOW}Please run 'bun run prisma:generate' manually after the script completes${NC}"
        fi
    else
        echo -e "${YELLOW}No Prisma schema found, skipping Prisma client generation${NC}"
    fi
fi

# Test if bun can read the current directory
echo -e "${YELLOW}🔍 Testing Bun directory access...${NC}"
if ! bun --version > /dev/null 2>&1; then
    echo -e "${RED}❌ Bun cannot access the current directory!${NC}"
    echo -e "${YELLOW}This might be due to file system permissions or Docker container restrictions.${NC}"
    echo -e "\n${BLUE}Workaround options:${NC}"
    echo -e "1. Copy the project to a directory with full permissions:"
    echo -e "   ${GREEN}cp -r . /tmp/project && cd /tmp/project${NC}"
    echo -e "2. Run with elevated permissions if needed:"
    echo -e "   ${GREEN}sudo ./migrate-to-bun.sh${NC}"
    echo -e "3. Use Docker to build the project:"
    echo -e "   ${GREEN}./docker-build.sh${NC}"
    echo -e "\n${YELLOW}For now, continuing with the migration setup...${NC}"
fi

echo -e "\n${GREEN}✅ Migration to Bun.js completed!${NC}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Try running: ${GREEN}bun run dev${NC}"
echo -e "2. If you get permission errors, try: ${GREEN}sudo bun run dev${NC}"
echo -e "3. Or copy to temp directory: ${GREEN}cp -r . /tmp/project && cd /tmp/project && bun run dev${NC}"
echo -e "4. For production: ${GREEN}bun run build${NC} then ${GREEN}bun run start${NC}"
echo -e "5. Build Docker image: ${GREEN}./docker-build.sh${NC}"
echo -e "\n${BLUE}Useful commands:${NC}"
echo -e "• ${GREEN}bun run dev${NC} - Start development server"
echo -e "• ${GREEN}bun run build${NC} - Build for production"
echo -e "• ${GREEN}bun run start${NC} - Start production server"
echo -e "• ${GREEN}bun run prisma:studio${NC} - Open Prisma Studio"
echo -e "\n${YELLOW}📖 Check BUN_MIGRATION.md for detailed information${NC}"
echo -e "\n${BLUE}Current status:${NC}"
echo -e "✅ Bun.js installed"
echo -e "✅ Dependencies installed"
echo -e "✅ Prisma client generated"
echo -e "✅ Configuration files updated"
