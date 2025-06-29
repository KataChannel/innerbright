#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting development environment with Docker Compose...${NC}"

# Check if docker-compose.yml exists
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ docker-compose.yml not found${NC}"
    exit 1
fi

# Build and start services
echo -e "${YELLOW}Building and starting services...${NC}"
docker-compose up --build -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Services started successfully!${NC}"
    
    echo -e "${YELLOW}Service status:${NC}"
    docker-compose ps
    
    echo -e "${GREEN}🌐 Application URLs:${NC}"
    echo -e "  Next.js App: ${GREEN}http://localhost:3000${NC}"
    echo -e "  Health Check: ${GREEN}http://localhost:3000/api/health${NC}"
    echo -e "  Database: ${GREEN}postgresql://postgres:password@localhost:5432/innerbright${NC}"
    
    echo -e "${YELLOW}Useful commands:${NC}"
    echo -e "  View logs: ${GREEN}docker-compose logs -f${NC}"
    echo -e "  Stop services: ${GREEN}docker-compose down${NC}"
    echo -e "  Restart services: ${GREEN}docker-compose restart${NC}"
    echo -e "  Execute shell in app: ${GREEN}docker-compose exec nextjs sh${NC}"
    echo -e "  Execute shell in db: ${GREEN}docker-compose exec postgres psql -U postgres -d innerbright${NC}"
else
    echo -e "${RED}❌ Failed to start services${NC}"
    exit 1
fi
