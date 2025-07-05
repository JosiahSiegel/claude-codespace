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

## Authentication

### Initial Login (Required)
You must authenticate with Claude Code before using the CLI:

```bash
claude login
```

This will open a browser window for authentication. Once completed, your session will be saved and you can use Claude CLI without further authentication.

### Verify Authentication
```bash
# Test basic functionality
claude --version

# Start an interactive session
claude
```

**Note**: If you encounter authentication issues, the login process will automatically prompt when you try to use Claude commands.

## Permissions Configuration

### Pre-configured Permissions
This DevContainer includes comprehensive permissions in `.claude/settings.local.json` that grant Claude and Roo access to:

- **Development Tools**: git, npm, yarn, node, python, docker
- **File Operations**: ls, cat, cp, mv, rm, mkdir, find, grep
- **System Commands**: pwd, whoami, which, date, env
- **Build Tools**: make, cmake, gcc, g++
- **Network Tools**: curl, wget, ping
- **Web Access**: GitHub, NPM Registry, PyPI, Anthropic docs

### Auto-approval Settings
Common read-only operations are pre-approved for faster workflow:
- File listing and reading
- Git status checks
- Package listings
- System information queries

### Bypassing All Permissions (Development Only)
For sandboxed environments with no internet access, you can bypass all permission checks:

```bash
# Start Claude with all permissions granted
claude --dangerously-skip-permissions

# Or set as an alias for convenience
alias claude-dev="claude --dangerously-skip-permissions"
```

**⚠️ Warning**: Only use `--dangerously-skip-permissions` in secure, isolated development environments.

## Common Commands

### Test Claude CLI
```bash
# Check CLI installation
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

# Test host filesystem access
ls -la /mnt
```

### Run Claude interactively
```bash
claude
```

## Working with Host Repositories

Since full host filesystem access is enabled, you can easily work on repositories located on your host system. You can work with multiple repositories simultaneously in VS Code, including both the claude-codespace repo and your Windows-hosted repos.

### Multi-Repository Workspace

**Working with Multiple Repositories Together**

You can add Windows-hosted repositories to your current VS Code workspace alongside the claude-codespace repo. This allows Roo to work seamlessly across all repositories in your workspace:

**Method 1: Add Folder to Workspace**
1. While in the DevContainer with claude-codespace open
2. Use `File > Add Folder to Workspace...` (or `Ctrl+K Ctrl+A`)
3. Navigate to `/mnt/c/repos/` or any host path
4. Select your repository folder
5. VS Code will now show both repositories in the Explorer sidebar
6. Roo can access and work with files from both repositories

**Method 2: Command Palette**
```bash
# In VS Code, open Command Palette (Ctrl+Shift+P)
# Type: "Workspaces: Add Folder to Workspace"
# Navigate to your host repository path
```

**Method 3: Save as Multi-Root Workspace**
1. Add multiple folders as described above
2. Use `File > Save Workspace As...`
3. Save the workspace configuration
4. Reopen this workspace file anytime to work with all repositories together

### Example Multi-Repository Setup

```
VS Code Explorer:
├── claude-codespace (workspace) [DevContainer]
│   ├── .devcontainer/
│   ├── CLAUDE.md
│   └── ...
├── your-app [Host: C:\repos\your-app]
│   ├── src/
│   ├── package.json
│   └── ...
└── another-project [Host: C:\Users\YourName\Projects\another-project]
    ├── main.py
    ├── requirements.txt
    └── ...
```

### Benefits of Multi-Repository Workspaces

1. **Unified Context**: Roo can see and understand relationships between repositories
2. **Cross-Repository Operations**: Easy file references and operations across repos
3. **Shared DevContainer Benefits**: All repos benefit from the DevContainer's tools and Claude CLI
4. **Seamless Navigation**: Use VS Code's file explorer to navigate all repositories
5. **Integrated Terminal**: Terminal commands work across all repository paths

### Working with Individual Host Repositories

You can also choose to work with host repositories individually:

### Quick Access Methods

**Method 1: Change Directory in Terminal**
```bash
# Navigate to your host repository
cd /mnt/c/Users/YourUsername/Projects/your-repo

# Start Claude in the host repo directory
claude
```

