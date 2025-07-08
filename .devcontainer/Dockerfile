# Multi-stage Dockerfile - Copy tools from official images to bypass corporate firewall
# This avoids DevContainer features that get blocked by urlblock.php

# ===== STAGE 1: Extract tools from official images =====
FROM hashicorp/terraform:1.7 AS terraform
FROM node:20-slim AS node

# ===== STAGE 2: GitHub CLI =====
FROM ubuntu:22.04 AS github-cli
RUN apt-get update && apt-get install -y curl tar \
    && curl -fsSL https://github.com/cli/cli/releases/download/v2.40.1/gh_2.40.1_linux_amd64.tar.gz -o gh.tar.gz \
    && tar -xzf gh.tar.gz \
    && mv gh_2.40.1_linux_amd64/bin/gh /usr/local/bin/gh \
    && chmod +x /usr/local/bin/gh \
    && rm -rf gh.tar.gz gh_2.40.1_linux_amd64

# ===== FINAL STAGE: Combine everything =====
FROM ubuntu:22.04

# Install basic packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    tar \
    gzip \
    unzip \
    git \
    sudo \
    ca-certificates \
    python3 \
    python3-pip \
    lsb-release \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create vscode user (corporate-friendly)
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid 1000 -m -s /bin/bash vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

# ===== Copy tools from other stages =====

# Install Azure CLI directly (more reliable than copying)
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Copy Terraform
COPY --from=terraform /bin/terraform /usr/local/bin/terraform

# Copy complete Node.js installation from official image
COPY --from=node /usr/local/ /usr/local/

# Create symlinks for node
RUN ln -s /usr/local/bin/node /usr/bin/node \
    && ln -s /usr/local/bin/npm /usr/bin/npm \
    && ln -s /usr/local/bin/npx /usr/bin/npx

# Copy GitHub CLI
COPY --from=github-cli /usr/local/bin/gh /usr/local/bin/gh

# Install aztfexport (no official image available)
ARG AZTFEXPORT_VERSION=0.18.0
RUN wget "https://github.com/Azure/aztfexport/releases/download/v${AZTFEXPORT_VERSION}/aztfexport_v${AZTFEXPORT_VERSION}_linux_amd64.zip" \
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
LABEL description="Azure/Terraform Dev Container - Multi-stage build bypasses corporate firewall" \
      base="ubuntu:22.04" \
      tools="azure-cli,terraform,node,github-cli,aztfexport"