#!/bin/bash

# Shell configuration script for DevContainer
# This script sets up shell aliases and configurations

# Create shell aliases
cat >> /etc/bash.bashrc << 'EOF'

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
    echo "🚀 Azure/Terraform DevContainer Ready!"
    echo ""
    echo "📋 Available tools:"
    echo "   • Azure CLI: $(az --version | head -1)"
    echo "   • Terraform: $(terraform version | head -1)"
    echo "   • Node.js: $(node --version)"
    echo "   • GitHub CLI: $(gh --version | head -1)"
    echo ""
    echo "🔧 Useful commands:"
    echo "   • check-versions  - Show all tool versions"
    echo "   • host           - Navigate to host filesystem"
    echo "   • az-login       - Login to Azure"
    echo ""
    echo "📁 Current workspace: $(pwd)"
    echo ""
}

# Show welcome message on login
show_welcome
EOF

echo "Shell configuration completed successfully"