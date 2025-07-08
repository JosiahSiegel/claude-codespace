# Claude Code DevContainer - Project Overview

## Repository Summary
The **claude-codespace** repository is a production-ready DevContainer template specifically designed for seamless Claude Code CLI and Roo Code extension integration, with comprehensive corporate environment support.

## Key Features
- **🚀 Ready-to-Use**: Pre-configured DevContainer with Claude CLI at `/usr/bin/claude`
- **🏢 Corporate-Ready**: Automated SSL certificate handling for corporate networks
- **🤖 AI-Optimized**: Roo Code extension pre-installed with MCP server integration
- **🔧 Smart Automation**: Convenience scripts for authentication and troubleshooting
- **📦 Template**: Serves as a base for other Claude Code DevContainer setups

## Architecture

### Core Components
1. **Claude CLI Integration**
   - Pre-installed Claude CLI at `/usr/bin/claude`
   - Automatic authentication flow
   - Corporate network compatibility

2. **Roo Code Extension**
   - Pre-configured with auto-approval for read operations
   - MCP server integration via Context7
   - Seamless file context sharing

3. **Corporate Support**
   - SSL certificate extraction and installation
   - NODE_OPTIONS automation for corporate environments
   - VPN disconnection fallback strategies

4. **DevContainer Optimization**
   - Host filesystem access via `/mnt/`
   - Optimized for AI-assisted development
   - Consistent development environment

### File Structure
```
claude-codespace/
├── .roo/                          # Roo Code configuration
│   ├── mcp.json                   # MCP server settings
│   ├── rules/                     # AI assistant context rules
│   │   ├── 01-repository-context.md
│   │   ├── 02-devcontainer-guidance.md
│   │   ├── 03-ssl-corporate-networking.md
│   │   └── 04-development-workflows.md
│   └── project-overview.md        # This file
├── scripts/
│   └── fix-claude-ssl.sh         # Corporate SSL fix script
├── .roomodes                      # Roo Code modes configuration
├── README.md                      # User documentation
└── .gitignore                     # Git ignore patterns
```

## Usage Patterns

### For Template Users
- Clone and customize for specific project needs
- Inherit corporate network compatibility
- Leverage pre-configured AI assistant setup

### For Corporate Developers
- Run `./scripts/fix-claude-ssl.sh` for SSL setup
- Use convenience commands: `claude-corp /login`, `claude-login`
- Follow VPN disconnection fallback if needed

### For DevOps Teams
- Deploy as standard AI development environment
- Customize MCP servers and extensions as needed
- Monitor and update Claude CLI versions

## AI Assistant Integration

### Roo Code Optimization
- **Context Awareness**: Rules provide repository-specific guidance
- **Corporate Support**: Understands SSL/networking challenges
- **Workflow Integration**: Knows DevContainer-specific patterns
- **Template Understanding**: Recognizes this as a template repository

### Claude CLI Synergy
- **Complementary Usage**: Roo for editing, Claude CLI for complex tasks
- **Shared Context**: Both understand the DevContainer environment
- **Corporate Compatibility**: Both configured for enterprise use

## Troubleshooting Hierarchy

### Level 1: Automated Fixes
- Run SSL fix script: `sudo ./scripts/fix-claude-ssl.sh`
- Use convenience commands: `claude-corp /login`

### Level 2: Manual Interventions
- VPN disconnection fallback
- Manual NODE_OPTIONS configuration
- Container rebuild

### Level 3: IT Involvement
- Whitelist endpoints: `*.anthropic.com`, `*.claude.ai`
- Request SSL inspection bypass
- Export corporate root certificates

## Development Workflow
1. **Setup**: Clone → Open in DevContainer → Run SSL fix if needed
2. **Authentication**: Use convenience commands or fallback methods
3. **Development**: Leverage both Roo Code and Claude CLI
4. **Troubleshooting**: Follow automated → manual → IT escalation path

## Target Audiences
- **Individual Developers**: Quick Claude Code setup
- **Corporate Teams**: Enterprise-ready AI development
- **DevOps Engineers**: Standardized AI development environments
- **Template Users**: Base for custom Claude Code setups

This repository bridges the gap between AI-assisted development tools and enterprise network requirements, providing a seamless experience regardless of network environment.