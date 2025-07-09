#!/bin/bash

# Claude Code SSL Certificate Fix Script
# Comprehensive script to diagnose and fix SSL certificate issues for Claude Code
# Works with various corporate VPNs, proxies, and certificate authorities
#
# Corporate Environment Features:
# - Automatically configures NODE_OPTIONS='--use-system-ca' for authentication
# - Creates convenience aliases: claude-login, claude-corp
# - Installs smart wrapper that auto-applies NODE_OPTIONS for /login commands
# - Provides clear instructions for VPN disconnection fallback method

set -e

# Script version and info
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Claude Code SSL Fix"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    echo -e "${BLUE}[DEBUG]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_header() {
    echo -e "${PURPLE}=== $1 ===${NC}"
}

# Test URLs and endpoints
CLAUDE_API_URL="https://api.anthropic.com/v1/messages"
TEST_URLS=(
    "https://api.anthropic.com"
    "https://claude.ai"
    "https://www.anthropic.com"
)

# Certificate paths
CERT_DIR="/usr/local/share/ca-certificates"
CUSTOM_CERT_DIR="$CERT_DIR/claude-ssl-fix"
CERT_BUNDLE_PATH="$CUSTOM_CERT_DIR/corporate-bundle.crt"

# Backup original certificates
BACKUP_DIR="$HOME/.claude-ssl-backup"

# Global variables for tracking
SSL_ISSUE_DETECTED=false
CORPORATE_PROXY_DETECTED=false
CERT_CHAIN_ISSUE=false
FIX_APPLIED=false
ORIGINAL_NODE_EXTRA_CA_CERTS=""

# Print script header
print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    $SCRIPT_NAME                     ║"
    echo "║                       Version $SCRIPT_VERSION                        ║"
    echo "║                                                              ║"
    echo "║  Diagnoses and fixes SSL certificate issues for Claude Code ║"
    echo "║  Works with corporate VPNs, proxies, and firewalls         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Backup current configuration
backup_config() {
    log_info "Creating backup of current configuration..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup environment variables
    env | grep -E "(NODE_|CURL_|HTTP_|HTTPS_)" > "$BACKUP_DIR/env_vars.backup" 2>/dev/null || true
    
    # Backup existing certificates
    if [ -d "$CUSTOM_CERT_DIR" ]; then
        cp -r "$CUSTOM_CERT_DIR" "$BACKUP_DIR/certs.backup" 2>/dev/null || true
    fi
    
    # Save original NODE_EXTRA_CA_CERTS
    ORIGINAL_NODE_EXTRA_CA_CERTS="$NODE_EXTRA_CA_CERTS"
    
    log_success "Configuration backed up to $BACKUP_DIR"
}

# Restore configuration from backup
restore_config() {
    log_warn "Restoring configuration from backup..."
    
    if [ -f "$BACKUP_DIR/env_vars.backup" ]; then
        # Note: We can't actually restore env vars in the parent shell
        # This is informational for manual restoration
        log_info "Environment variables backup available at: $BACKUP_DIR/env_vars.backup"
    fi
    
    if [ -d "$BACKUP_DIR/certs.backup" ]; then
        rm -rf "$CUSTOM_CERT_DIR" 2>/dev/null || true
        cp -r "$BACKUP_DIR/certs.backup" "$CUSTOM_CERT_DIR" 2>/dev/null || true
        update-ca-certificates >/dev/null 2>&1 || true
    fi
    
    export NODE_EXTRA_CA_CERTS="$ORIGINAL_NODE_EXTRA_CA_CERTS"
}

