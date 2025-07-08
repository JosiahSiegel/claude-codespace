# SSL & Corporate Networking

## Corporate Environment Support

This repository includes comprehensive corporate network and SSL certificate support through the [`scripts/fix-claude-ssl.sh`](scripts/fix-claude-ssl.sh) script.

### Corporate Environment Features

#### Automatic SSL Certificate Handling
- **Certificate Detection**: Automatically detects corporate proxy/firewall certificates
- **Certificate Extraction**: Extracts certificates from current SSL connections
- **Bundle Creation**: Creates comprehensive certificate bundles combining system + corporate certs
- **System Integration**: Installs certificates into system certificate store

#### Authentication Convenience Commands
The SSL fix script automatically creates these convenience commands:

```bash
# Smart wrapper (auto-applies NODE_OPTIONS)
claude-corp /login
~/.local/bin/claude-corporate /login

# Simple alias
claude-login  # Equivalent to: NODE_OPTIONS='--use-system-ca' claude /login

# Manual command
NODE_OPTIONS='--use-system-ca' claude /login
```

#### VPN Disconnection Fallback
- **Temporary VPN disconnection** is a valid troubleshooting method
- OAuth tokens are cached, so this is only needed once per environment
- Reconnect VPN after successful authentication

### Common Corporate Network Issues

#### SSL Certificate Problems
- **Zscaler**: Corporate proxy certificates automatically detected and installed
- **Corporate Firewalls**: SSL inspection bypass certificates handled
- **Self-signed Certificates**: Custom CA certificates integrated

#### Authentication Requirements
- **NODE_OPTIONS='--use-system-ca'** is **REQUIRED** for corporate environments
- Standard `claude /login` often fails due to certificate chain issues
- The fix script automatically configures this requirement

### Script Capabilities

#### What the Script Does
1. **Diagnoses** SSL connectivity issues to Claude API endpoints
2. **Extracts** corporate certificates from active connections
3. **Creates** comprehensive certificate bundles
4. **Configures** Node.js environment variables automatically
5. **Installs** convenience aliases and smart wrappers
6. **Tests** the fix and provides clear next steps

#### When to Run the Script
- **Initial setup** in corporate environments
- **Network connectivity issues** with Claude CLI
- **SSL certificate errors** 
- **To refresh convenience commands** (runs every time)
- **After VPN configuration changes**

### Troubleshooting Workflow

#### Step 1: Run the SSL Fix Script
```bash
sudo ./scripts/fix-claude-ssl.sh
```

#### Step 2: Authentication Methods (in order of preference)
1. **Smart wrapper**: `claude-corp /login` (after terminal restart)
2. **Immediate**: `~/.local/bin/claude-corporate /login`
3. **Alias**: `claude-login` (after terminal restart)
4. **Manual**: `NODE_OPTIONS='--use-system-ca' claude /login`
5. **Fallback**: Disconnect VPN, run `claude /login`, reconnect

#### Step 3: Verify Setup
```bash
# Test CLI
claude --version

# Test connectivity
curl -v https://api.anthropic.com/v1/messages
```

### Key Files Created
- **Certificate Bundle**: `~/.local/share/ca-certificates/claude-ssl-fix/complete-ca-bundle.crt`
- **Smart Wrapper**: `~/.local/bin/claude-corporate`
- **Shell Profile**: Updated with aliases and environment variables

### IT Requirements
For persistent corporate environment usage, contact IT to:
- **Whitelist**: `*.anthropic.com`, `*.claude.ai`
- **SSL Bypass**: Request SSL inspection bypass for Claude endpoints
- **Certificate Export**: Provide corporate root certificates if needed