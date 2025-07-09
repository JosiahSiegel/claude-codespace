# Claude DevContainer - Project Overview

## Summary
**claude-codespace** - Production-ready DevContainer for Claude CLI & Roo Code with corporate network support.

## Key Features
- 🚀 Pre-configured Claude CLI (`/usr/bin/claude`)
- 🏢 Corporate SSL certificate handling
- 🤖 Roo Code + MCP (Context7) integration
- 🔧 Automation scripts & troubleshooting tools

## Quick Start
1. Clone → Open in DevContainer
2. Corporate users: `sudo .devcontainer/scripts/fix-claude-ssl.sh`
3. Login: `claude-corp /login` or `claude-login`
4. Verify: `claude --version` & `check-versions`

## Structure
```
.roo/              # Roo configuration
├── mcp.json       # MCP servers
├── rules/         # AI context rules
└── project-overview.md
scripts/           # Helper scripts
.roomodes          # Roo modes
```

## Corporate Troubleshooting
1. **Auto**: Run SSL fix script
2. **Manual**: Disconnect VPN → login → reconnect
3. **IT**: Whitelist *.anthropic.com, *.claude.ai

## Usage
- **Template**: Base for custom Claude setups
- **Development**: Use Roo (editing) + Claude CLI (complex tasks)
- **Host Access**: `/mnt/[drive]` (Windows), `/host` (full root)

## Commands
- `devcontainer-help` - Full documentation
- `check-versions` - Tool versions
- `claude-corp /login` - Corporate login