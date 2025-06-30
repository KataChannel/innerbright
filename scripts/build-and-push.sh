#!/bin/bash

# Auto Git Push with Build Verification
# This script builds the project first, then commits and pushes if build succeeds

set -e

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