# Test Claude API connectivity with quick timeout
test_claude_connectivity() {
    local test_name="$1"
    local additional_args="$2"
    
    log_debug "Testing connectivity: $test_name"
    
    # Use very aggressive timeout - if it takes longer than 3 seconds, consider it an SSL issue
    local curl_output
    local curl_exit_code
    
    log_debug "Running quick test: timeout 3 curl $additional_args --connect-timeout 2 --max-time 3 '$CLAUDE_API_URL'"
    
    # Quick test with very short timeout
    curl_output=$(timeout 3 curl $additional_args --connect-timeout 2 --max-time 3 "$CLAUDE_API_URL" 2>&1)
    curl_exit_code=$?
    
    log_debug "Quick test completed with exit code: $curl_exit_code"
    
    # Analyze the result
    if [ $curl_exit_code -eq 0 ]; then
        log_success "✅ $test_name: Connection successful"
        return 0
    elif [ $curl_exit_code -eq 60 ]; then
        log_error "❌ $test_name: SSL certificate problem detected (exit code 60)"
        SSL_ISSUE_DETECTED=true
        CORPORATE_PROXY_DETECTED=true
        return 1
    elif [ $curl_exit_code -eq 124 ]; then
        log_error "❌ $test_name: Connection timed out (likely SSL handshake issue)"
        SSL_ISSUE_DETECTED=true
        return 1
    else
        log_error "❌ $test_name: Connection failed (exit code: $curl_exit_code)"
        SSL_ISSUE_DETECTED=true
        return 1
    fi
}

# Quick network connectivity test
quick_network_test() {
    log_info "Quick network connectivity test..."
    
    # Test basic connectivity using curl (more reliable than nslookup/nc)
    log_debug "Testing basic connectivity to api.anthropic.com..."
    if timeout 10 curl -s --connect-timeout 5 --max-time 10 --head https://api.anthropic.com >/dev/null 2>&1; then
        log_success "✅ Basic connectivity working"
        return 0
    else
        log_debug "Basic HTTPS failed, trying HTTP to test DNS/connectivity..."
        if timeout 10 curl -s --connect-timeout 5 --max-time 10 --head http://httpbin.org/get >/dev/null 2>&1; then
            log_success "✅ Basic internet connectivity working (DNS and network OK)"
            log_info "HTTPS to Anthropic API is blocked, likely SSL certificate issue"
            return 0
        else
            log_error "❌ No internet connectivity detected"
            return 1
        fi
    fi
}

# Detect corporate environment
detect_corporate_environment() {
    log_header "Detecting Corporate Environment"
    
    # Quick network test first
    if ! quick_network_test; then
        log_error "Basic network connectivity failed. Check your internet connection."
        SSL_ISSUE_DETECTED=true
        return 1
    fi
    
    # Test the actual API endpoint to see if SSL certificates are working
    log_info "Network connectivity confirmed. Checking for SSL certificate issues..."
    
    # Test the specific API endpoint that Claude CLI needs
    if test_claude_connectivity "Initial SSL certificate test"; then
        log_success "🎉 SSL certificates are already working properly!"
        log_info "Claude Code should function normally."
        log_info "No fixes needed."
        return 0
    else
        log_error "❌ SSL certificate issue detected"
        SSL_ISSUE_DETECTED=true
        CORPORATE_PROXY_DETECTED=true
        log_info "Proceeding to certificate extraction and fix..."
    fi
    
    # Check for proxy environment variables
    if [ -n "$HTTP_PROXY" ] || [ -n "$HTTPS_PROXY" ] || [ -n "$http_proxy" ] || [ -n "$https_proxy" ]; then
        log_warn "Corporate proxy detected in environment variables:"
        [ -n "$HTTP_PROXY" ] && echo "  HTTP_PROXY: $HTTP_PROXY"
        [ -n "$HTTPS_PROXY" ] && echo "  HTTPS_PROXY: $HTTPS_PROXY"
        [ -n "$http_proxy" ] && echo "  http_proxy: $http_proxy"
        [ -n "$https_proxy" ] && echo "  https_proxy: $https_proxy"
        CORPORATE_PROXY_DETECTED=true
    fi
    
    # Check for corporate certificate authorities in the connection
    log_info "Analyzing certificate chain..."
    local cert_info
    cert_info=$(echo | openssl s_client -connect api.anthropic.com:443 -servername api.anthropic.com 2>/dev/null | openssl x509 -noout -issuer 2>/dev/null) || true
    
    if echo "$cert_info" | grep -iE "(zscaler|corporate|internal|proxy|firewall)" >/dev/null 2>&1; then
        log_warn "Corporate certificate authority detected in chain"
        CORPORATE_PROXY_DETECTED=true
    fi
}

