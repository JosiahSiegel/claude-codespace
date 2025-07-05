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
- **Claude CLI Pre-installed**: NPM package `@anthropic-ai/claude-code` installed globally
- **Roo Code Extension**: Pre-configured for seamless AI assistance
- **Host Filesystem Access**: WSL mount access to all drives (`/mnt/c/`, `/mnt/d/`, etc.)
- **MCP Servers**: Context7 integration for up-to-date documentation

### 🤖 AI Development Ready
- **Comprehensive Permissions**: Pre-configured access to development tools, file operations, and web resources
- **Auto-approval Settings**: Streamlined workflow for read-only operations
- **Context Awareness**: Repository-specific rules and guidance
- **Mode Specialization**: DevContainer-focused architect and code modes

### 🔧 Enhanced Productivity
- **Dynamic Context Variables**: `{{workspace}}`, `{{mode}}`, etc.
- **MCP Integration**: Latest Context7 server with 8000 token limits
- **Container-aware Commands**: Optimized for containerized development

## 🛠️ Installation Details

### Claude CLI
The DevContainer automatically installs Claude CLI via NPM:
- Primary location: `/usr/local/bin/claude`
- Symlink for compatibility: `/usr/bin/claude`

### DevContainer Configuration
The [`Dockerfile`](.devcontainer/Dockerfile) includes:
1. **Node.js Installation**: Uses NodeSource repository for latest LTS
2. **Claude CLI Installation**: `npm install -g @anthropic-ai/claude-code`
3. **Symlink Creation**: Ensures Claude is available at `/usr/bin/claude`

### Verification
After the container builds, verify installation:
```bash
# Check Claude CLI version
claude --version

# Check Node.js installation
node --version

# List global NPM packages
npm list -g --depth=0
```

## 📋 Requirements

- VS Code with DevContainer extension
- Docker Desktop
- Claude Code account (for authentication)

## 🔐 Authentication

Before using Claude CLI, you must authenticate:

```bash
# Login to Claude
claude login

# Test basic functionality
claude --version

# Start an interactive session
claude
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

## 🔧 Configuration

### Permissions
Pre-configured in `.claude/settings.local.json`:
- Full development toolchain access (git, npm, docker, etc.)
- File operation permissions
- Web access to essential domains
- Auto-approval for common read operations

### Quick Permission Bypass (Development Only)
For maximum flexibility in isolated environments:
```bash
claude --dangerously-skip-permissions
```
⚠️ **Warning**: Only use in secure, isolated development environments.

### Host Filesystem Access Options
See [CLAUDE.md](CLAUDE.md#host-filesystem-access) for alternative mounting options if the default WSL mount doesn't meet your needs.

## 🔍 Troubleshooting

### Claude CLI Not Found
1. Rebuild the DevContainer: `Dev Containers: Rebuild Container`
2. Check if Node.js is installed: `node --version`
3. Check global NPM packages: `npm list -g --depth=0`
4. Verify the binary exists: `which claude`
5. For corporate environments, see [Corporate VPN/Proxy Setup](#corporate-vpnproxy-setup) below

### MCP Server Issues
- Restart the Roo Code extension
- Check VS Code developer tools for MCP server logs
- Verify network connectivity within the container

### Permission Issues
- Ensure the container is running with proper user permissions
- Verify workspace directory access: `ls -la /workspaces/claude-codespace`

### Corporate VPN/Proxy Setup

⚠️ **Important**: Corporate environments with SSL interception or self-signed certificates can prevent Claude CLI installation and authentication.

#### Installation Issues
If Claude CLI fails to install during container build due to SSL certificate errors:

1. **Run the installation helper** (available after container starts):
   ```bash
   install-claude-helper
   ```

2. **Manual installation with disabled SSL** (INSECURE - development only):
   ```bash
   npm config set strict-ssl false
   npm install -g @anthropic-ai/claude-code
   npm config set strict-ssl true  # Re-enable after installation
   ```

3. **Configure corporate proxy** (if applicable):
   ```bash
   npm config set proxy http://your-proxy:port
   npm config set https-proxy http://your-proxy:port
   npm install -g @anthropic-ai/claude-code
   ```

4. **Custom certificates**: Place your corporate CA certificates in `.devcontainer/certs/` and uncomment the certificate copying section in the Dockerfile.

#### Authentication Limitations
**⚠️ Critical**: Even if Claude CLI installs successfully, `claude login` will fail in environments with:
- Self-signed certificates
- Corporate SSL interception
- Modified certificate chains

This is a security feature to protect authentication tokens and cannot be bypassed. The Claude CLI requires valid SSL certificates for authentication to ensure secure communication with Anthropic's servers.

**Workarounds**:
- Temporarily connect from a network without SSL interception for initial authentication
- Use Claude CLI from a personal device or network
- Request IT department to whitelist Anthropic domains from SSL inspection

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Comprehensive setup and usage guide
- **[.devcontainer/devcontainer.json](.devcontainer/devcontainer.json)** - Container configuration
- **[.roo/](.roo/)** - Workspace rules and mode configurations

## 📝 License

This template is provided as-is for development use. Customize freely for your projects.

---

**Ready to start?** Open this repository in VS Code and let the DevContainer handle the setup! 🎉