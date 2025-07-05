# DevContainer Guidance

## DevContainer Optimization Best Practices

### Claude CLI Usage
- Always test Claude CLI availability with `claude --version`
- Use full path `/usr/bin/claude` when configuring Roo Code extension
- Verify MCP servers are properly connected before starting work

### File Operations
- All changes should be made within the workspace directory: `/workspaces/claude-codespace`
- Use relative paths for better portability
- Consider containerized environment limitations when suggesting file operations

### Command Execution
- Prefer containerized commands over host system commands
- Use `docker` commands when interacting with container infrastructure
- Always verify command availability in the container environment

### Workflow Efficiency
- Leverage auto-approval settings for read-only operations
- Use context mentions (`@filename`) to provide file context efficiently
- Utilize MCP servers for up-to-date documentation and examples

### Common DevContainer Commands
```bash
# Test Claude CLI
claude --version

# Check container status
docker ps

# Verify workspace permissions
ls -la /workspaces/claude-codespace

# Test MCP server connectivity
# (This will be tested automatically when using context7)
```

### Troubleshooting
- If Claude CLI is not found, check if it's properly installed at `/usr/bin/claude`
- For permission issues, verify the container is running with proper user permissions
- MCP server issues can often be resolved by restarting the Roo Code extension