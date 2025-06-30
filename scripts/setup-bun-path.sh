#!/bin/bash

# Setup Bun PATH Configuration
# This script ensures Bun is always available in PATH

echo "🔧 Setting up Bun PATH configuration..."

# Function to add Bun to PATH if not already present
setup_bun_path() {
    if [[ ":$PATH:" != *":$HOME/.bun/bin:"* ]]; then
        export PATH="$HOME/.bun/bin:$PATH"
        echo "✅ Bun PATH added to current session"
    fi
}

# Setup PATH for current session
setup_bun_path

# Determine shell configuration file
SHELL_RC=""
if [[ "$SHELL" == *"zsh"* ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ "$SHELL" == *"bash"* ]]; then
    if [[ -f "$HOME/.bashrc" ]]; then
        SHELL_RC="$HOME/.bashrc"
    else
        SHELL_RC="$HOME/.bash_profile"
    fi
fi

# Add to shell profile permanently
if [[ -n "$SHELL_RC" ]]; then
    if ! grep -q 'export PATH="$HOME/.bun/bin:$PATH"' "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> "$SHELL_RC"
        echo "✅ Bun PATH added to $SHELL_RC"
        echo "🔄 Run 'source $SHELL_RC' or restart terminal to apply globally"
    else
        echo "✅ Bun PATH already configured in $SHELL_RC"
    fi
else
    echo "⚠️  Could not detect shell configuration file"
    echo "💡 Please manually add 'export PATH=\"\$HOME/.bun/bin:\$PATH\"' to your shell profile"
fi

# Verify bun is working
if command -v bun &> /dev/null; then
    echo "✅ Bun is working: $(bun --version)"
else
    echo "❌ Bun not found, please install it first"
    echo "📝 Install with: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

echo "🎉 Bun PATH setup completed!"
