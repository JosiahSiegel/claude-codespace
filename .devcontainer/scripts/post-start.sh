#!/bin/bash

# Post-start script for DevContainer
# Runs each time the container starts

set -e

echo "🔄 Running post-start setup..."

# Check if Claude CLI is available and working
echo "🔍 Checking Claude CLI..."
if command -v claude &> /dev/null; then
    echo "✅ Claude CLI is available at: $(which claude)"
    # Ensure symlink exists at /usr/bin/claude for Roo Code extension
    if [ ! -f "/usr/bin/claude" ]; then
        echo "🔗 Creating symlink at /usr/bin/claude for Roo Code extension..."
        sudo ln -sf "$(which claude)" /usr/bin/claude
    fi
else
    echo "⚠️  Claude CLI not found, checking npm installation..."
    # Try to find and link Claude CLI if it was installed but not linked properly
    CLAUDE_PATH=$(find /usr/local/lib/node_modules/@anthropic-ai/claude-code -name "claude" -type f 2>/dev/null | head -1)
    if [ -n "$CLAUDE_PATH" ]; then
        echo "🔗 Found Claude CLI, creating symlinks..."
        sudo ln -sf "$CLAUDE_PATH" /usr/local/bin/claude
        sudo ln -sf "$CLAUDE_PATH" /usr/bin/claude
        echo "✅ Claude CLI linked successfully"
    fi
fi

# Fix npm/nvm configuration conflicts
echo "🔧 Resolving npm/nvm configuration conflicts..."
if [ -f "$HOME/.npmrc" ]; then
    # Remove conflicting npm settings that interfere with nvm
    npm config delete prefix 2>/dev/null || true
    npm config delete globalconfig 2>/dev/null || true
    echo "✅ npm configuration conflicts resolved"
fi

# Update npm and check for security vulnerabilities
echo "🔧 Updating npm and checking security..."
npm update -g --silent 2>/dev/null || true

# Ensure workspace permissions are correct
echo "📂 Checking workspace permissions..."
if [ -d "/workspaces/claude-codespace" ]; then
    sudo chown -R vscode:vscode /workspaces/claude-codespace 2>/dev/null || true
fi

# Check Git configuration
echo "🔧 Verifying Git configuration..."
if ! git config --global user.name &> /dev/null; then
    git config --global user.name "DevContainer User"
fi

if ! git config --global user.email &> /dev/null; then
    git config --global user.email "user@devcontainer.local"
fi

# Ensure Azure CLI is logged out initially (for clean state)
echo "☁️  Checking Azure CLI state..."
az account clear 2>/dev/null || true

# Check if MCP servers are configured
echo "🔌 Checking MCP server configuration..."
if [ -d "/home/vscode/.config/mcp" ]; then
    echo "✅ MCP configuration directory exists"
else
    mkdir -p /home/vscode/.config/mcp
    chown vscode:vscode /home/vscode/.config/mcp
fi

# Display welcome message with status
echo ""
echo "🎉 DevContainer post-start setup complete!"
echo ""
echo "📋 Quick Status Check:"
echo "   • Claude CLI: $(command -v claude >/dev/null && echo "✅ Available" || echo "❌ Not found")"
echo "   • Azure CLI: $(command -v az >/dev/null && echo "✅ Available" || echo "❌ Not found")"
echo "   • Terraform: $(command -v terraform >/dev/null && echo "✅ Available" || echo "❌ Not found")"
echo "   • Git: $(command -v git >/dev/null && echo "✅ Available" || echo "❌ Not found")"
echo ""
echo "💡 Run 'check-versions' for detailed version information"
echo ""