#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Building optimized Next.js Docker image with Bun.js...${NC}"

# Build the Docker image
echo -e "${YELLOW}Building Docker image with Bun runtime...${NC}"
docker build -t innerbright-nextjs-bun:latest .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Docker image built successfully with Bun!${NC}"
    
    echo -e "${YELLOW}Image size:${NC}"
    docker images innerbright-nextjs-bun:latest --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
    
    echo -e "${YELLOW}🏃 Running container with Bun runtime...${NC}"
    docker run -d \
        --name innerbright-bun-app \
        -p 3000:3000 \
        -e NODE_ENV=production \
        -e NEXTAUTH_SECRET=your-secret-here \
        -e NEXTAUTH_URL=http://localhost:3000 \
        --restart unless-stopped \
        innerbright-nextjs-bun:latest
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Container started successfully!${NC}"
        echo -e "${GREEN}🌐 Application is running at: http://localhost:3000${NC}"
        echo -e "${GREEN}🏥 Health check available at: http://localhost:3000/api/health${NC}"
        
        echo -e "${YELLOW}Container status:${NC}"
        docker ps --filter name=innerbright-bun-app --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo -e "${RED}❌ Failed to start container${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Failed to build Docker image${NC}"
    exit 1
fi

echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  Stop container: ${GREEN}docker stop innerbright-bun-app${NC}"
echo -e "  Remove container: ${GREEN}docker rm innerbright-bun-app${NC}"
echo -e "  View logs: ${GREEN}docker logs innerbright-bun-app${NC}"
echo -e "  Execute shell: ${GREEN}docker exec -it innerbright-bun-app sh${NC}"
