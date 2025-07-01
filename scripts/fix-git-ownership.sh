#!/bin/bash

# Git Ownership and Safe Directory Fix Script for KataCore
# This script fixes common Git ownership and safe directory issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging functions
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✅ $1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

log "🔧 Fixing Git ownership and safe directory issues for KataCore..."

# Get current directory
REPO_PATH=$(pwd)
log "Repository path: $REPO_PATH"

# Check if we're in a Git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not in a Git repository!"
fi

# Remove any existing problematic safe.directory entries
log "Cleaning up existing safe.directory configurations..."
git config --global --unset-all safe.directory 2>/dev/null || true

# Add the current repository path as safe directory
log "Adding repository as safe directory..."
git config --global --add safe.directory "$REPO_PATH"

# Apply Git configuration from .gitconfig-auto if it exists
if [[ -f ".gitconfig-auto" ]]; then
    log "Applying Git configuration from .gitconfig-auto..."
    git config --global include.path "$REPO_PATH/.gitconfig-auto"
else
    log "Setting up basic Git configuration..."
    # Set up basic configuration
    git config --global push.default current
    git config --global push.autoSetupRemote true
    git config --global branch.autosetupmerge always
    git config --global fetch.prune true
fi

# Test Git functionality
log "Testing Git functionality..."
if git status > /dev/null 2>&1; then
    success "Git is working correctly!"
else
    error "Git is still not working properly"
fi

# Show current Git configuration
log "Current Git safe directories:"
git config --global --get-all safe.directory || echo "No safe directories configured"

success "Git ownership and safe directory issues have been fixed!"
success "You can now use Git commands normally."

# Additional helpful information
echo ""
log "💡 Helpful Git commands for KataCore:"
echo "  bun run git:save     # Quick save with timestamp"
echo "  bun run git:push     # Auto commit and push"
echo "  ./scripts/auto-push.sh 'Your message'  # Custom commit message"