**Method 2: Open Host Repository in VS Code**
1. Use VS Code's "Open Folder" command (`Ctrl+K Ctrl+O`)
2. Navigate to `/mnt/c/Users/YourUsername/Projects/your-repo`
3. Roo Code will work seamlessly with the host repository

**Method 3: Use VS Code Terminal**
```bash
# Open VS Code terminal and navigate
code /mnt/c/Users/YourUsername/Projects/your-repo

# Or use terminal commands directly
cd /mnt/c/path/to/your/repo && code .
```

### Common Host Repository Paths

- **Windows Users**: `/mnt/c/Users/YourUsername/`
- **Projects Folder**: `/mnt/c/Users/YourUsername/Projects/`
- **Desktop**: `/mnt/c/Users/YourUsername/Desktop/`
- **Documents**: `/mnt/c/Users/YourUsername/Documents/`
- **Other Drives**: `/mnt/d/`, `/mnt/e/`, etc.

### Best Practices for Host Repository Work

1. **Maintain Claude Authentication**: Your Claude login persists across directories and workspaces
2. **Use Relative Paths**: When working in host repos, use relative paths for better portability
3. **Git Integration**: Git commands work normally on host repositories
4. **File Permissions**: Changes made in the container are reflected on the host immediately
5. **Extension Compatibility**: Roo Code and other VS Code extensions work seamlessly with host files
6. **Multi-Repository Context**: When working with multiple repos, Roo automatically understands the context of each repository
7. **Workspace Persistence**: Save multi-root workspaces to quickly resume work on multiple projects

### Example Workflows

**Single Repository Workflow:**
```bash
# 1. Navigate to your host project
cd /mnt/c/Users/YourUsername/Projects/my-web-app

# 2. Verify Claude is working
claude --version

# 3. Start Claude for the project
claude

# 4. Or open the entire project in VS Code
code .
```

**Multi-Repository Workflow:**
```bash
# 1. Start in the DevContainer with claude-codespace
cd /workspaces/claude-codespace

# 2. Add a host repository to workspace via terminal
code --add /mnt/c/repos/your-project

# 3. Add another repository
code --add /mnt/c/Users/YourUsername/Projects/my-app

# 4. Now Roo can work across all three repositories
# The VS Code Explorer will show all repositories
```

## Workflow Optimization Tips

1. **Use Context Mentions**: Reference files with `@filename` for efficient context sharing
2. **Leverage MCP Servers**: Use context7 for up-to-date documentation (`resolve-library-id` and `get-library-docs`)
3. **Auto-approval Benefits**: Read-only operations and safe commands are pre-approved for faster workflow
4. **Mode Switching**: Switch between specialized modes for different tasks (architect for planning, code for implementation)
5. **Host Repository Access**: Work with multiple repositories simultaneously - both DevContainer and host repos in one workspace

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
The DevContainer has **full host filesystem access** enabled:

**✅ Current Access (Enabled):**
- The workspace directory (`/workspaces/claude-codespace`) is mounted from your host system
- **WSL mount access** is enabled - all drives mounted in WSL context are accessible at `/mnt/`
- Can access files across your host system (C:\, D:\, etc.) through WSL mount points
- Changes made in the container are reflected on the host system

**📂 Access Patterns:**
- Workspace files: `/workspaces/claude-codespace/`
- Host drives: `/mnt/c/`, `/mnt/d/`, etc.
- WSL distributions: `/mnt/wsl/`

**🔧 Alternative Mount Options:**
If you need different access patterns, you can modify [`.devcontainer/devcontainer.json`](.devcontainer/devcontainer.json:8):

**Option 1: User Profile Access (Most Secure)**
```json
"source=${env:USERPROFILE},target=/mnt/user,type=bind,consistency=cached"
```
- Works across all Windows systems without drive letter assumptions
- Access your user profile at `/mnt/user/`

**Option 2: Specific Drives (Manual)**
```json
"source=C:\\,target=/mnt/c,type=bind,consistency=cached",
"source=D:\\,target=/mnt/d,type=bind,consistency=cached"
```
- Manual drive specification for specific needs

**⚠️ Security Note:** Full filesystem access is enabled for development flexibility. The current WSL mount configuration provides broad access while maintaining reasonable security boundaries.