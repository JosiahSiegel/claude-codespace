FROM node:latest

RUN apt-get update && apt-get install -y ca-certificates curl && \
    update-ca-certificates

# Install Azure CLI with robust installation method
RUN apt-get update && apt-get install -y jq bc apt-transport-https lsb-release gnupg && \
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
