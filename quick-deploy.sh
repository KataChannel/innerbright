#!/bin/bash

# Quick Deploy - Simplest way to deploy changes
# Usage: ./quick-deploy.sh "commit message"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration  
SERVER="deploy@116.118.85.41"
PROJECT_DIR="/opt/innerbright"

# Get commit message
MSG="${1:-update: $(date '+%Y-%m-%d %H:%M:%S')}"

echo -e "${BLUE}🚀 Quick Deploy: $MSG${NC}"

# Local operations
echo -e "${YELLOW}📝 Local: git add, commit, push...${NC}"
git add .
git commit -m "$MSG"
git push

# Server operations
echo -e "${YELLOW}🔗 Server: pull and update...${NC}"
ssh $SERVER "cd $PROJECT_DIR && git pull && docker compose up --build -d"

echo -e "${GREEN}✅ Deploy completed!${NC}"
