# Minimal Dockerfile - leveraging devcontainer features for most tools
# Base image: Ubuntu LTS

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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install aztfexport (no official image or feature available)
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

# Create directories
RUN mkdir -p /workspaces /host

# Set environment
ENV SHELL=/bin/bash

# Note: User creation is handled by devcontainer features (common-utils)
WORKDIR /workspaces

# Labels
LABEL description="Azure/Terraform Dev Container with DevContainer Features" \
      base="ubuntu:22.04" \
      features="azure-cli,terraform,node,github-cli"