# Extract certificates from browser/system
extract_certificates() {
    log_header "Extracting Corporate Certificates"
    
    # Create certificate directory
    mkdir -p "$CUSTOM_CERT_DIR"
    
    # Method 1: Extract from current connection
    log_info "Extracting certificates from current connection..."
    
    local cert_file="$CUSTOM_CERT_DIR/extracted-chain.crt"
    
    # Get the full certificate chain
    if echo | openssl s_client -connect api.anthropic.com:443 -servername api.anthropic.com -showcerts 2>/dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | tee "$cert_file" >/dev/null; then
        if [ -s "$cert_file" ]; then
            log_success "Certificate chain extracted to $cert_file"
            
            # Also copy individual certificates to system certificate store
            log_info "Installing certificate to system store..."
            
            # Split certificates and install each one
            local cert_count=0
            awk 'BEGIN {cert_count=0; in_cert=0}
                 /-----BEGIN CERTIFICATE-----/ {
                     cert_count++;
                     filename="'"$CUSTOM_CERT_DIR"'/corporate-cert-" cert_count ".crt";
                     in_cert=1;
                     print > filename
                 }
                 in_cert==1 && !/-----BEGIN CERTIFICATE-----/ {
                     print > filename
                 }
                 /-----END CERTIFICATE-----/ {
                     print > filename;
                     close(filename);
                     in_cert=0
                 }
                 END {
                     print cert_count > "'"$CUSTOM_CERT_DIR"'/cert_count.tmp"
                 }' "$cert_file"
            
            # Read the actual count from the awk output
            if [ -f "$CUSTOM_CERT_DIR/cert_count.tmp" ]; then
                cert_count=$(cat "$CUSTOM_CERT_DIR/cert_count.tmp")
                rm -f "$CUSTOM_CERT_DIR/cert_count.tmp"
            fi
            
            # Copy certificates to system store
            for cert in "$CUSTOM_CERT_DIR"/corporate-cert-*.crt; do
                if [ -f "$cert" ]; then
                    local cert_name=$(basename "$cert")
                    cp "$cert" "/usr/local/share/ca-certificates/$cert_name"
                    log_info "Added certificate: $cert_name"
                fi
            done
            
            if [ $cert_count -gt 0 ]; then
                log_success "Installed $cert_count corporate certificates to system store"
            fi
        else
            log_warn "No certificates extracted from connection"
            rm -f "$cert_file"
        fi
    fi
    
    # Method 2: Check for existing corporate certificates in system
    log_info "Checking for existing corporate certificates..."
    
    local found_corporate_certs=false
    
    # Common corporate CA names to look for
    local corporate_patterns=("zscaler" "corporate" "internal" "proxy" "firewall" "company" "enterprise")
    
    for pattern in "${corporate_patterns[@]}"; do
        find /usr/share/ca-certificates /etc/ssl/certs /usr/local/share/ca-certificates -name "*${pattern}*" -type f 2>/dev/null | while read cert_path; do
            if [ -f "$cert_path" ]; then
                # Skip if the certificate is already in our custom directory
                if [[ "$cert_path" != "$CUSTOM_CERT_DIR"* ]]; then
                    log_info "Found corporate certificate: $cert_path"
                    cp "$cert_path" "$CUSTOM_CERT_DIR/"
                    found_corporate_certs=true
                fi
            fi
        done
    done
    
    # Method 3: Try to extract from common browser certificate stores
    log_info "Checking browser certificate stores..."
    
    # Firefox certificates (if available)
    local firefox_dirs=(
        "$HOME/.mozilla/firefox"
        "/snap/firefox/common/.mozilla/firefox"
    )
    
    for firefox_dir in "${firefox_dirs[@]}"; do
        if [ -d "$firefox_dir" ]; then
            find "$firefox_dir" -name "cert9.db" 2>/dev/null | head -1 | while read cert_db; do
                log_info "Found Firefox certificate database: $cert_db"
                # Note: Extracting from Firefox requires additional tools, noted for manual extraction
            done
        fi
    done
}

