#!/bin/bash

# Quick Save Script - Auto commit and push with timestamp
# Usage: ./scripts/quick-save.sh [optional-message]

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

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
MESSAGE="${1:-"Quick save: $TIMESTAMP"}"

echo "💾 Quick saving changes..."
echo "📝 Message: $MESSAGE"

# Run the auto-push script with custom message
./scripts/auto-push.sh "$MESSAGE"
