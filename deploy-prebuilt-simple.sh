#!/bin/bash

# Simple pre-built deployment without git complications
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Simple Pre-built Deployment for Innerbright${NC}"
echo -e "${BLUE}Target: AMD CS 2 Server (1 vCPU, 2GB RAM)${NC}"
echo "================================================"

# Validate local build exists
if [ ! -d ".next/standalone" ]; then
    echo -e "${RED}❌ Error: .next/standalone not found!${NC}"
    echo -e "${YELLOW}💡 Run './build-local.sh' first to build the application locally${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Pre-built files found locally${NC}"
echo -e "${BLUE}📊 Build size:${NC}"
du -sh .next/standalone
du -sh .next/static 2>/dev/null || echo ".next/static not found - will use fallback"

# Create deployment archive
echo -e "${BLUE}📦 Creating deployment archive...${NC}"
tar -czf deploy-package.tar.gz \
    .next/ \
    package.json \
    next.config.ts \
    public/ \
    Dockerfile.prebuilt* \
    docker-compose.prebuilt.yml \
    prisma/ \
    2>/dev/null || echo "Some files may be missing, continuing..."

echo -e "${GREEN}✅ Archive created: deploy-package.tar.gz${NC}"

# Check if remote server is accessible
echo -e "${GREEN}🔌 Testing server connection...${NC}"
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@116.118.48.208 exit; then
    echo -e "${RED}❌ Failed to connect to server. Check connection and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Server connection successful${NC}"

# Deploy to server
echo -e "${GREEN}🚀 Deploying to server...${NC}"
ssh root@116.118.48.208 << 'ENDSSH'
set -e

# Colors for remote output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}📍 Starting deployment on server...${NC}"

# Navigate to project directory
cd /root/innerbright

# Stop existing containers
echo -e "${BLUE}🛑 Stopping existing containers...${NC}"
docker-compose -f docker-compose.prebuilt.yml down 2>/dev/null || echo "No containers to stop"

# Clean up old build artifacts
echo -e "${BLUE}🧹 Cleaning old artifacts...${NC}"
rm -rf .next/ deploy-package.tar.gz 2>/dev/null || true

echo -e "${GREEN}✅ Server preparation complete${NC}"
ENDSSH

# Copy deployment package to server
echo -e "${BLUE}📤 Uploading deployment package...${NC}"
scp deploy-package.tar.gz root@116.118.48.208:/root/innerbright/

# Extract and deploy on server
ssh root@116.118.48.208 << 'ENDSSH'
set -e

# Colors for remote output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}📦 Extracting deployment package...${NC}"
cd /root/innerbright
tar -xzf deploy-package.tar.gz

# Choose the right Dockerfile based on build type
if [ -d ".next/standalone" ]; then
    echo -e "${GREEN}✅ Using standalone build with Dockerfile.prebuilt${NC}"
    DOCKERFILE="Dockerfile.prebuilt"
else
    echo -e "${YELLOW}⚠️ Using regular build with Dockerfile.prebuilt-regular${NC}"
    DOCKERFILE="Dockerfile.prebuilt-regular"
fi

# Update docker-compose to use the correct Dockerfile
sed -i "s/dockerfile: Dockerfile.prebuilt/dockerfile: $DOCKERFILE/" docker-compose.prebuilt.yml

# Build and start containers
echo -e "${BLUE}🔨 Building containers...${NC}"
docker-compose -f docker-compose.prebuilt.yml build --no-cache

echo -e "${BLUE}🚀 Starting services...${NC}"
docker-compose -f docker-compose.prebuilt.yml up -d

# Wait for services to be ready
echo -e "${BLUE}⏳ Waiting for services to start...${NC}"
sleep 10

# Check container status
echo -e "${BLUE}📊 Container status:${NC}"
docker-compose -f docker-compose.prebuilt.yml ps

# Test application health
echo -e "${BLUE}🔍 Testing application health...${NC}"
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Application is responding on port 3000${NC}"
else
    echo -e "${YELLOW}⚠️ Application may still be starting up...${NC}"
fi

# Show resource usage
echo -e "${BLUE}📊 Resource usage:${NC}"
docker stats --no-stream

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}🌐 Application should be available at: http://116.118.48.208:3000${NC}"

# Clean up deployment package
rm -f deploy-package.tar.gz
ENDSSH

# Clean up local deployment package
rm -f deploy-package.tar.gz

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}🌐 Your application is available at: http://116.118.48.208:3000${NC}"
echo -e "${YELLOW}📝 To check logs: ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml logs'${NC}"
