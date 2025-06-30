#!/bin/bash

# Setup Git Auto-Push Configuration
echo "⚙️  Setting up Git auto-push configuration..."

# Apply git configuration
echo "📝 Applying git configuration..."
git config --local include.path ../.gitconfig-auto

# Set up auto-push for current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "🔧 Setting up auto-push for branch: $CURRENT_BRANCH"

# Set upstream if not already set
if ! git config --get branch.$CURRENT_BRANCH.remote > /dev/null; then
    echo "🔗 Setting upstream for current branch..."
    git push --set-upstream origin $CURRENT_BRANCH
fi

# Enable auto-push configuration
git config --local push.default current
git config --local push.autoSetupRemote true

echo "✅ Git auto-push configuration completed!"
echo ""
echo "📋 Available commands:"
echo "  bun run git:push          - Auto commit and push"
echo "  bun run git:save          - Quick save with timestamp"
echo "  bun run git:build-push    - Build first, then push"
echo "  bun run git:watch         - Auto-commit every 10 minutes"
echo ""
echo "🔧 Direct script usage:"
echo "  ./scripts/auto-push.sh 'Your commit message'"
echo "  ./scripts/quick-save.sh 'Optional message'"
echo "  ./scripts/build-and-push.sh"
echo "  ./scripts/watch-auto-commit.sh 5  # Check every 5 minutes"
