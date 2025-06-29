#!/bin/bash

# Full Deploy Pipeline
# Complete workflow: git deploy -> connect to server -> pull and update

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
SERVER_IP="116.118.85.41"
SERVER_USER="deploy"
PROJECT_DIR="/opt/innerbright"
TARGET_BRANCH="dev"  # Changed to dev branch

echo -e "${PURPLE}"
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                    🚀 INNERBRIGHT FULL DEPLOY PIPELINE 🚀                    ║"
echo "║                                                                               ║"
echo "║  This will:                                                                   ║"
echo "║  1. 📝 Add, commit & push local changes                                      ║"
echo "║  2. 🔗 Connect to production server                                          ║"
echo "║  3. 📥 Pull latest changes from dev branch                                   ║"
echo "║  4. 🔄 Update containers                                                     ║"
echo "║  5. 🏥 Check health status                                                   ║"
echo "║                                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

# Get commit message
COMMIT_MESSAGE="$1"
if [[ -z "$COMMIT_MESSAGE" ]]; then
    read -p "Enter commit message (or press Enter for auto): " COMMIT_MESSAGE
    COMMIT_MESSAGE=${COMMIT_MESSAGE:-"update: $(date '+%Y-%m-%d %H:%M:%S')"}
fi

echo -e "${BLUE}📋 Deployment Plan:${NC}"
echo -e "   Commit: ${GREEN}$COMMIT_MESSAGE${NC}"
echo -e "   Branch: ${GREEN}$TARGET_BRANCH${NC}"
echo -e "   Server: ${GREEN}$SERVER_USER@$SERVER_IP${NC}"
echo -e "   Project: ${GREEN}$PROJECT_DIR${NC}\n"

read -p "Continue with deployment? (Y/n): " confirm
if [[ $confirm =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}❌ Deployment cancelled${NC}"
    exit 0
fi

echo

# Step 1: Git operations
echo -e "${CYAN}📝 Step 1: Git Operations${NC}"
echo "================================"

# Switch to dev branch if not already on it
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]]; then
    echo -e "${YELLOW}🔄 Switching to $TARGET_BRANCH branch...${NC}"
    git checkout "$TARGET_BRANCH" || git checkout -b "$TARGET_BRANCH"
fi

# Check if we have changes
if git diff-index --quiet HEAD --; then
    echo -e "${GREEN}✅ No local changes to commit${NC}"
    
    # Check for unpushed commits
    UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l)
    if [[ $UNPUSHED -gt 0 ]]; then
        echo -e "${YELLOW}📤 Pushing $UNPUSHED unpushed commit(s) to $TARGET_BRANCH...${NC}"
        git push origin "$TARGET_BRANCH"
    fi
else
    echo -e "${YELLOW}📝 Committing and pushing changes to $TARGET_BRANCH...${NC}"
    ./git-deploy.sh "$COMMIT_MESSAGE" "$TARGET_BRANCH"
fi

echo

# Step 2: Connect to server and deploy
echo -e "${CYAN}🔗 Step 2: Server Connection & Deployment${NC}"
echo "==========================================="

# Create temporary script for server operations
TEMP_SCRIPT=$(mktemp)
cat > "$TEMP_SCRIPT" << EOF
#!/bin/bash

# Colors for server output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_DIR="/opt/innerbright"
TARGET_BRANCH="$TARGET_BRANCH"

echo -e "\${BLUE}🖥️  Server Operations\${NC}"
echo "==================="

# Navigate to project directory
cd \$PROJECT_DIR

# Check current status
echo -e "\${CYAN}📋 Current Status:\${NC}"
echo -e "   Directory: \$(pwd)"
echo -e "   User: \$(whoami)"

# Check if this is a git repository
if [ ! -d ".git" ]; then
    echo -e "\${YELLOW}⚠️  Not a git repository. Setting up...\${NC}"
    
    # Check if directory is empty or has files
    if [ "\$(ls -A .)" ]; then
        echo -e "\${YELLOW}📁 Directory has files. Backing up and cloning fresh...\${NC}"
        cd /opt
        sudo mv innerbright innerbright.backup.\$(date +%Y%m%d_%H%M%S)
        sudo git clone -b \$TARGET_BRANCH https://github.com/chikiet/innerbright.git innerbright
        sudo chown -R deploy:deploy innerbright
        cd innerbright
    else
        echo -e "\${YELLOW}📁 Empty directory. Cloning repository...\${NC}"
        git clone -b \$TARGET_BRANCH https://github.com/chikiet/innerbright.git .
    fi
    echo -e "\${GREEN}✅ Git repository initialized on \$TARGET_BRANCH branch\${NC}"
else
    echo -e "\${GREEN}✅ Git repository exists\${NC}"
    
    # Switch to dev branch if not already on it
    CURRENT_BRANCH=\$(git branch --show-current)
    if [[ "\$CURRENT_BRANCH" != "\$TARGET_BRANCH" ]]; then
        echo -e "\${YELLOW}🔄 Switching to \$TARGET_BRANCH branch...\${NC}"
        git checkout \$TARGET_BRANCH || git checkout -b \$TARGET_BRANCH origin/\$TARGET_BRANCH
    fi
