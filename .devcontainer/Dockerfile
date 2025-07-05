FROM node:latest

RUN apt-get update && apt-get install -y ca-certificates && \
    update-ca-certificates

# Install Claude CLI via NPM
RUN npm install -g @anthropic-ai/claude-code

# Verify Claude CLI installation
RUN claude --version

# Create a symlink to ensure Claude is available in the expected location
RUN ln -sf /usr/local/bin/claude /usr/bin/claude 2>/dev/null || true