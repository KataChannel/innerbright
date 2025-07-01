#!/bin/bash

# Auto Git Push Script for KataCore
# This script automatically commits and pushes changes to git

set -e  # Exit on any error

# Setup Bun PATH if needed
if ! command -v bun &> /dev/null; then
    if [[ -f "$HOME/.bun/bin/bun" ]]; then
        export PATH="$HOME/.bun/bin:$PATH"
        echo "🔧 Added Bun to PATH for this session"
    else
        echo "❌ Error: Bun not found! Please install Bun first."
        echo "💡 Run: curl -fsSL https://bun.sh/install | bash"
        exit 1
    fi
fi

echo "🚀 Starting auto git push for KataCore..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository!"
    exit 1
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Check for uncommitted changes
if [[ -n $(git status --porcelain) ]]; then
    echo "📝 Found uncommitted changes, adding them..."
    
    # Add all changes
    git add .
    
    # Get commit message from parameter or use default
    COMMIT_MSG="${1:-"Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"}"
    
    echo "💾 Committing with message: $COMMIT_MSG"
    git commit -m "$COMMIT_MSG"
else
    echo "✅ No uncommitted changes found"
fi

# Check if we're ahead of remote
if git status | grep -q "Your branch is ahead"; then
    echo "⬆️  Pushing changes to remote..."
    git push origin "$CURRENT_BRANCH"
    echo "✅ Successfully pushed to origin/$CURRENT_BRANCH"
else
    echo "✅ Already up to date with remote"
fi

echo "🎉 Auto git push completed successfully!"
