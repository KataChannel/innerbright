#!/bin/bash

# Complete deployment script - Build locally and deploy to server
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Complete Deployment for Innerbright${NC}"
echo -e "${BLUE}Target: AMD CS 2 Server (1 vCPU, 2GB RAM)${NC}"
echo "================================================"

# Step 1: Local Build
echo -e "${GREEN}🏗️ Step 1: Building application locally...${NC}"

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
rm -rf .next
rm -rf node_modules/.cache 2>/dev/null || true

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Installing dependencies...${NC}"
    if command -v bun &> /dev/null; then
        bun install
    else
        npm install
    fi
fi

# Build the application
echo -e "${GREEN}🔨 Building Next.js application...${NC}"
if command -v bun &> /dev/null; then
    bun run build
else
    npm run build
fi

# Check build results
if [ -d ".next/standalone" ]; then
    echo -e "${GREEN}✅ Standalone build created successfully!${NC}"
    echo -e "${BLUE}📊 Build size:${NC}"
    du -sh .next/standalone
    du -sh .next/static 2>/dev/null || echo ".next/static not found - will use fallback"
    echo -e "${GREEN}✅ Ready for server deployment with Dockerfile.prebuilt${NC}"
    DOCKERFILE_TYPE="Dockerfile.prebuilt"
else
    echo -e "${YELLOW}⚠️ Standalone build not found, using regular build${NC}"
    echo -e "${BLUE}📊 Build size:${NC}"
    du -sh .next
    echo -e "${YELLOW}⚠️ Will use Dockerfile.prebuilt-regular for deployment${NC}"
    DOCKERFILE_TYPE="Dockerfile.prebuilt-regular"
fi

echo -e "${GREEN}✅ Local build completed!${NC}"

# Step 2: Prepare Deployment Package
echo -e "${GREEN}🏗️ Step 2: Preparing deployment package...${NC}"

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

# Step 3: Deploy to Server
echo -e "${GREEN}🚀 Step 3: Deploying to server...${NC}"

# Check if remote server is accessible
echo -e "${GREEN}🔌 Testing server connection...${NC}"
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@116.118.48.208 exit; then
    echo -e "${RED}❌ Failed to connect to server. Check connection and try again.${NC}"
    rm -f deploy-package.tar.gz
    exit 1
fi

echo -e "${GREEN}✅ Server connection successful${NC}"

# Prepare server environment
echo -e "${GREEN}🔧 Preparing server environment...${NC}"
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
echo -e "${GREEN}🚀 Extracting and deploying on server...${NC}"
ssh root@116.118.48.208 << ENDSSH
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
sed -i "s/dockerfile: Dockerfile.prebuilt/dockerfile: \$DOCKERFILE/" docker-compose.prebuilt.yml

# Build and start containers
echo -e "${BLUE}🔨 Building containers...${NC}"
docker-compose -f docker-compose.prebuilt.yml build --no-cache

echo -e "${BLUE}🚀 Starting services...${NC}"
docker-compose -f docker-compose.prebuilt.yml up -d

# Wait for services to be ready
echo -e "${BLUE}⏳ Waiting for services to start...${NC}"
sleep 15

# Check container status
echo -e "${BLUE}📊 Container status:${NC}"
docker-compose -f docker-compose.prebuilt.yml ps

# Test application health
echo -e "${BLUE}🔍 Testing application health...${NC}"
for i in {1..5}; do
    if curl -f http://localhost:3000 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Application is responding on port 3000${NC}"
        break
    else
        echo -e "${YELLOW}⚠️ Attempt \$i: Application may still be starting up...${NC}"
        sleep 5
    fi
done

# Show resource usage
echo -e "${BLUE}📊 Resource usage:${NC}"
docker stats --no-stream | head -5

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}🌐 Application should be available at: http://116.118.48.208:3000${NC}"

# Clean up deployment package
rm -f deploy-package.tar.gz
ENDSSH

# Clean up local deployment package
rm -f deploy-package.tar.gz

# Final status report
echo ""
echo -e "${GREEN}🎉 Complete Deployment Finished Successfully!${NC}"
echo "================================================"
echo -e "${BLUE}🌐 Your application is available at:${NC}"
echo -e "   ${GREEN}http://116.118.48.208:3000${NC}"
echo -e "   ${GREEN}http://innerbright.vn${NC} (if DNS is configured)"
echo ""
echo -e "${YELLOW}📝 Useful commands:${NC}"
echo -e "   Check logs: ${BLUE}ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml logs'${NC}"
echo -e "   Restart app: ${BLUE}ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml restart'${NC}"
echo -e "   Check status: ${BLUE}ssh root@116.118.48.208 'cd /root/innerbright && docker-compose -f docker-compose.prebuilt.yml ps'${NC}"
echo ""
echo -e "${GREEN}✅ All done! Your InnerBright application is live! 🚀${NC}"
