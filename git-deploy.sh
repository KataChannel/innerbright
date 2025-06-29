#!/bin/bash

# Auto Git Deploy Script
# Automatically add, commit, and push changes to git repository

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
DEFAULT_COMMIT_MESSAGE="update: $(date '+%Y-%m-%d %H:%M:%S')"

echo -e "${BLUE}🚀 Auto Git Deploy${NC}\n"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Check for uncommitted changes
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  No changes to commit${NC}"
    
    # Still offer to push if we have unpushed commits
    UNPUSHED=$(git log @{u}.. --oneline 2>/dev/null | wc -l)
    if [[ $UNPUSHED -gt 0 ]]; then
        echo -e "${CYAN}📤 Found $UNPUSHED unpushed commit(s)${NC}"
        read -p "Push to remote? (Y/n): " push_only
        if [[ ! $push_only =~ ^[Nn]$ ]]; then
            echo -e "${YELLOW}📤 Pushing to remote...${NC}"
            git push
            echo -e "${GREEN}✅ Push completed${NC}"
        fi
    else
        echo -e "${GREEN}✅ Repository is up to date${NC}"
    fi
    exit 0
fi

# Show status
echo -e "${CYAN}📋 Git Status:${NC}"
git status --short

echo

# Get commit message
if [[ -n "$1" ]]; then
    COMMIT_MESSAGE="$1"
else
    read -p "Enter commit message (or press Enter for default): " COMMIT_MESSAGE
    COMMIT_MESSAGE=${COMMIT_MESSAGE:-$DEFAULT_COMMIT_MESSAGE}
fi

echo -e "\n${YELLOW}🔄 Processing git operations...${NC}"

# Add all changes
echo -e "${CYAN}📝 Adding all changes...${NC}"
git add .

# Show what will be committed
echo -e "\n${CYAN}📋 Files to be committed:${NC}"
git diff --cached --name-status

echo

# Commit changes
echo -e "${CYAN}💾 Committing changes...${NC}"
git commit -m "$COMMIT_MESSAGE"

# Push to remote
echo -e "${CYAN}📤 Pushing to remote...${NC}"
CURRENT_BRANCH=$(git branch --show-current)
git push origin $CURRENT_BRANCH

echo -e "\n${GREEN}✅ Git operations completed successfully!${NC}"
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "   Commit: $COMMIT_MESSAGE"
echo -e "   Branch: $CURRENT_BRANCH"
echo -e "   Files: $(git diff HEAD~1 --name-only | wc -l) changed"

# Show recent commits
echo -e "\n${CYAN}📈 Recent commits:${NC}"
git log --oneline -5

echo -e "\n${GREEN}🎉 All done!${NC}"
