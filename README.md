# Claude Code DevContainer Template

Ready-to-use DevContainer setup optimized for [Claude Code](https://claude.ai/code) CLI and [Roo Code](https://marketplace.visualstudio.com/items?itemName=rooveterinaryinc.roo-cline) extension integration.

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

3. **Start Claude Code**
   ```bash
   # Launch interactive Claude Code session
   claude
   
   # Check version
   claude --version
   ```

4. **Start Coding**
   - Roo Code extension is pre-installed and configured
   - Claude CLI available at `/usr/bin/claude`
   - Authentication happens automatically on first run

## ✨ What's Included

- **Claude CLI**: Pre-installed and ready to use
- **Roo Code Extension**: AI assistant pre-configured
- **Host Filesystem Access**: Full access to your host machine via `/mnt/`
- **MCP Servers**: Context7 integration for documentation
- **SSL Fix Script**: Automatic corporate network compatibility

## 🔧 Network Issues?

**Corporate VPN/Proxy/Firewall causing problems?** Run the automated fix:

```bash
./scripts/fix-claude-ssl.sh
```

This script automatically detects and fixes SSL certificate issues, configures corporate proxy certificates, and validates the fix.

## 📋 Requirements

- VS Code with DevContainer extension
- Docker Desktop
- Claude Code account (for authentication)

## 🔍 Troubleshooting

### Claude CLI Not Working?
1. **First, try the network fix**: `./scripts/fix-claude-ssl.sh`
2. Rebuild container: `Dev Containers: Rebuild Container`
3. Verify installation: `claude --version`

### Check Tool Versions
```bash
check-versions
```

Ready to start? Open in VS Code and run `./scripts/fix-claude-ssl.sh` if you encounter any network issues! 🎉