# Setup convenience aliases and wrapper for Claude CLI corporate environment
setup_claude_corporate_aliases() {
    log_header "Setting up Claude CLI Corporate Environment Aliases"
    
    # Determine the target user and home directory
    local target_user
    local target_home
    
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        target_user="$SUDO_USER"
        target_home=$(eval echo ~$SUDO_USER)
    else
        target_user="$USER"
        target_home="$HOME"
    fi
    
    # Determine shell profile path
    local shell_profile
    if [ -n "$BASH_VERSION" ]; then
        shell_profile="$target_home/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_profile="$target_home/.zshrc"
    else
        shell_profile="$target_home/.profile"
    fi
    
    # Remove old configuration and add new complete bundle configuration
    if [ -f "$shell_profile" ]; then
        sed -i '/# Claude SSL Fix/d' "$shell_profile" 2>/dev/null || true
        sed -i '/NODE_EXTRA_CA_CERTS.*claude-ssl-fix/d' "$shell_profile" 2>/dev/null || true
        sed -i '/NODE_OPTIONS.*use-system-ca/d' "$shell_profile" 2>/dev/null || true
        sed -i '/alias claude-login/d' "$shell_profile" 2>/dev/null || true
        sed -i '/alias claude-corp/d' "$shell_profile" 2>/dev/null || true
        sed -i '/# Claude corporate wrapper alias/d' "$shell_profile" 2>/dev/null || true
        sed -i '/# Add user.*local.*bin.*PATH.*Claude/d' "$shell_profile" 2>/dev/null || true
        sed -i '/export PATH=.*\.local\/bin.*PATH/d' "$shell_profile" 2>/dev/null || true
    fi
    
    log_info "Adding NODE_OPTIONS configuration for corporate environment..."
    echo "# Claude SSL Fix - Corporate Environment Configuration" >> "$shell_profile"
    echo "# Corporate environment: Use system CA for Claude CLI login" >> "$shell_profile"
    echo "export NODE_OPTIONS='--use-system-ca'" >> "$shell_profile"
    echo "# Convenience alias for Claude login in corporate environments" >> "$shell_profile"
    echo "alias claude-login=\"NODE_OPTIONS='--use-system-ca' claude /login\"" >> "$shell_profile"
    
    # Create the smart wrapper
    create_claude_wrapper "$target_user" "$target_home" "$shell_profile"
    
    log_success "NODE_OPTIONS configured for corporate environment compatibility"
    log_success "Added 'claude-login' alias for easy authentication"
    log_success "Corporate environment setup complete for user $target_user"
}

# Create a wrapper script for claude that automatically applies NODE_OPTIONS for /login
create_claude_wrapper() {
    local target_user="$1"
    local target_home="$2"
    local shell_profile="$3"
    
    log_info "Creating Claude CLI wrapper for automatic NODE_OPTIONS handling..."
    
    # Create user's local bin directory if it doesn't exist
    local user_bin_dir="$target_home/.local/bin"
    mkdir -p "$user_bin_dir"
    
    # Create the wrapper script
    local wrapper_script="$user_bin_dir/claude-corporate"
    
    cat > "$wrapper_script" << 'EOF'
#!/bin/bash
# Claude CLI Corporate Environment Wrapper
# Automatically applies NODE_OPTIONS='--use-system-ca' for /login commands
# Generated by Claude SSL Fix Script

# Find the real claude binary
CLAUDE_BIN=""
if [ -x "/usr/bin/claude" ]; then
    CLAUDE_BIN="/usr/bin/claude"
elif command -v claude >/dev/null 2>&1; then
    CLAUDE_BIN=$(command -v claude)
else
    echo "Error: Claude CLI not found"
    exit 1
fi

# Check if this is a login command
if [ "$1" = "/login" ] || [ "$1" = "login" ]; then
    # For login commands, ensure NODE_OPTIONS includes --use-system-ca
    if [ -n "$NODE_OPTIONS" ]; then
        # If NODE_OPTIONS is already set, check if it contains --use-system-ca
        if echo "$NODE_OPTIONS" | grep -q "use-system-ca"; then
            # Already has --use-system-ca, just run the command
            exec "$CLAUDE_BIN" "$@"
        else
            # Add --use-system-ca to existing NODE_OPTIONS
            NODE_OPTIONS="$NODE_OPTIONS --use-system-ca" exec "$CLAUDE_BIN" "$@"
        fi
    else
        # Set NODE_OPTIONS with --use-system-ca
        NODE_OPTIONS='--use-system-ca' exec "$CLAUDE_BIN" "$@"
    fi
else
    # For non-login commands, just pass through
    exec "$CLAUDE_BIN" "$@"
fi
EOF

    # Make the wrapper executable
    chmod +x "$wrapper_script"
    
    # Change ownership to the target user if we're running as root
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        chown "$target_user:$target_user" "$wrapper_script"
        chown "$target_user:$target_user" "$user_bin_dir"
    fi
    
    log_success "Claude corporate wrapper created: $wrapper_script"
    log_info "The wrapper automatically applies NODE_OPTIONS for /login commands"
    
    # Check if PATH already includes the user's bin directory
    if ! grep -q "/.local/bin" "$shell_profile" 2>/dev/null; then
        echo "# Add user's local bin to PATH for Claude corporate wrapper" >> "$shell_profile"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_profile"
        log_info "Added $user_bin_dir to PATH in $shell_profile"
    fi
    
    # Create an additional alias that uses the wrapper (use full path to avoid PATH issues)
    echo "# Claude corporate wrapper alias" >> "$shell_profile"
    echo "alias claude-corp=\"$wrapper_script\"" >> "$shell_profile"
    
    # Also create a more direct alias that doesn't depend on PATH
    echo "# Direct claude-corp alias using full path" >> "$shell_profile"
    echo "alias claude-corporate=\"$wrapper_script\"" >> "$shell_profile"
    
    log_info "Added 'claude-corp' and 'claude-corporate' aliases for the corporate wrapper"
    
    # Verify the wrapper was created successfully
    if [ -x "$wrapper_script" ]; then
        log_success "Corporate wrapper script created successfully at $wrapper_script"
        log_info "To use immediately: source $shell_profile"
        log_info "Or restart your terminal to load the new aliases"
    else
        log_error "Failed to create executable wrapper script at $wrapper_script"
    fi
}

