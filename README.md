# Claude Code DevContainer Template

A ready-to-use DevContainer setup optimized for [Claude Code](https://claude.ai/code) CLI and [Roo Code](https://marketplace.visualstudio.com/items?itemName=rooveterinaryinc.roo-cline) extension integration.

## 🚀 Quick Start

1. **Open in DevContainer**
   - Clone this repository
   - Open in VS Code
   - Click "Reopen in Container" when prompted

2. **Fix Network Issues (If Needed)**
   ```bash
   # Run if you encounter SSL/network connectivity issues
   ./scripts/fix-claude-ssl.sh
   ```

3. **Authenticate Claude CLI**
   ```bash
   claude login
   claude --version
   ```

4. **Start Coding**
   - Roo Code extension is pre-installed and configured
   - Claude CLI available at `/usr/bin/claude`

## 🔧 Network Issues?

**Corporate VPN/Proxy/Firewall causing problems?** Run the automated fix:

```bash
./scripts/fix-claude-ssl.sh
```

This script automatically:
- Detects and fixes SSL certificate issues
- Configures corporate proxy certificates
- Enables Claude CLI to work with VPNs and firewalls
- Validates the fix with `curl -v https://api.anthropic.com/v1/messages`

## ✨ What's Included

- **Claude CLI**: Pre-installed and ready to use
- **Roo Code Extension**: AI assistant pre-configured
- **Host Filesystem Access**: Full access to your host machine
- **MCP Servers**: Context7 integration for documentation
- **SSL Fix Script**: Automatic corporate network compatibility

## 📋 Requirements

- VS Code with DevContainer extension
- Docker Desktop
- Claude Code account (for authentication)

## 🗂️ File Access

- **Workspace**: `/workspaces/claude-codespace/`
- **Host Drives**: `/mnt/c/`, `/mnt/d/`, etc.
- **WSL Context**: `/mnt/wsl/`

## 🔍 Troubleshooting

### Claude CLI Not Working?
1. **First, try the network fix**: `./scripts/fix-claude-ssl.sh`
2. Rebuild container: `Dev Containers: Rebuild Container`
3. Verify installation: `claude --version`

### Still Having Issues?
- Check [CLAUDE.md](CLAUDE.md) for detailed setup instructions
- Review [scripts/README.md](scripts/README.md) for the SSL fix script

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - Detailed setup and configuration guide
- **[scripts/README.md](scripts/README.md)** - Network diagnostic and fix tools

---

**Ready to start?** Open in VS Code and run `./scripts/fix-claude-ssl.sh` if you encounter any network issues! 🎉