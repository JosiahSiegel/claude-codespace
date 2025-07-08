# Repository Context

This is the **claude-codespace** repository - a comprehensive DevContainer setup optimized for Claude Code CLI and Roo Code extension integration.

## Repository Purpose
- **Primary**: Provides Claude Code CLI access within a DevContainer environment
- **Secondary**: Enables seamless Roo Code extension usage in containerized environments  
- **Template**: Serves as a template/example for Claude Code DevContainer setups
- **Corporate-Ready**: Includes corporate network/SSL troubleshooting capabilities

## Current Workspace
- **Workspace Path**: {{workspace}}
- **Operating System**: {{operatingSystem}}
- **Default Shell**: {{shell}}
- **Current Mode**: {{mode}}

## Key Components

### Claude CLI Integration
- **Claude CLI**: Pre-installed at `/usr/bin/claude`
- **Authentication**: Automatic on first run
- **Corporate Support**: SSL fix script for corporate networks

### Roo Code Extension
- **Pre-installed**: Roo Code extension pre-configured
- **MCP Integration**: Context7 server for documentation
- **Auto-approval**: Read-only operations enabled

### DevContainer Features
- **Host Access**: Full filesystem access via `/mnt/`
- **Container Optimization**: Optimized for AI-assisted development
- **Network Fixes**: Automated SSL/proxy certificate handling

## Development Context
When working in this repository, you should:
- **Understand**: This is specifically for Claude Code/Roo integration optimization
- **Focus**: DevContainer and CLI configuration improvements
- **Consider**: Containerized development workflows
- **Prioritize**: Seamless AI assistant integration

## File Structure
```
claude-codespace/
├── .roo/                     # Roo Code configuration
│   ├── mcp.json             # MCP server configuration
│   └── rules/               # Context rules for AI assistant
├── scripts/                 # Utility scripts
│   └── fix-claude-ssl.sh    # Corporate SSL/network fix script
├── .roomodes               # Roo Code modes configuration
├── README.md               # Repository documentation
└── .gitignore              # Git ignore patterns
```

## Target Users
- **Developers**: Using Claude Code CLI in corporate environments
- **DevOps**: Setting up AI-assisted development environments
- **Corporate Users**: Dealing with SSL/proxy restrictions
- **Template Users**: Creating similar Claude Code setups