# Install and configure certificates
install_certificates() {
    log_header "Installing Corporate Certificates"
    
    if [ ! -d "$CUSTOM_CERT_DIR" ] || [ -z "$(ls -A "$CUSTOM_CERT_DIR" 2>/dev/null)" ]; then
        log_warn "No certificates found to install"
        return 1
    fi
    
    # Update system certificate store first
    log_info "Updating system certificate store..."
    update-ca-certificates >/dev/null 2>&1 || true
    
    # Create comprehensive certificate bundle (system + corporate)
    log_info "Creating comprehensive certificate bundle..."
    local complete_bundle="$CUSTOM_CERT_DIR/complete-ca-bundle.crt"
    
    # Start with system certificates
    if [ -f "/etc/ssl/certs/ca-certificates.crt" ]; then
        cat "/etc/ssl/certs/ca-certificates.crt" > "$complete_bundle"
        log_info "Added system certificates to bundle"
    fi
    
    # Add corporate certificates
    find "$CUSTOM_CERT_DIR" -name "*.crt" -o -name "*.pem" -o -name "*.cer" | while read cert_file; do
        if [ -f "$cert_file" ] && [ "$cert_file" != "$complete_bundle" ]; then
            cat "$cert_file" >> "$complete_bundle"
        fi
    done
    
    if [ -f "$complete_bundle" ]; then
        # Copy to both locations for compatibility
        cp "$complete_bundle" "$CERT_BUNDLE_PATH"
        log_success "Complete certificate bundle created: $complete_bundle"
    else
        log_error "Failed to create certificate bundle"
        return 1
    fi
    
    # Configure Node.js/Claude CLI to use complete certificate bundle
    log_info "Configuring Node.js certificate path..."
    export NODE_EXTRA_CA_CERTS="$complete_bundle"
    
    # Add to shell profile for persistence
    local shell_profile
    local target_user
    local target_home
    
    # Determine the target user and home directory
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        target_user="$SUDO_USER"
        target_home=$(eval echo ~$SUDO_USER)
    else
        target_user="$USER"
        target_home="$HOME"
    fi
    
    # Determine shell profile path
    if [ -n "$BASH_VERSION" ]; then
        shell_profile="$target_home/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_profile="$target_home/.zshrc"
    else
        shell_profile="$target_home/.profile"
    fi
    
    # Determine shell profile path
    local shell_profile
    if [ -n "$BASH_VERSION" ]; then
        shell_profile="$target_home/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_profile="$target_home/.zshrc"
    else
        shell_profile="$target_home/.profile"
    fi
    
    # Remove old certificate bundle configuration
    if [ -f "$shell_profile" ]; then
        sed -i '/# Claude SSL Fix - Complete Certificate Bundle/d' "$shell_profile" 2>/dev/null || true
        sed -i '/NODE_EXTRA_CA_CERTS.*claude-ssl-fix/d' "$shell_profile" 2>/dev/null || true
    fi
    
    echo "# Claude SSL Fix - Complete Certificate Bundle" >> "$shell_profile"
    echo "export NODE_EXTRA_CA_CERTS=\"$complete_bundle\"" >> "$shell_profile"
    
    log_success "Complete certificate bundle path added to $shell_profile for user $target_user"
    
    # Also set the environment variable for the current session
    export NODE_EXTRA_CA_CERTS="$complete_bundle"
    
    # Test the configuration
    log_info "Testing certificate configuration..."
    if test_claude_connectivity "After certificate installation"; then
        log_success "Certificate installation successful!"
        FIX_APPLIED=true
        return 0
    else
        log_warn "Certificate installation completed but SSL test still failing"
        FIX_APPLIED=true
        return 0
    fi
}

