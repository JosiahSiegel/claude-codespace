# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides Claude Code CLI access within a DevContainer for use with Roo Code extension running inside the same DevContainer. It serves as an optimized template for Claude Code/Roo integration in containerized development environments.

## Claude CLI Path

The Claude CLI is available at `/usr/bin/claude` inside the DevContainer.

## Setup for Roo Code Extension in DevContainer

**Roo Code Configuration**: Configure Roo Code extension to use:
```
/usr/bin/claude
```

**Installation**: Make sure Roo Code extension is installed in the DevContainer VS Code instance.

## Optimized Configuration Features

### Enhanced MCP Configuration
- **Context7 Integration**: Pre-configured with optimized token limits (8000) for better documentation retrieval
- **Auto-approval Settings**: Streamlined workflow with automatic approval for read-only operations
- **Latest Package Version**: Always uses the latest Context7 MCP server version

### Workspace Context Awareness
- **Repository-specific Rules**: Automatically loaded workspace rules provide context about this claude-codespace repository
- **DevContainer Guidance**: Built-in best practices for containerized development
- **Dynamic Context Variables**: Uses `{{workspace}}`, `{{mode}}`, and other variables for adaptive configuration

### Project-specific Mode Overrides
- **DevContainer-focused Modes**: Specialized architect and code modes optimized for container workflows
- **Configuration File Focus**: Enhanced editing capabilities for .json, .yaml, .md files
- **Container-aware Commands**: Optimized command execution for DevContainer environment

## Common Commands

### Test Claude CLI
```bash
claude --version
```

### Verify DevContainer Setup
```bash
# Check workspace permissions
ls -la /workspaces/claude-codespace

# Test container status
docker ps

# Verify user context
whoami
```

### Run Claude interactively
```bash
claude
```

## Workflow Optimization Tips

1. **Use Context Mentions**: Reference files with `@filename` for efficient context sharing
2. **Leverage MCP Servers**: Use context7 for up-to-date documentation (`resolve-library-id` and `get-library-docs`)
3. **Auto-approval Benefits**: Read-only operations and safe commands are pre-approved for faster workflow
4. **Mode Switching**: Switch between specialized modes for different tasks (architect for planning, code for implementation)

## Troubleshooting

### Claude CLI Issues
- Verify installation: `which claude` should return `/usr/bin/claude`
- Check permissions: Ensure the binary is executable
- Test basic functionality: `claude --version`

### MCP Server Connectivity
- Context7 issues are often resolved by restarting the Roo Code extension
- Check MCP server logs in VS Code developer tools if needed
- Verify network connectivity within the container

### Container Environment
- Ensure proper user permissions within the DevContainer
- Verify workspace directory access: `/workspaces/claude-codespace`
- Check that all required tools are available in the container PATH

### Host Filesystem Access
Currently, the DevContainer has **limited** host filesystem access:

**✅ Current Access:**
- The workspace directory (`/workspaces/claude-codespace`) is mounted from your Windows host
- Can access files within the repository and its parent directories
- Changes made in the container are reflected on the host system

**❌ Limited Access:**
- Cannot access broader Windows filesystem (C:\Users, C:\Program Files, etc.)
- Cannot access files outside the mounted workspace directory

**🔧 To Enable Broader Host Access:**
Uncomment the mount configurations in [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json:7):
```json
"mounts": [
  "source=C:\\,target=/mnt/c,type=bind,consistency=cached",
  "source=C:\\Users,target=/mnt/host/Users,type=bind,consistency=cached"
]
```

After uncommenting and rebuilding the container, you'll have:
- Full C:\ drive access at `/mnt/c/`
- User folders access at `/mnt/host/Users/`
- Ability to work with files anywhere on your Windows system

**⚠️ Security Note:** Broader filesystem access increases security considerations. Only enable if needed for your workflow.
```