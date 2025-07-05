# Claude Code DevContainer Template

A ready-to-use DevContainer setup optimized for [Claude Code](https://claude.ai/code) CLI and [Roo Code](https://marketplace.visualstudio.com/items?itemName=rooveterinaryinc.roo-cline) extension integration.

## 🚀 Quick Start

1. **Open in DevContainer**
   - Clone this repository
   - Open in VS Code
   - Click "Reopen in Container" when prompted

2. **Authenticate Claude CLI**
   ```bash
   # Login to Claude
   claude login
   
   # Verify Claude is working
   claude --version
   ```

3. **Start Coding**
   - Roo Code extension is pre-installed and configured
   - Claude CLI available at `/usr/bin/claude`
   - Full host filesystem access enabled

## ✨ Features

### 🐳 DevContainer Optimized
- **Claude CLI Pre-installed**: Ready to use at `/usr/bin/claude`
- **Roo Code Extension**: Pre-configured for seamless AI assistance
- **Host Filesystem Access**: WSL mount access to all drives (`/mnt/c/`, `/mnt/d/`, etc.)
- **MCP Servers**: Context7 integration for up-to-date documentation

### 🤖 AI Development Ready
- **Comprehensive Permissions**: Pre-configured access to development tools, file operations, and web resources
- **Auto-approval Settings**: Streamlined workflow for read-only operations
- **Context Awareness**: Repository-specific rules and guidance
- **Mode Specialization**: DevContainer-focused architect and code modes
- **Configuration Focus**: Optimized for `.json`, `.yaml`, `.md` files

### 🔧 Enhanced Productivity
- **Dynamic Context Variables**: `{{workspace}}`, `{{mode}}`, etc.
- **MCP Integration**: Latest Context7 server with 8000 token limits
- **Container-aware Commands**: Optimized for containerized development

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Comprehensive setup and usage guide
- **[.devcontainer/devcontainer.json](.devcontainer/devcontainer.json)** - Container configuration
- **[.roo/](.roo/)** - Workspace rules and mode configurations

## 🛠️ Requirements

- VS Code with DevContainer extension
- Docker Desktop
- Claude Code account (for authentication)

## 🔐 Authentication

Before using Claude CLI, you must authenticate:

```bash
# Login to Claude
claude login

# Verify you're logged in
claude --version
```

## 🗂️ File Access

This DevContainer provides full host filesystem access:

- **Workspace**: `/workspaces/claude-codespace/`
- **Host Drives**: `/mnt/c/`, `/mnt/d/`, etc.
- **WSL Context**: `/mnt/wsl/`

## 🚀 Using as a Template

1. **Fork or Download** this repository
2. **Customize** the devcontainer configuration as needed
3. **Modify** workspace rules in `.roo/rules/` for your project
4. **Update** CLAUDE.md with project-specific guidance

## 🔧 Configuration Options

### Permissions
The DevContainer comes with comprehensive permissions pre-configured in `.claude/settings.local.json`:
- Full development toolchain access (git, npm, docker, etc.)
- File operation permissions
- Web access to essential domains
- Auto-approval for common read operations

### Host Filesystem Access
The DevContainer supports multiple host access patterns. See [CLAUDE.md](CLAUDE.md#host-filesystem-access) for alternative mounting options if the default WSL mount doesn't meet your needs.

### Quick Permission Bypass (Development Only)
For maximum flexibility in isolated environments:
```bash
claude --dangerously-skip-permissions
```

## 📝 License

This template is provided as-is for development use. Customize freely for your projects.

---

**Ready to start?** Open this repository in VS Code and let the DevContainer handle the setup! 🎉