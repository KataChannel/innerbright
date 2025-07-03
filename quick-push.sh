#!/bin/bash

# KataCore Quick Git Push
# Simple one-liner for quick commits and pushes

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get commit message from argument or use default
if [ -z "$1" ]; then
    COMMIT_MESSAGE="Quick update: $(date '+%Y-%m-%d %H:%M:%S')"
else
    COMMIT_MESSAGE="$1"
fi

echo -e "${BLUE}🚀 KataCore Quick Push${NC}"
echo -e "${YELLOW}Message: $COMMIT_MESSAGE${NC}"
echo

# Check if we're in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not a git repository${NC}"
    exit 1
fi

# Add all changes
echo "📝 Adding changes..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo -e "${YELLOW}⚠️  No changes to commit${NC}"
    exit 0
fi

# Commit changes
echo "💾 Committing changes..."
git commit -m "$COMMIT_MESSAGE"

# Push to current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📤 Pushing to $CURRENT_BRANCH..."
git push origin "$CURRENT_BRANCH"

echo -e "${GREEN}✅ Successfully pushed to $CURRENT_BRANCH${NC}"
echo "Latest commit: $(git log --oneline -1)"
