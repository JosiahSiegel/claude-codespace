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

# Check and fix port forwarding issues
echo "🔍 Checking port forwarding status..."
if [ -f ".devcontainer/scripts/fix-port-forwarding.sh" ]; then
    # Run a quick port check (non-interactive)
    if netstat -tuln 2>/dev/null | grep -q ":8080\|:10000\|:10001\|:10002"; then
        echo "⚠️  Port conflicts detected, running port forwarding fix..."
        # Run the fix script in non-interactive mode
        bash .devcontainer/scripts/fix-port-forwarding.sh 2>/dev/null || true
    else
        echo "✅ No port forwarding conflicts detected"
    fi
else
    echo "⚠️  Port forwarding fix script not found"
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
echo "   • Port Forwarding: $(netstat -tuln 2>/dev/null | grep -q ":8080\|:10000\|:10001\|:10002" && echo "⚠️  Conflicts detected" || echo "✅ Clean")"
echo ""
echo "💡 Run 'check-versions' for detailed version information"
echo "💡 Run '.devcontainer/scripts/fix-port-forwarding.sh' if experiencing port issues"
echo ""
echo "📚 Run 'devcontainer-help' for comprehensive help and documentation"
echo ""
echo "🕐 Date: $(date)"
echo ""

# Create symlinks for Windows drive letters under /mnt
echo "🔗 Setting up Windows drive letter symlinks..."
if [ -d "/host/mnt/host" ]; then
    # Create /mnt directory if it doesn't exist
    sudo mkdir -p /mnt
    
    # Find all drive letters and create symlinks
    for drive in /host/mnt/host/*; do
        if [ -d "$drive" ]; then
            drive_letter=$(basename "$drive")
            if [ ! -e "/mnt/$drive_letter" ]; then
                sudo ln -s "$drive" "/mnt/$drive_letter"
                echo "   ✅ Created symlink: /mnt/$drive_letter -> $drive"
            else
                echo "   ℹ️  Symlink already exists: /mnt/$drive_letter"
            fi
        fi
    done
    echo "   ✅ Windows drive symlinks setup complete"
else
    echo "   ℹ️  No Windows drives detected (not running on WSL2)"
fi
echo ""