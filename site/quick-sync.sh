#!/bin/bash

# =============================================================================
# Quick Sync Script for Fast Deployment
# Optimized for frequent development deployments
# =============================================================================

set -euo pipefail

readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Configuration
CLOUD_USER="${CLOUD_USER:-root}"
CLOUD_HOST="${CLOUD_HOST:-your-server.com}"
CLOUD_PATH="${CLOUD_PATH:-/var/www/innerbright/site}"
SSH_KEY="${SSH_KEY:-~/.ssh/id_rsa}"

echo -e "${BLUE}⚡ Quick Sync Deployment${NC}"

# Build only if needed
if [ ! -d ".next/standalone" ] || [ ! -d ".next/static" ]; then
    echo -e "${YELLOW}🏗️  Building standalone...${NC}"
    ./build-standalone-optimized.sh
fi

# Quick sync essential files only
echo -e "${YELLOW}📤 Quick sync to server...${NC}"

# Sync standalone app
rsync -avz --delete --progress \
    -e "ssh -i $SSH_KEY" \
    .next/standalone/ \
    "$CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/"

# Sync static assets
rsync -avz --delete --progress \
    -e "ssh -i $SSH_KEY" \
    .next/static/ \
    "$CLOUD_USER@$CLOUD_HOST:$CLOUD_PATH/.next/static/"

# Restart container
echo -e "${YELLOW}🔄 Restarting container...${NC}"
ssh -i "$SSH_KEY" "$CLOUD_USER@$CLOUD_HOST" "
    cd $CLOUD_PATH
    docker restart innerbright-site 2>/dev/null || {
        docker stop innerbright-site 2>/dev/null || true
        docker rm innerbright-site 2>/dev/null || true
        docker run -d --name innerbright-site --restart unless-stopped -p 3000:3000 innerbright-site:latest
    }
"

echo -e "${GREEN}✅ Quick sync completed!${NC}"
