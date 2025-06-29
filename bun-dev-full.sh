#!/bin/bash

# Full Development Environment with Bun
# This script starts both API and Site in development mode

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🚀 Innerbright Development Environment with Bun${NC}"
echo -e "${BLUE}===============================================${NC}\n"

# Export PATH for bun
export PATH="$HOME/.bun/bin:$PATH"

# Check if bun is available
if ! command -v bun &> /dev/null; then
    echo -e "${RED}❌ Bun is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install Bun first: curl -fsSL https://bun.sh/install | bash${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Bun version: $(bun --version)${NC}\n"

# Function to start API
start_api() {
    echo -e "${CYAN}🔧 Starting NestJS API with Bun...${NC}"
    cd api
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}📦 Installing API dependencies...${NC}"
        bun install
    fi
    
    # Start in development mode
    echo -e "${GREEN}🚀 Starting API on port 3333...${NC}"
    bun run start:dev &
    API_PID=$!
    cd ..
}

# Function to start Site
start_site() {
    echo -e "${CYAN}🎨 Starting Next.js Site with Bun...${NC}"
    cd site
    
    # Install dependencies if node_modules doesn't exist
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}📦 Installing Site dependencies...${NC}"
        bun install
    fi
    
    # Generate Prisma client if needed
    if [ -f "prisma/schema.prisma" ]; then
        echo -e "${YELLOW}🗄️  Generating Prisma client...${NC}"
        bun run prisma:generate
    fi
    
    # Start in development mode
    echo -e "${GREEN}🚀 Starting Site on port 3000...${NC}"
    bun run dev &
    SITE_PID=$!
    cd ..
}

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}🛑 Shutting down development servers...${NC}"
    if [ ! -z "$API_PID" ]; then
        kill $API_PID 2>/dev/null
    fi
    if [ ! -z "$SITE_PID" ]; then
        kill $SITE_PID 2>/dev/null
    fi
    echo -e "${GREEN}✅ Development servers stopped${NC}"
    exit 0
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Start services
start_api
sleep 3
start_site

echo -e "\n${GREEN}🎉 Development environment started!${NC}"
echo -e "${CYAN}📋 Service URLs:${NC}"
echo -e "   🎨 Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "   🔧 API: ${GREEN}http://localhost:3333${NC}"
echo -e "   🏥 API Health: ${GREEN}http://localhost:3333/health${NC}"

echo -e "\n${BLUE}💡 Useful commands:${NC}"
echo -e "   • View API logs: ${YELLOW}cd api && bun run start:dev${NC}"
echo -e "   • View Site logs: ${YELLOW}cd site && bun run dev${NC}"
echo -e "   • Stop all: ${YELLOW}Ctrl+C${NC}"

echo -e "\n${YELLOW}Press Ctrl+C to stop all services${NC}"

# Wait for processes to finish
wait
