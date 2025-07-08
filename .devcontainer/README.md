# DevContainer Configuration

Claude Code CLI + Roo Code extension optimized DevContainer setup.

## What's Included

- **Claude CLI**: Pre-installed at `/usr/bin/claude`
- **MCP Servers**: Context7 for documentation
- **Host Access**: Full filesystem access via `/mnt/`
- **Auto-Fix**: Network/SSL issues resolved automatically

## Quick Commands

```bash
# Check versions
check-versions

# Launch Claude Code interactive session
claude

# Test Claude CLI
claude --version

# Fix network issues (corporate environments)
./scripts/fix-claude-ssl.sh
```

## Configuration Files

- **devcontainer.json**: Main DevContainer configuration
- **Dockerfile**: Ubuntu base with Claude CLI setup
- **scripts/**: Setup and maintenance scripts
- **.terraform.rc**: Terraform CLI configuration