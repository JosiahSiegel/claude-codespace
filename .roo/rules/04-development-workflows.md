# Development Workflows

## Initial Setup
1. Clone → Open in DevContainer → Verify with `claude --version`
2. Corporate networks: Run `sudo .devcontainer/scripts/fix-claude-ssl.sh`

## Daily Workflow
- Start: `claude --version` + corporate auth if needed
- Use: `claude` (CLI), Roo Code (editor), `@filename` (context)
- Troubleshoot: Re-run SSL fix, check NODE_OPTIONS

## File Paths
- **Workspace**: `/workspaces/claude-codespace/`
- **Host drives**: `/mnt/c`, `/mnt/d` (via symlinks)
- **Full host**: `/host` (complete filesystem)

## Key Integrations
- Claude CLI + Roo Code for comprehensive workflow
- Context7 MCP for documentation
- Corporate: Use convenience commands from SSL fix