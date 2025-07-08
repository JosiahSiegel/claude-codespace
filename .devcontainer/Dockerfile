# Minimal Dockerfile - Use custom devops image with all tools pre-installed
# This avoids DevContainer features that get blocked by urlblock.php

# ===== Use custom devops image as base =====
FROM ghcr.io/josiahsiegel/devops-image:latest

# All dev tools already included in custom devops image:
# docker-in-docker, azure-cli, node, python, git, github-cli, terraform
# vscode user and sudo permissions are already configured in the base image

# Install aztfexport (only tool not included in base image)
ARG AZTFEXPORT_VERSION=0.18.0
RUN wget --no-check-certificate "https://github.com/Azure/aztfexport/releases/download/v${AZTFEXPORT_VERSION}/aztfexport_v${AZTFEXPORT_VERSION}_linux_amd64.zip" \
    && unzip aztfexport_v${AZTFEXPORT_VERSION}_linux_amd64.zip \
    && chmod +x aztfexport \
    && mv aztfexport /usr/local/bin/ \
    && rm aztfexport_v${AZTFEXPORT_VERSION}_linux_amd64.zip

# Copy and run shell configuration script
COPY scripts/shell-config.sh /tmp/shell-config.sh
RUN chmod +x /tmp/shell-config.sh && \
    /tmp/shell-config.sh && \
    rm /tmp/shell-config.sh

# Copy version check script
COPY scripts/check-versions /usr/local/bin/check-versions
RUN chmod +x /usr/local/bin/check-versions

# Create directories and set ownership
RUN mkdir -p /workspaces /host /home/vscode/.azure /home/vscode/.terraform.d \
    && chown -R vscode:vscode /home/vscode

# Set environment
ENV SHELL=/bin/bash \
    PATH="/usr/local/bin:${PATH}"

WORKDIR /workspaces
USER vscode

# Labels
LABEL description="Azure/Terraform Dev Container - Minimal build using custom devops base" \
      base="ghcr.io/josiahsiegel/devops-image:latest" \
      tools="docker-in-docker,azure-cli,node,python,git,github-cli,terraform,aztfexport"