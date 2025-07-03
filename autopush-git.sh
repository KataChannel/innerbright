#!/bin/bash

# KataCore Auto Push Git Script
# Automatically commits and pushes changes to the repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 KataCore Auto Git Push${NC}"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Check if git is configured
if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
    echo -e "${RED}❌ Error: Git user not configured${NC}"
    echo "Please configure git with:"
    echo "  git config --global user.name \"Your Name\""
    echo "  git config --global user.email \"your.email@example.com\""
    exit 1
fi

# Check for changes
if git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  No changes detected${NC}"
    echo "Repository is already up to date"
    exit 0
fi

# Show current status
echo -e "${BLUE}📊 Current git status:${NC}"
git status --short

echo ""

# Get commit message from user or use default
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}💬 Enter commit message (or press Enter for auto-generated message):${NC}"
    read -r commit_message
    
    if [ -z "$commit_message" ]; then
        # Generate automatic commit message based on changes
        timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        modified_files=$(git diff --name-only --cached 2>/dev/null || git diff --name-only)
        num_files=$(echo "$modified_files" | wc -l)
        
        if [ "$num_files" -eq 1 ]; then
            commit_message="Update $(echo "$modified_files" | head -1) - $timestamp"
        else
            commit_message="Update $num_files files - $timestamp"
        fi
        
        echo -e "${BLUE}📝 Auto-generated commit message: $commit_message${NC}"
    fi
else
    commit_message="$*"
fi

# Get current branch
current_branch=$(git branch --show-current)
echo -e "${BLUE}🌿 Current branch: $current_branch${NC}"

# Check if there are any remote repositories
if ! git remote > /dev/null 2>&1; then
    echo -e "${RED}❌ Error: No remote repositories configured${NC}"
    echo "Please add a remote repository first:"
    echo "  git remote add origin <repository-url>"
    exit 1
fi

# Get remote name (usually 'origin')
remote_name=$(git remote | head -1)
echo -e "${BLUE}🔗 Remote: $remote_name${NC}"

# Add all changes
echo -e "${BLUE}📦 Adding all changes...${NC}"
git add .

# Show what will be committed
echo ""
echo -e "${BLUE}📋 Files to be committed:${NC}"
git diff --cached --name-status

echo ""

# Commit changes
echo -e "${BLUE}💾 Committing changes...${NC}"
git commit -m "$commit_message"

# Push to remote
echo -e "${BLUE}🚀 Pushing to $remote_name/$current_branch...${NC}"

# Check if upstream is set
if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  No upstream branch set, setting upstream...${NC}"
    git push --set-upstream "$remote_name" "$current_branch"
else
    git push
fi

echo ""
echo -e "${GREEN}✅ Successfully pushed changes!${NC}"

# Show the latest commit
echo ""
echo -e "${BLUE}📝 Latest commit:${NC}"
git log -1 --oneline

# Show remote URL
remote_url=$(git remote get-url "$remote_name")
echo ""
echo -e "${BLUE}🔗 Repository URL: $remote_url${NC}"

# Optional: Open repository in browser (if running in a GUI environment)
if command -v xdg-open &> /dev/null && [ -n "$DISPLAY" ]; then
    echo ""
    read -p "Open repository in browser? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Convert SSH URL to HTTPS for browser
        if [[ $remote_url == git@* ]]; then
            browser_url=$(echo "$remote_url" | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/\.git$//')
        else
            browser_url="$remote_url"
        fi
        xdg-open "$browser_url" 2>/dev/null &
    fi
fi

echo ""
echo -e "${GREEN}🎉 Auto push completed successfully!${NC}"