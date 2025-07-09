#!/bin/bash

# Shell configuration script for DevContainer
# This script sets up shell aliases and configurations

# Create shell aliases
cat >> /etc/bash.bashrc << 'EOF'

# Add npm global bin to PATH (for Claude CLI and other global packages)
if [ -d "$HOME/.npm-global/bin" ]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# Fix npm/nvm conflicts on shell startup
if [ -f "$HOME/.npmrc" ] && command -v nvm &> /dev/null; then
    npm config delete prefix 2>/dev/null || true
    npm config delete globalconfig 2>/dev/null || true
fi

# Custom aliases for development
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Azure CLI aliases
alias az-login='az login --use-device-code'
alias az-sub='az account show --output table'

# Terraform aliases
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'

# Navigation helpers for host access
alias host='cd /host'
alias home='cd /host/home'
alias projects='cd /host/repos || cd /host/home/*/projects || echo "Projects directory not found"'

# Function to show welcome message
show_welcome() {
    echo ""
    echo "🚀 Claude DevContainer Ready!"
    echo ""
    echo "📋 Available tools:"
    echo "   • Claude CLI: $(command -v claude >/dev/null && claude --version 2>/dev/null | head -1 || echo 'Not installed')"
    echo "   • Azure CLI: $(az --version 2>/dev/null | head -1)"
    echo "   • Terraform: $(terraform version 2>/dev/null | head -1)"
    echo "   • Node.js: $(node --version 2>/dev/null)"
    echo ""
    echo "🔧 Useful commands:"
    echo "   • devcontainer-help - Show comprehensive help and documentation"
    echo "   • check-versions    - Show all tool versions"
    echo "   • claude --version  - Test Claude CLI"
    echo "   • host              - Navigate to host filesystem"
    echo ""
    echo "📁 Current workspace: $(pwd)"
    echo "🕐 Date: $(date)"
    echo ""
}

# Show welcome message on login
show_welcome
EOF

echo "Shell configuration completed successfully"