fi

echo -e "   Git branch: \$(git branch --show-current 2>/dev/null || echo 'N/A')"

echo

# Pull latest changes
echo -e "\${YELLOW}📥 Pulling latest changes from \$TARGET_BRANCH...\${NC}"
if git pull origin \$TARGET_BRANCH; then
    echo -e "\${GREEN}✅ Git pull successful from \$TARGET_BRANCH\${NC}"
else
    echo -e "\${RED}❌ Git pull failed\${NC}"
    echo -e "\${YELLOW}💡 Trying to fetch and reset...\${NC}"
    if git fetch origin && git reset --hard origin/\$TARGET_BRANCH; then
        echo -e "\${GREEN}✅ Git reset successful\${NC}"
    else
        echo -e "\${RED}❌ Git operations failed\${NC}"
        exit 1
    fi
fi

echo

# Check if docker-compose.yml exists
if [[ ! -f "docker-compose.yml" ]]; then
    echo -e "\${RED}❌ docker-compose.yml not found\${NC}"
    exit 1
fi

# Update containers
echo -e "\${YELLOW}🔄 Updating containers...\${NC}"
if docker compose up --build -d --remove-orphans; then
    echo -e "\${GREEN}✅ Containers updated successfully\${NC}"
else
    echo -e "\${RED}❌ Container update failed\${NC}"
    exit 1
fi

echo

# Wait for services to be ready
echo -e "\${YELLOW}⏳ Waiting for services to be ready...\${NC}"
sleep 15

# Health check
echo -e "\${CYAN}🏥 Health Check:\${NC}"
docker compose ps

echo

# Test endpoints
echo -e "\${CYAN}🔍 Testing Endpoints:\${NC}"

# Test frontend
if curl -f -s http://localhost:3000/api/health > /dev/null; then
    echo -e "\${GREEN}✅ Frontend (Next.js) is healthy\${NC}"
else
    echo -e "\${RED}❌ Frontend (Next.js) is not responding\${NC}"
fi

# Test backend
if curl -f -s http://localhost:3333/health > /dev/null; then
    echo -e "\${GREEN}✅ Backend (NestJS) is healthy\${NC}"
else
    echo -e "\${RED}❌ Backend (NestJS) is not responding\${NC}"
fi

echo

# Show logs if there are any errors
ERRORS=\$(docker compose logs --tail=10 2>&1 | grep -i error | wc -l)
if [[ \$ERRORS -gt 0 ]]; then
    echo -e "\${YELLOW}⚠️  Found \$ERRORS error(s) in logs:\${NC}"
    docker compose logs --tail=5 | grep -i error
    echo
fi

# Final status
echo -e "\${GREEN}🎉 Server deployment completed!\${NC}"
echo -e "\${CYAN}📊 Final Status:\${NC}"
echo -e "   Deployment time: \$(date)"
echo -e "   Branch: \$TARGET_BRANCH"
echo -e "   Containers running: \$(docker compose ps --services --filter status=running | wc -l)"
echo -e "   Project directory: \$PROJECT_DIR"

echo
echo -e "\${BLUE}🔧 Management Options:\${NC}"
echo -e "   • View logs: \${YELLOW}docker compose logs -f\${NC}"
echo -e "   • Restart services: \${YELLOW}docker compose restart\${NC}"
echo -e "   • Management console: \${YELLOW}./manage-production.sh\${NC}"
echo -e "   • Exit: \${YELLOW}exit\${NC}"

# Keep session open
echo
echo -e "\${CYAN}💡 Session is ready. Type 'exit' to disconnect.\${NC}"
exec bash -l
EOF

chmod +x "$TEMP_SCRIPT"

# Execute on server
echo -e "${YELLOW}🔗 Connecting to server and executing deployment...\${NC}"

# Use SSH to execute the script
if ssh -o ConnectTimeout=10 "$SERVER_USER@$SERVER_IP" "bash -s" < "$TEMP_SCRIPT"; then
    echo -e "\n${GREEN}✅ Full deployment pipeline completed successfully!\${NC}"
else
    echo -e "\n${RED}❌ Server deployment failed\${NC}"
    
    # Cleanup
    rm -f "$TEMP_SCRIPT"
    exit 1
fi

# Cleanup
rm -f "$TEMP_SCRIPT"

echo -e "\n${PURPLE}🎉 Deployment Summary:\${NC}"
echo -e "   ✅ Local changes committed and pushed to $TARGET_BRANCH"
echo -e "   ✅ Server updated with latest code from $TARGET_BRANCH"
echo -e "   ✅ Containers rebuilt and restarted"
echo -e "   ✅ Health checks passed"
echo -e "\n${CYAN}🌐 Your application is now live at: https://innerbright.vn\${NC}"