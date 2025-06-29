#!/bin/bash

# Test Build - Test docker build locally before deploying
# Usage: ./test-build.sh

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🧪 Testing Docker Build Locally${NC}"
echo "================================="

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

# Clean up previous builds
echo -e "${YELLOW}🧹 Cleaning up previous builds...${NC}"
docker system prune -f > /dev/null 2>&1 || true

# Test API build
echo -e "${YELLOW}🔨 Testing API build...${NC}"
if docker build -t innerbright-api-test ./api; then
    echo -e "${GREEN}✅ API build successful${NC}"
else
    echo -e "${RED}❌ API build failed${NC}"
    exit 1
fi

# Test Site build  
echo -e "${YELLOW}🔨 Testing Site build...${NC}"
if docker build -t innerbright-site-test ./site; then
    echo -e "${GREEN}✅ Site build successful${NC}"
else
    echo -e "${RED}❌ Site build failed${NC}"
    exit 1
fi

# Test docker-compose build
echo -e "${YELLOW}🔨 Testing Docker Compose build...${NC}"
if docker compose build; then
    echo -e "${GREEN}✅ Docker Compose build successful${NC}"
else
    echo -e "${RED}❌ Docker Compose build failed${NC}"
    exit 1
fi

# Clean up test images
echo -e "${YELLOW}🧹 Cleaning up test images...${NC}"
docker rmi innerbright-api-test innerbright-site-test > /dev/null 2>&1 || true

echo -e "${GREEN}🎉 All builds passed! Ready for deployment.${NC}"