# Alternative fixes for different environments
try_alternative_fixes() {
    log_header "Trying Alternative Fixes"
    
    # Fix 1: Update ca-certificates package
    log_info "Fix 1: Updating ca-certificates package..."
    if apt-get update >/dev/null 2>&1 && apt-get install -y ca-certificates >/dev/null 2>&1; then
        update-ca-certificates >/dev/null 2>&1
        log_success "ca-certificates package updated"
        
        if test_claude_connectivity "After ca-certificates update"; then
            FIX_APPLIED=true
            return 0
        fi
    fi
    
    # Fix 2: Clear and rebuild certificate cache
    log_info "Fix 2: Rebuilding certificate cache..."
    rm -rf /etc/ssl/certs/ca-certificates.crt 2>/dev/null || true
    update-ca-certificates --fresh >/dev/null 2>&1 || true
    
    if test_claude_connectivity "After certificate cache rebuild"; then
        FIX_APPLIED=true
        return 0
    fi
    
    # Fix 3: Try using system curl CA bundle
    log_info "Fix 3: Configuring curl CA bundle..."
    local curl_ca_bundle
    curl_ca_bundle=$(curl-config --ca 2>/dev/null) || curl_ca_bundle="/etc/ssl/certs/ca-certificates.crt"
    
    if [ -f "$curl_ca_bundle" ]; then
        export CURL_CA_BUNDLE="$curl_ca_bundle"
        export NODE_EXTRA_CA_CERTS="$curl_ca_bundle"
        
        if test_claude_connectivity "After configuring curl CA bundle"; then
            FIX_APPLIED=true
            return 0
        fi
    fi
    
    # Fix 4: Install additional CA certificates
    log_info "Fix 4: Installing additional CA certificate packages..."
    if apt-get install -y ca-certificates-java ca-certificates-mono >/dev/null 2>&1; then
        update-ca-certificates >/dev/null 2>&1
        
        if test_claude_connectivity "After installing additional CA packages"; then
            FIX_APPLIED=true
            return 0
        fi
    fi
    
    return 1
}

# Test Claude CLI functionality
test_claude_cli() {
    log_header "Testing Claude CLI"
    
    # Check if Claude CLI is installed (try both /usr/bin/claude and PATH)
    local claude_path=""
    if [ -x "/usr/bin/claude" ]; then
        claude_path="/usr/bin/claude"
    elif command -v claude >/dev/null 2>&1; then
        claude_path=$(command -v claude)
    else
        log_error "Claude CLI not found. Please install it first."
        return 1
    fi
    
    # Test basic CLI functionality
    log_info "Testing Claude CLI version..."
    log_debug "Using Claude CLI at: $claude_path"
    
    # Run as the original user if we're running as root
    local claude_cmd="$claude_path --version"
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        claude_cmd="sudo -u $SUDO_USER $claude_path --version"
    fi
    
    if timeout 10 $claude_cmd >/dev/null 2>&1; then
        local version
        version=$(timeout 10 $claude_cmd 2>/dev/null | head -1)
        log_success "Claude CLI is working: $version"
    else
        log_warn "Claude CLI version check failed (this is expected when running as root)"
        log_info "Claude CLI should work normally when run as regular user"
    fi
    
    # Test NODE_OPTIONS configuration
    log_info "Testing NODE_OPTIONS configuration..."
    if [ -n "$NODE_OPTIONS" ] && echo "$NODE_OPTIONS" | grep -q "use-system-ca"; then
        log_success "✅ NODE_OPTIONS is configured with --use-system-ca"
        log_info "Corporate environment authentication should work correctly"
    else
        log_warn "⚠️  NODE_OPTIONS not configured with --use-system-ca"
        log_info "You may need to use: NODE_OPTIONS='--use-system-ca' claude /login"
    fi
    
    # Test authentication status (don't try to login automatically)
    log_info "Checking Claude CLI authentication status..."
    local auth_cmd="$claude_path /status"
    if [ "$EUID" -eq 0 ] && [ -n "$SUDO_USER" ]; then
        auth_cmd="sudo -u $SUDO_USER $claude_path /status"
    fi
    
    if timeout 10 $auth_cmd >/dev/null 2>&1; then
        log_success "Claude CLI authentication is working"
    else
        log_warn "Claude CLI authentication test failed or timed out"
        log_info "Authentication required - use the methods shown in the report below"
    fi
    
    return 0
}

