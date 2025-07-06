# Claude Code Setup Guide

## 🚀 Quick Start

1. **Fix Network Issues (Run This First)**
   ```bash
   ./scripts/fix-claude-ssl.sh
   ```

2. **Test Connectivity**
   ```bash
   curl -v https://api.anthropic.com/v1/messages
   ```
   Should show: `SSL certificate verify ok`

3. **Authenticate Claude CLI**
   ```bash
   claude login
   claude --version
   ```

## 🔧 Network Issues in Corporate Environments

**SSL certificate problems prevent Claude Code from working** with:
- Corporate VPNs
- Zscaler/Proxy services  
- Corporate firewalls
- Self-signed certificates

### Common Error Messages:
```
SSL certificate problem: self-signed certificate in certificate chain
SSL certificate problem: unable to get local issuer certificate
```

## ✅ Automated Solution

The [`fix-claude-ssl.sh`](scripts/fix-claude-ssl.sh) script automatically:
- Detects SSL certificate issues
- Extracts corporate certificates from the connection
- Installs certificates in the system trust store
- Configures Node.js/Claude CLI properly
- Validates the fix

```bash
# Run the fix script
./scripts/fix-claude-ssl.sh

# Verify it worked
curl -v https://api.anthropic.com/v1/messages

# Should show: SSL certificate verify ok
```

## 📍 Claude CLI Location

Claude CLI is installed at `/usr/bin/claude` in the DevContainer.

## 🔍 Troubleshooting

### 1. Network Issues
```bash
# First, run the automated fix
./scripts/fix-claude-ssl.sh

# Test connectivity
curl -v https://api.anthropic.com/v1/messages
```

### 2. Claude CLI Issues
```bash
# Verify installation
claude --version

# Check authentication
claude login
```

### 3. Container Issues
```bash
# Rebuild container
# Command Palette: "Dev Containers: Rebuild Container"

# Verify workspace
ls -la /workspaces/claude-codespace
```

## 📚 Additional Resources

- [`scripts/README.md`](scripts/README.md) - Detailed script documentation

---

**Key Point**: Always test network connectivity with `curl -v https://api.anthropic.com/v1/messages` before attempting to use Claude CLI.