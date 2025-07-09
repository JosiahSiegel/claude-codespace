#!/bin/bash

# Post-create script for DevContainer
# Runs after the container is created and all features are installed

set -e

echo "🚀 Running post-create setup..."

# Set up npm global directory for non-root user (avoid conflict with nvm)
echo "🔧 Configuring npm for user..."
mkdir -p /home/vscode/.npm-global
# Only set prefix if nvm is not being used
if ! command -v nvm &> /dev/null && [ ! -d "$HOME/.nvm" ]; then
    npm config set prefix '/home/vscode/.npm-global'
    echo "✅ npm prefix configured"
    # Add npm global bin to PATH for this session
    export PATH="/home/vscode/.npm-global/bin:$PATH"
else
    echo "✅ nvm detected, skipping npm prefix configuration"
fi

# Install Claude Code CLI
echo "📦 Installing Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    # Install Claude CLI globally using the official package name
    # npm prefix is configured above to use user-writable directory
    npm install -g @anthropic-ai/claude-code --force --no-os-check
    
    # Check if Claude CLI is now available (check both system PATH and npm global)
    if command -v claude &> /dev/null; then
        echo "✅ Claude CLI installed successfully"
        CLAUDE_PATH=$(which claude)
    elif [ -f "/home/vscode/.npm-global/bin/claude" ]; then
        echo "✅ Claude CLI installed in npm global directory"
        CLAUDE_PATH="/home/vscode/.npm-global/bin/claude"
    else
        echo "⚠️  Claude CLI installation completed but not found in PATH"
        echo "    This may be normal during container build - it will be available after restart"
        CLAUDE_PATH=""
    fi
    
    # Create symlink at standard location for Roo Code extension
    if [ -n "$CLAUDE_PATH" ] && [ ! -f "/usr/bin/claude" ]; then
        sudo ln -sf "$CLAUDE_PATH" /usr/bin/claude
        echo "🔗 Created symlink at /usr/bin/claude for Roo Code extension"
    fi
else
    echo "✅ Claude CLI already installed at: $(which claude)"
fi

# Set up SSH directory (handle readonly mount gracefully)
echo "🔑 Setting up SSH directory..."
if [ -d "/home/vscode/.ssh" ]; then
    # SSH directory exists (likely mounted from host)
    if [ -w "/home/vscode/.ssh" ]; then
        # If writable, set proper permissions
        chmod 700 /home/vscode/.ssh 2>/dev/null || true
        chown vscode:vscode /home/vscode/.ssh 2>/dev/null || true
        echo "✅ SSH directory permissions updated"
    else
        # If readonly mount, just verify it exists
        echo "✅ SSH directory mounted from host (readonly)"
    fi
else
    # Create SSH directory if it doesn't exist
    mkdir -p /home/vscode/.ssh
    chmod 700 /home/vscode/.ssh
    chown vscode:vscode /home/vscode/.ssh
    echo "✅ SSH directory created"
fi

# Set up Git configuration by copying from host if available
echo "🔧 Setting up Git configuration..."
if [ -f "/home/vscode/.gitconfig-host" ]; then
    # Copy host gitconfig to make it writable
    cp /home/vscode/.gitconfig-host /home/vscode/.gitconfig
    echo "✅ Copied Git configuration from host"
else
    # Create new gitconfig if host doesn't have one
    touch /home/vscode/.gitconfig
    echo "📝 Created new Git configuration file"
fi

# Ensure gitconfig is writable
chown vscode:vscode /home/vscode/.gitconfig
chmod 644 /home/vscode/.gitconfig

# Set basic git configuration if not already set
if ! git config --global user.name &> /dev/null; then
    git config --global user.name "DevContainer User"
fi

if ! git config --global user.email &> /dev/null; then
    git config --global user.email "user@devcontainer.local"
fi

# Configure git for container environment
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global safe.directory '*'

# Create cache directories (handle existing mounts gracefully)
echo "📁 Setting up cache directories..."
for dir in "/home/vscode/.azure" "/home/vscode/.terraform.d"; do
    if [ -d "$dir" ]; then
        # Directory exists, try to set ownership if writable
        if [ -w "$dir" ]; then
            chown -R vscode:vscode "$dir" 2>/dev/null || true
            echo "✅ Cache directory $(basename "$dir") permissions updated"
        else
            echo "✅ Cache directory $(basename "$dir") mounted from host"
        fi
    else
        # Create directory if it doesn't exist
        mkdir -p "$dir"
        chown -R vscode:vscode "$dir"
        echo "✅ Cache directory $(basename "$dir") created"
    fi
done

# Set up workspace permissions
echo "📂 Setting workspace permissions..."
sudo chown -R vscode:vscode /workspaces 2>/dev/null || true

# Create a simple MCP server config directory
echo "🔌 Setting up MCP server configuration..."
mkdir -p /home/vscode/.config/mcp
chown vscode:vscode /home/vscode/.config/mcp

# Install helper scripts globally (backup in case Dockerfile didn't install them)
echo "🔧 Installing helper scripts..."

# Install check-versions
if [ -f ".devcontainer/scripts/check-versions" ]; then
    sudo cp .devcontainer/scripts/check-versions /usr/local/bin/check-versions
    sudo chmod +x /usr/local/bin/check-versions
    echo "✅ check-versions script installed globally"
elif [ -f "/workspaces/claude-codespace/.devcontainer/scripts/check-versions" ]; then
    sudo cp /workspaces/claude-codespace/.devcontainer/scripts/check-versions /usr/local/bin/check-versions
    sudo chmod +x /usr/local/bin/check-versions
    echo "✅ check-versions script installed globally"
else
    echo "⚠️  check-versions script not found, will be available from workspace"
fi

# Install devcontainer-help
if [ -f ".devcontainer/scripts/devcontainer-help" ]; then
    sudo cp .devcontainer/scripts/devcontainer-help /usr/local/bin/devcontainer-help
    sudo chmod +x /usr/local/bin/devcontainer-help
    echo "✅ devcontainer-help script installed globally"
elif [ -f "/workspaces/claude-codespace/.devcontainer/scripts/devcontainer-help" ]; then
    sudo cp /workspaces/claude-codespace/.devcontainer/scripts/devcontainer-help /usr/local/bin/devcontainer-help
    sudo chmod +x /usr/local/bin/devcontainer-help
    echo "✅ devcontainer-help script installed globally"
else
    echo "⚠️  devcontainer-help script not found, will be available from workspace"
fi

echo "✅ Post-create setup completed successfully!"
echo ""
echo "📚 Run 'devcontainer-help' for comprehensive help and documentation"