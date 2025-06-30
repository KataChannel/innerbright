#!/bin/bash

# Auto Git Push with Build Verification
# This script builds the project first, then commits and pushes if build succeeds

set -e

# Setup Bun PATH - source the helper script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/bun-setup.sh"

# Setup Bun for current session
if ! setup_bun_for_session; then
    exit 1
fi

echo "🔨 Building and testing before git push..."

# Run the test-build script first
if ./test-build.sh; then
    echo "✅ Build successful, proceeding with git operations..."
    
    # Run auto-push with build success message
    MESSAGE="${1:-"Auto-commit after successful build: $(date '+%Y-%m-%d %H:%M:%S')"}"
    ./scripts/auto-push.sh "$MESSAGE"
else
    echo "❌ Build failed, skipping git push"
    echo "💡 Fix the build errors before pushing to git"
    exit 1
fi
