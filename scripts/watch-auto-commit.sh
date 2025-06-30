#!/bin/bash

# Watch mode auto-commit
# Automatically commits changes every X minutes if there are modifications

INTERVAL_MINUTES=${1:-10}  # Default 10 minutes
INTERVAL_SECONDS=$((INTERVAL_MINUTES * 60))

echo "👀 Starting auto-commit watch mode..."
echo "⏰ Will check for changes every $INTERVAL_MINUTES minutes"
echo "🛑 Press Ctrl+C to stop"

while true; do
    if [[ -n $(git status --porcelain) ]]; then
        echo "📝 Changes detected, auto-committing..."
        ./scripts/auto-push.sh "Auto-commit from watch mode: $(date '+%Y-%m-%d %H:%M:%S')"
    else
        echo "✅ No changes detected ($(date '+%H:%M:%S'))"
    fi
    
    sleep $INTERVAL_SECONDS
done