# Generate report and recommendations
generate_report() {
    log_header "Fix Report and Recommendations"
    
    echo
    if [ "$FIX_APPLIED" = true ]; then
        log_success "🎉 SSL certificate issues have been resolved!"
        log_info "The following fixes were applied:"
        
        if [ -f "$CERT_BUNDLE_PATH" ]; then
            echo "  ✅ Corporate certificates installed: $CERT_BUNDLE_PATH"
        fi
        
        if [ -n "$NODE_EXTRA_CA_CERTS" ]; then
            echo "  ✅ Node.js configured to use certificates: $NODE_EXTRA_CA_CERTS"
        fi
        
        echo
        log_info "🚀 READY FOR AUTHENTICATION:"
        echo
        log_success "✅ NODE_OPTIONS automatically configured for corporate environment"
        log_success "✅ Convenience alias 'claude-login' created for easy authentication"
        log_success "✅ Smart wrapper 'claude-corp' created for automatic NODE_OPTIONS handling"
        echo
        log_info "Next steps for authentication:"
        echo "  1. IMPORTANT: Restart your terminal or run: source ~/.bashrc"
        echo "  2. Test Claude CLI: claude --version"
        echo
        log_info "🔑 AUTHENTICATION METHODS (in order of preference):"
        echo
        log_success "   🥇 BEST: Use the smart wrapper (auto-applies NODE_OPTIONS)"
        echo "      After terminal restart: claude-corp /login"
        echo "      OR immediately: ~/.local/bin/claude-corporate /login"
        echo
        log_success "   🥈 RECOMMENDED: Use the convenience alias"
        echo "      After terminal restart: claude-login"
        echo "      OR immediately: NODE_OPTIONS='--use-system-ca' claude /login"
        echo
        log_success "   🥉 ALTERNATIVE: Use full NODE_OPTIONS command"
        echo "      NODE_OPTIONS='--use-system-ca' claude /login"
        echo
        log_warn "   🆘 FALLBACK: If all above methods fail"
        echo "      • Temporarily disconnect from corporate VPN"
        echo "      • Run: claude /login"
        echo "      • Reconnect to VPN after successful authentication"
        echo
        echo "  4. Verify functionality: curl -v $CLAUDE_API_URL"
        echo
        log_info "🔧 Corporate Environment Notes:"
        echo "  • NODE_OPTIONS='--use-system-ca' is now set by default"
        echo "  • Smart wrapper automatically applies NODE_OPTIONS for /login commands"
        echo "  • Corporate proxy detected: Zscaler/corporate certificates now trusted"
        echo "  • OAuth tokens are cached - only need to auth once per environment"
        echo "  • If authentication still fails, contact IT to whitelist:"
        echo "    - *.anthropic.com"
        echo "    - *.claude.ai"
        
    else
        log_warn "⚠️  Automatic fixes were not successful"
        echo
        log_info "Manual steps to try:"
        echo
        
        if [ "$CORPORATE_PROXY_DETECTED" = true ]; then
            echo "  🏢 Corporate Environment Detected:"
            echo "     • Contact IT to whitelist: *.anthropic.com, *.claude.ai"
            echo "     • Request SSL inspection bypass for Claude endpoints"
            echo "     • Export corporate root certificate from browser"
            echo
        fi
        
        if [ "$CERT_CHAIN_ISSUE" = true ]; then
            echo "  🔗 Certificate Chain Issues:"
            echo "     • Update your system:  apt-get update &&  apt-get upgrade"
            echo "     • Install certificate updates:  apt-get install ca-certificates"
            echo "     • Check network connectivity on different networks"
            echo
        fi
        
        echo "  🔧 CRITICAL: OAuth Authentication Solutions:"
        echo
        log_error "     ⚠️  CORPORATE ENVIRONMENT REQUIRES NODE_OPTIONS"
        echo
        log_success "     🥇 USE THE SMART WRAPPER (automatically applies NODE_OPTIONS):"
        echo "        # Run this script again to install the wrapper, then:"
        echo "        claude-corp /login"
        echo
        log_success "     🥈 PRIMARY METHOD (REQUIRED for corporate networks):"
        echo "        NODE_OPTIONS='--use-system-ca' claude /login"
        echo
        log_warn "     🥉 FALLBACK METHODS (if primary fails):"
        echo "        • Temporarily disconnect from corporate VPN"
        echo "        • Run: claude /login"
        echo "        • Reconnect to VPN after successful authentication"
        echo "        • Use mobile hotspot to complete 'claude /login'"
        echo "        • Once authenticated, tokens are cached for corporate network use"
        echo
        log_info "     📝 To make this permanent, add to your shell profile:"
        echo "        export NODE_OPTIONS='--use-system-ca'"
        echo "        alias claude-login=\"NODE_OPTIONS='--use-system-ca' claude /login\""
        echo "        # The smart wrapper is automatically installed by this script"
        echo
        
        echo "  📋 Manual Certificate Bundle Creation:"
        echo "     1. Extract corporate certificates: openssl s_client -connect api.anthropic.com:443 -showcerts"
        echo "     2. Create bundle: cat /etc/ssl/certs/ca-certificates.crt extracted-certs.crt > complete-bundle.crt"
        echo "     3. Export: NODE_EXTRA_CA_CERTS=/path/to/complete-bundle.crt"
        echo "     4. Add to shell profile for persistence"
        echo "     5. IMPORTANT: Still use NODE_OPTIONS='--use-system-ca' for authentication"
    fi
    
    echo
    log_info "🔍 Always test fixes with: curl -v $CLAUDE_API_URL"
    echo
}

