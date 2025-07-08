# Development Workflows

## Claude Code DevContainer Specific Workflows

### Initial Setup Workflow
1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd claude-codespace
   ```

2. **Open in DevContainer**
   - Launch VS Code
   - Open folder in VS Code
   - Click "Reopen in Container" when prompted
   - Wait for container build and initialization

3. **Verify Environment**
   ```bash
   # Test Claude CLI availability
   claude --version
   
   # Check MCP server connectivity
   # (will be tested automatically via Context7)
   
   # Verify Roo Code extension is loaded
   # Check VS Code extensions panel
   ```

4. **Handle Corporate Networks (if needed)**
   ```bash
   # Run SSL fix script for corporate environments
   sudo ./scripts/fix-claude-ssl.sh
   
   # Follow the authentication instructions provided
   ```

### Daily Development Workflow

#### Starting a Session
1. **Environment Check**
   ```bash
   claude --version
   ```
   
2. **Authentication (corporate environments)**
   ```bash
   # Use convenience commands created by SSL fix script
   claude-corp /login  # After terminal restart
   # OR immediately:
   ~/.local/bin/claude-corporate /login
   ```

3. **Verify Connectivity**
   ```bash
   # Test API connectivity
   curl -v https://api.anthropic.com/v1/messages
   ```

#### Working with Claude Code
- **Interactive Mode**: Use `claude` command for conversational interface
- **Roo Code Integration**: Use Roo Code extension for in-editor assistance
- **File Context**: Leverage `@filename` mentions for file-specific queries
- **MCP Resources**: Utilize Context7 for up-to-date documentation

#### Working with Scripts
- **SSL Fix**: Re-run `./scripts/fix-claude-ssl.sh` when:
  - Network connectivity issues arise
  - VPN configuration changes
  - Need to refresh convenience commands
  - Setting up new environments

### Troubleshooting Workflow

#### Authentication Issues
1. **Check Environment Variables**
   ```bash
   echo $NODE_OPTIONS
   # Should show: --use-system-ca (for corporate environments)
   ```

2. **Verify Certificate Configuration**
   ```bash
   # Check if certificate bundle exists
   ls -la ~/.local/share/ca-certificates/claude-ssl-fix/
   ```

3. **Test Connectivity**
   ```bash
   # Test API endpoint directly
   curl -v https://api.anthropic.com/v1/messages
   ```

4. **Re-run SSL Fix**
   ```bash
   sudo ./scripts/fix-claude-ssl.sh
   ```

#### Container Issues
1. **Rebuild Container**
   - Command Palette: `Dev Containers: Rebuild Container`
   
2. **Check Container Status**
   ```bash
   docker ps
   docker logs <container-id>
   ```

3. **Verify Mounts**
   ```bash
   # Check host filesystem access
   ls -la /mnt/
   ```

### File Management Patterns

#### Workspace Organization
- **Primary Development**: `/workspaces/claude-codespace/`
- **Host Access**: `/mnt/` for accessing host filesystem
- **Configuration**: `.roo/` directory for Roo-specific settings
- **Scripts**: `scripts/` directory for utility scripts

#### File Operation Best Practices
- Use relative paths within workspace
- Consider containerized environment when suggesting operations
- Leverage DevContainer features for consistent environments
- Use MCP servers for accessing external documentation

### Integration Patterns

#### Claude Code + Roo Code Synergy
- **Use Claude CLI** for complex problem-solving sessions
- **Use Roo Code** for real-time editing assistance
- **Combine approaches** for comprehensive development workflow
- **Leverage MCP servers** for accessing latest documentation

#### Corporate Environment Considerations
- **Always use NODE_OPTIONS='--use-system-ca'** for authentication
- **Leverage convenience commands** created by SSL fix script
- **Consider VPN disconnection** as fallback authentication method
- **Contact IT** for persistent SSL inspection bypass if needed

### Repository Maintenance

#### Keeping Templates Updated
- Monitor Claude CLI updates
- Update DevContainer configuration as needed
- Refresh SSL fix script for new corporate environments
- Update MCP server configurations

#### Documentation Updates
- Keep README.md current with latest setup procedures
- Update .roo rules with new patterns and workflows
- Document new troubleshooting scenarios
- Maintain script documentation inline