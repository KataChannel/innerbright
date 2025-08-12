#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting ULTRA-MINIMAL deployment for 2GB server...${NC}"

# Git operations
echo -e "${GREEN}📝 Adding files to git...${NC}"
git add .

echo -e "${GREEN}💾 Committing changes...${NC}"
git commit -m "🔧 Ultra-minimal deployment for 2GB server - $(date)" || {
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

# SSH and deploy with ULTRA-MINIMAL optimizations
echo -e "${GREEN}🐳 Connecting to server (ULTRA-MINIMAL mode for 2GB)...${NC}"
ssh root@116.118.48.208 << 'EOF'
    set -e
    cd /opt/innerbright
    
    echo "📥 Pulling latest changes..."
    git pull
    
    echo "💾 Checking system resources..."
    free -h
    df -h / | tail -1
    echo "Load: $(cat /proc/loadavg)"
    
    echo "🛑 Stopping ALL services to maximize memory..."
    docker compose -f docker-compose.minimal.yml down || true
    docker compose down || true
    
    echo "🧹 EXTREME cleanup..."
    docker system prune -af --volumes || true
    docker builder prune -af || true
    docker image prune -af || true
    
    # Create swap if needed
    if [ ! -f /swapfile ] && [ $(free | grep Swap | awk '{print $2}') -eq 0 ]; then
        echo "📦 Creating 1GB swap for build..."
        fallocate -l 1G /swapfile 2>/dev/null || dd if=/dev/zero of=/swapfile bs=1M count=1024
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo "✅ Swap enabled"
    fi
    
    # Clear caches
    sync && echo 3 > /proc/sys/vm/drop_caches
    
    echo "💾 Memory after cleanup:"
    free -h
    
    echo "🔨 Building with ULTRA-MINIMAL settings..."
    export DOCKER_BUILDKIT=0
    export COMPOSE_DOCKER_CLI_BUILD=0
    
    # Start PostgreSQL first (minimal)
    echo "🐘 Starting minimal PostgreSQL..."
    docker compose -f docker-compose.minimal.yml up -d postgres
    sleep 30
    
    echo "🏗️ Building with 600MB memory limit..."
    docker compose -f docker-compose.minimal.yml build site --memory=600m
    
    echo "🚀 Starting application..."
    docker compose -f docker-compose.minimal.yml up -d site
    
    echo "⏳ Waiting for startup (3 minutes)..."
    sleep 180
    
    echo "🔍 Status check..."
    docker compose -f docker-compose.minimal.yml ps
    docker stats --no-stream
    
    echo "📋 Logs check..."
    docker compose -f docker-compose.minimal.yml logs --tail=5 site
    
    # Disable swap after successful build
    if [ -f /swapfile ]; then
        echo "🗑️ Removing temporary swap..."
        swapoff /swapfile || true
        rm -f /swapfile || true
    fi
    
    echo "✅ Ultra-minimal deployment completed!"
EOF

echo -e "${GREEN}🎉 Ultra-minimal deployment finished!${NC}"

# Health check
echo -e "${BLUE}🔍 Final health check...${NC}"
sleep 30
if curl -f -s -o /dev/null "http://116.118.48.208:3000" 2>/dev/null; then
    echo -e "${GREEN}✅ Service is responding!${NC}"
else
    echo -e "${YELLOW}⚠️  Service may still be starting. Please check manually.${NC}"
fi
