FROM node:latest

# SSL Certificate handling for corporate environments
# Option 1: Update system certificates (default behavior)
RUN apt-get update && apt-get install -y ca-certificates curl && \
    update-ca-certificates

# Install Azure CLI with robust installation method for VPN/corporate environments
RUN apt-get update && apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
    # Create keyring directory if it doesn't exist
    mkdir -p /etc/apt/keyrings && \
    # Download and add Microsoft GPG key with better error handling
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg && \
    # Set proper permissions on the keyring
    chmod 644 /etc/apt/keyrings/microsoft.gpg && \
    # Add Azure CLI repository with signed-by option
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list && \
    # Update package list and install Azure CLI
    apt-get update && \
    apt-get install -y azure-cli

# Option 2: Copy custom certificates if provided
# Uncomment and place your corporate certs in .devcontainer/certs/
# COPY certs/*.crt /usr/local/share/ca-certificates/
# RUN update-ca-certificates

# Environment variables for SSL handling
# WARNING: Disabling SSL verification is insecure and should only be used in trusted environments
# Option 1: Disable Node.js SSL verification (for NPM install in corporate environments)
# ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# Option 2: Set custom CA certificates path
# ENV NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/custom/your-ca.crt

# Option 3: Hypothetical Claude CLI SSL bypass (may not be supported)
# ENV CLAUDE_DISABLE_SSL_VERIFY=1

# Configure NPM for corporate environments (if needed)
# Uncomment and modify as needed:
# RUN npm config set strict-ssl false
# RUN npm config set registry https://registry.npmjs.org/
# RUN npm config set proxy http://your-proxy:port
# RUN npm config set https-proxy http://your-proxy:port

# Install Claude CLI via NPM
# Note: This installation might fail in corporate environments with SSL issues
# If it fails, see manual installation instructions in README
RUN npm install -g @anthropic-ai/claude-code || \
    (echo "WARNING: Claude CLI installation failed. This might be due to SSL/proxy issues." && \
     echo "You may need to manually install Claude after the container starts." && \
     echo "See README for corporate environment setup instructions." && \
     exit 0)

# Verify Claude CLI installation (allow failure)
RUN claude --version 2>/dev/null || \
    echo "Claude CLI not installed yet - manual installation required"

# Create a symlink to ensure Claude is available in the expected location
RUN ln -sf /usr/local/bin/claude /usr/bin/claude 2>/dev/null || true

# Create a helper script for manual Claude installation
RUN echo '#!/bin/bash\n\
echo "Manual Claude CLI Installation Helper"\n\
echo "===================================="\n\
echo ""\n\
echo "If Claude CLI failed to install due to SSL/proxy issues, try:"\n\
echo ""\n\
echo "1. Disable SSL verification temporarily (INSECURE - development only):"\n\
echo "   npm config set strict-ssl false"\n\
echo "   npm install -g @anthropic-ai/claude-code"\n\
echo "   npm config set strict-ssl true"\n\
echo ""\n\
echo "2. Or use corporate proxy:"\n\
echo "   npm config set proxy http://your-proxy:port"\n\
echo "   npm config set https-proxy http://your-proxy:port"\n\
echo "   npm install -g @anthropic-ai/claude-code"\n\
echo ""\n\
echo "3. Or download and install manually from a trusted network"\n\
echo ""\n\
echo "NOTE: Even if installation succeeds, 'claude login' may fail"\n\
echo "due to SSL certificate validation during authentication."\n\
echo "This is a security feature and cannot be easily bypassed."\n\
' > /usr/local/bin/install-claude-helper && \
chmod +x /usr/local/bin/install-claude-helper