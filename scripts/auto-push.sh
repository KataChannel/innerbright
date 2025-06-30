#!/bin/bash

# Auto Git Push Script for KataCore
# This script automatically commits and pushes changes to git

set -e  # Exit on any error

# Setup Bun PATH - source the helper script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bun-setup.sh"

# Setup Bun for current session
if ! setup_bun_for_session; then
    exit 1
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
