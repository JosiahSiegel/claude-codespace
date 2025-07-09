# SSL & Corporate Networking

## Corporate SSL Fix
```bash
# Fix SSL issues
sudo .devcontainer/scripts/fix-claude-ssl.sh

# Login methods (after fix)
claude-corp /login                       # Smart wrapper
~/.local/bin/claude-corporate /login     # Immediate
claude-login                             # Alias
NODE_OPTIONS='--use-system-ca' claude /login  # Manual
```

## Key Points
- **Required for**: Zscaler, corporate firewalls, SSL inspection
- **Creates**: Certificate bundles, convenience commands
- **Fallback**: Disconnect VPN → login → reconnect
- **IT requests**: Whitelist *.anthropic.com, *.claude.ai