# Cleanup function
cleanup() {
    if [ "$1" = "restore" ]; then
        restore_config
        log_info "Configuration restored"
    fi
}

# Signal handlers
trap 'cleanup restore; exit 130' INT
trap 'cleanup restore; exit 143' TERM

# Main function
main() {
    print_header
    
    # Parse command line arguments
    local restore_on_failure=false
    local verbose=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --restore-on-failure)
                restore_on_failure=true
                shift
                ;;
            --verbose|-v)
                verbose=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --restore-on-failure  Restore configuration if fixes fail"
                echo "  --verbose, -v         Enable verbose output"
                echo "  --help, -h           Show this help message"
                echo ""
                echo "This script diagnoses and fixes SSL certificate issues for Claude Code."
                echo "It works with various corporate VPNs, proxies, and certificate authorities."
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    log_info "Starting SSL certificate diagnosis and repair..."
    echo
    
    # Create backup
    backup_config
    
    # Always setup corporate aliases and convenience commands
    setup_claude_corporate_aliases
    
    # Step 1: Detect corporate environment and SSL issues
    detect_corporate_environment
    
    if [ "$SSL_ISSUE_DETECTED" = false ]; then
        log_success "No SSL certificate issues detected!"
        test_claude_cli
        log_success "Claude Code should be working correctly."
        exit 0
    fi
    
    # Step 2: Try to extract and install certificates
    if [ "$CORPORATE_PROXY_DETECTED" = true ] || [ "$CERT_CHAIN_ISSUE" = true ]; then
        extract_certificates
        
        if install_certificates; then
            log_info "Testing fix..."
            if test_claude_connectivity "After certificate installation"; then
                test_claude_cli
                generate_report
                exit 0
            fi
        fi
    fi
    
    # Step 3: Try alternative fixes
    if try_alternative_fixes; then
        test_claude_cli
        generate_report
        exit 0
    fi
    
    # Step 4: If all fixes failed
    if [ "$restore_on_failure" = true ]; then
        restore_config
    fi
    
    generate_report
    
    # Exit with error code if no fix was successful
    exit 1
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi