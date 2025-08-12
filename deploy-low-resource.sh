#!/bin/bash

# Exit on error
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting LOW-RESOURCE optimized deployment process...${NC}"

# Git operations
echo -e "${GREEN}📝 Adding files to git...${NC}"
git add .

echo -e "${GREEN}💾 Committing changes...${NC}"
git commit -m "🔧 Low-resource deployment optimization - $(date)" || {
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

# SSH and deploy with LOW-RESOURCE optimizations
echo -e "${GREEN}🐳 Connecting to server and deploying (LOW-RESOURCE mode)...${NC}"
ssh root@116.118.48.208 << 'EOF'
    set -e
    cd /opt/innerbright
    
    echo "📥 Pulling latest changes..."
    git pull
    
    echo "💾 Checking system resources..."
    df -h / | tail -1
    free -h
    echo "CPU info:"
    nproc
    cat /proc/loadavg
    
    echo "🛑 Stopping all services first to free up memory..."
    docker compose -f docker-compose.low-resource.yml down || true
    
    echo "🧹 Aggressive cleanup for low-resource environment..."
    # More aggressive cleanup for low-resource servers
    docker system prune -af --volumes || true
    docker builder prune -af || true
    
    # Create temporary swap if not exists (for build process)
    if [ ! -f /swapfile ]; then
        echo "📦 Creating temporary swap for build process..."
        fallocate -l 1G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=1024
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        echo "✅ Temporary swap created"
    fi
    
    # Clear swap if any
    sync && echo 3 > /proc/sys/vm/drop_caches || true
    
    echo "💾 Memory status after cleanup:"
    free -h
    
    echo "🔨 Building with EXTREME resource optimization..."
    # Sequential build to avoid memory pressure
    # Set memory limits for docker daemon
    export DOCKER_BUILDKIT=0  # Disable buildkit to save memory
    export COMPOSE_DOCKER_CLI_BUILD=0
    
    # Build only essential services first
    # echo "🐘 Starting PostgreSQL first..."
    # docker compose -f docker-compose.low-resource.yml up -d postgres
    
    # echo "⏳ Waiting for PostgreSQL to be ready..."
    # sleep 20
    
    # echo "🔴 Starting Redis..."
    # docker compose -f docker-compose.low-resource.yml up -d redis
    
    # echo "⏳ Waiting for Redis to be ready..."
    # sleep 10
    
    echo "🏗️ Building application with EXTREME memory limits..."
    # Build with reduced parallelism and memory limits for 2GB server
    docker compose -f docker-compose.low-resource.yml build site --memory=800m --cpus=0.5
    
    echo "🚀 Starting main application..."
    docker compose -f docker-compose.low-resource.yml up -d site
    
    echo "⏳ Waiting for application to be ready..."
    sleep 60
    
    echo "🔍 Checking container health..."
    docker compose -f docker-compose.low-resource.yml ps
    docker stats --no-stream
    
    echo "📋 Checking application logs..."
    docker compose -f docker-compose.low-resource.yml logs --tail=10 site
    
    echo "✅ Low-resource deployment completed successfully!"
EOF

echo -e "${GREEN}🎉 Low-resource deployment finished!${NC}"
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
