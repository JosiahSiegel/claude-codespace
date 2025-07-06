# Network Fix Script

Automated solution to resolve SSL certificate and network connectivity issues for Claude Code.

## 🚀 Quick Start

**Having network issues?** Run this:

```bash
./scripts/fix-claude-ssl.sh
```

## 📁 The Solution

### [`fix-claude-ssl.sh`](fix-claude-ssl.sh) - **Complete SSL Fix**
**Comprehensive SSL certificate fix for corporate environments**

- **Detects**: VPNs, proxies, corporate firewalls, Zscaler
- **Extracts**: Corporate certificates from live connections  
- **Installs**: Certificates in system trust store
- **Configures**: Node.js/Claude CLI with `NODE_EXTRA_CA_CERTS`
- **Validates**: Fix with `curl -v https://api.anthropic.com/v1/messages`

```bash
# Basic usage
./scripts/fix-claude-ssl.sh

# With verbose output
./scripts/fix-claude-ssl.sh --verbose

# With safety backup
./scripts/fix-claude-ssl.sh --restore-on-failure

# Get help
./scripts/fix-claude-ssl.sh --help
```

## 🔧 How It Works

1. **Detection**: Tests network connectivity and identifies SSL certificate issues
2. **Extraction**: Uses `openssl s_client` to extract corporate certificate chain
3. **Installation**: Installs certificates in `/usr/local/share/ca-certificates/claude-ssl-fix/`
4. **Configuration**: Sets `NODE_EXTRA_CA_CERTS` environment variable
5. **Validation**: Confirms fix with connectivity test

## ✅ Success Indicators

After running the fix script, you should see:

```bash
$ curl -v https://api.anthropic.com/v1/messages
* SSL certificate verify ok
< HTTP/2 405
{"type":"error","error":{"type":"invalid_request_error","message":"Method Not Allowed"}}
```

The "Method Not Allowed" error is **expected** (GET vs POST), but SSL should work.

## 🏢 Corporate Environment Support

**Automatically handles:**
- Zscaler proxies
- Corporate VPN SSL interception
- Self-signed certificate chains
- Missing certificate authorities
- Proxy authentication (basic detection)

## 🔍 Troubleshooting

### Script Won't Run
```bash
# Make executable
chmod +x scripts/fix-claude-ssl.sh

# Run with bash explicitly
bash scripts/fix-claude-ssl.sh
```

### Still Getting SSL Errors
```bash
# Check if certificates were installed
ls -la /usr/local/share/ca-certificates/claude-ssl-fix/

# Verify environment variable
echo $NODE_EXTRA_CA_CERTS

# Re-source shell configuration
source ~/.bashrc
```

### Need to Restore Original Settings
```bash
# If backup was created during fix
ls -la /root/.claude-ssl-backup/

# Contact IT for original corporate certificates
```

---

**Bottom Line**: Run [`./scripts/fix-claude-ssl.sh`](fix-claude-ssl.sh) to automatically resolve SSL certificate issues in corporate environments.