#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting PRE-BUILT deployment for 2GB server...${NC}"

# Build locally first
echo -e "${GREEN}🏗️ Building application locally...${NC}"
if [ ! -d ".next" ]; then
    echo -e "${YELLOW}⚠️ No .next directory found. Building locally...${NC}"
    npm run build || bun run build
else
    echo -e "${BLUE}ℹ️ Using existing .next build directory${NC}"
fi

# Check if standalone build exists
if [ -d ".next/standalone" ]; then
    echo -e "${GREEN}✅ Standalone build found${NC}"
    BUILD_TYPE="standalone"
else
    echo -e "${YELLOW}⚠️ Using regular build (no standalone)${NC}"
    BUILD_TYPE="regular"
fi

# Git operations
echo -e "${GREEN}📝 Adding files to git...${NC}"
git add .

echo -e "${GREEN}💾 Committing changes...${NC}"
git commit -m "🔧 Pre-built deployment optimization - $(date)" || {
    echo -e "${YELLOW}ℹ️ No changes to commit${NC}"
}

echo -e "${GREEN}📤 Pushing to remote...${NC}"
git push

# Check if remote server is accessible
echo -e "${GREEN}🔌 Testing server connection...${NC}"
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes root@116.118.48.208 exit; then
    echo -e "${RED}❌ Failed to connect to server. Check connection and try again.${NC}"
    exit 1
fi

# SSH and deploy with PRE-BUILT optimizations
echo -e "${GREEN}🐳 Connecting to server and deploying (PRE-BUILT mode)...${NC}"
ssh root@116.118.48.208 << 'EOF'
    set -e
    cd /opt/innerbright
    
    echo "📥 Pulling latest changes (including pre-built files)..."
    git pull
    
    echo "💾 Checking system resources..."
    df -h / | tail -1
    free -h
    echo "CPU info:"
    nproc
    cat /proc/loadavg
    
    echo "🛑 Stopping all services..."
    docker compose -f docker-compose.prebuilt.yml down || true
    
    echo "🧹 Cleanup docker resources..."
    docker system prune -af --volumes || true
    
    echo "💾 Memory status after cleanup:"
    free -h
    
    echo "🚀 Starting services with pre-built files..."
    # No build needed - just start services
    docker compose -f docker-compose.prebuilt.yml up -d
    
    echo "⏳ Waiting for services to be ready..."
    sleep 45
    
    echo "🔍 Checking container health..."
    docker compose -f docker-compose.prebuilt.yml ps
    docker stats --no-stream
    
    echo "📋 Checking application logs..."
    docker compose -f docker-compose.prebuilt.yml logs --tail=10 site
    
    echo "✅ Pre-built deployment completed successfully!"
EOF

echo -e "${GREEN}🎉 Pre-built deployment finished!${NC}"
echo -e "${BLUE}🔍 Checking service status...${NC}"

# Quick health check
if curl -f -s -o /dev/null "http://116.118.48.208:3000" 2>/dev/null; then
    echo -e "${GREEN}✅ Service is healthy and responding${NC}"
else
    echo -e "${YELLOW}⚠️  Service might still be starting up. Checking again in 30 seconds...${NC}"
    sleep 30
    if curl -f -s -o /dev/null "http://116.118.48.208:3000" 2>/dev/null; then
        echo -e "${GREEN}✅ Service is now healthy and responding${NC}"
    else
        echo -e "${RED}❌ Service is not responding. Please check logs manually.${NC}"
    fi
fi
