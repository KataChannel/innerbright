#!/bin/bash

# Quick Save Script - Auto commit and push with timestamp
# Usage: ./scripts/quick-save.sh [optional-message]

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MESSAGE="${1:-"Quick save: $TIMESTAMP"}"

echo "💾 Quick saving changes..."
echo "📝 Message: $MESSAGE"

# Run the auto-push script with custom message
./scripts/auto-push.sh "$MESSAGE"
