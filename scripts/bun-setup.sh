#!/bin/bash

# Bun PATH Setup Helper
# Source this file or call it from other scripts to ensure Bun is available

# Function to setup Bun PATH for current session
setup_bun_for_session() {
    # Add Bun to PATH if not already present
    if [[ ":$PATH:" != *":$HOME/.bun/bin:"* ]]; then
        export PATH="$HOME/.bun/bin:$PATH"
    fi
    
    # Verify bun is available
    if ! command -v bun &> /dev/null; then
        echo "❌ Error: Bun not found even after PATH setup!"
        echo "💡 Please install Bun: curl -fsSL https://bun.sh/install | bash"
        return 1
    fi
    
    return 0
}

# Auto-call setup if script is executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    setup_bun_for_session
fi
