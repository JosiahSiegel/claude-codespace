FROM node:latest

# SSL Certificate handling for corporate environments
# Option 1: Update system certificates (default behavior)
RUN apt-get update && apt-get install -y ca-certificates && \
    update-ca-certificates

# Option 2: Copy custom certificates if provided
# Uncomment and place your corporate certs in .devcontainer/certs/
# COPY certs/*.crt /usr/local/share/ca-certificates/
# RUN update-ca-certificates

# Environment variables for SSL handling
# WARNING: Disabling SSL verification is insecure and should only be used in trusted environments
# Set these in devcontainer.json if needed:
# NODE_TLS_REJECT_UNAUTHORIZED=0 (for NPM install)
# CLAUDE_DISABLE_SSL_VERIFY=1 (hypothetical - Claude CLI may not support this)

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