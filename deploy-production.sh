#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="innerbright"
COMPOSE_FILE="docker-compose.yml"

echo -e "${BLUE}🚀 Deploying ${PROJECT_NAME} to production...${NC}"

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from template...${NC}"
    cp .env.example .env
    echo -e "${RED}❌ Please update .env file with production values and run again${NC}"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Pull latest images
echo -e "${YELLOW}📥 Pulling latest base images...${NC}"
docker-compose pull postgres minio nginx redis 2>/dev/null || true

# Build and start services
echo -e "${YELLOW}🔨 Building and starting services...${NC}"
docker-compose up --build -d --remove-orphans

# Wait for services to be healthy
echo -e "${YELLOW}⏳ Waiting for services to be healthy...${NC}"
sleep 30

# Check service health
echo -e "${YELLOW}🏥 Checking service health...${NC}"

services=("postgres" "nextjs" "nestjs" "minio")
all_healthy=true

for service in "${services[@]}"; do
    if docker-compose ps $service | grep -q "healthy\|running"; then
        echo -e "${GREEN}✅ $service is healthy${NC}"
    else
        echo -e "${RED}❌ $service is not healthy${NC}"
        all_healthy=false
    fi
done

if [ "$all_healthy" = true ]; then
    echo -e "${GREEN}🎉 All services are healthy!${NC}"
    
    echo -e "${BLUE}📋 Service Information:${NC}"
    echo -e "  🌐 Frontend: ${GREEN}http://localhost:3000${NC}"
    echo -e "  🔧 API: ${GREEN}http://localhost:3333${NC}"
    echo -e "  🗄️  Database: ${GREEN}postgresql://localhost:5432/innerbright${NC}"
    echo -e "  📦 MinIO: ${GREEN}http://localhost:9000${NC}"
    echo -e "  🔍 PgAdmin: ${GREEN}http://localhost:5050${NC}"
    
    echo -e "${BLUE}🔧 Useful commands:${NC}"
    echo -e "  View logs: ${GREEN}docker-compose logs -f${NC}"
    echo -e "  Stop: ${GREEN}docker-compose down${NC}"
    echo -e "  Restart: ${GREEN}docker-compose restart${NC}"
    echo -e "  Update: ${GREEN}./deploy-production.sh${NC}"
    
else
    echo -e "${RED}❌ Some services are not healthy. Check logs:${NC}"
    echo -e "  ${YELLOW}docker-compose logs${NC}"
    exit 1
fi

# Show resource usage
echo -e "${BLUE}📊 Resource Usage:${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
