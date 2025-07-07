#!/bin/bash

# Claude Code SSL Certificate Fix Script
# Comprehensive script to diagnose and fix SSL certificate issues for Claude Code
# Works with various corporate VPNs, proxies, and certificate authorities

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
    if echo | openssl s_client -connect api.anthropic.com:443 -servername api.anthropic.com -showcerts 2>/dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' |  tee "$cert_file" >/dev/null; then
        if [ -s "$cert_file" ]; then
            log_success "Certificate chain extracted to $cert_file"
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
                log_info "Found corporate certificate: $cert_path"
                 cp "$cert_path" "$CUSTOM_CERT_DIR/"
                found_corporate_certs=true
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

# Install and configure certificates
install_certificates() {
    log_header "Installing Corporate Certificates"
    
    if [ ! -d "$CUSTOM_CERT_DIR" ] || [ -z "$(ls -A "$CUSTOM_CERT_DIR" 2>/dev/null)" ]; then
        log_warn "No certificates found to install"
        return 1
    fi
    
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
    
    # Update system certificate store
    log_info "Updating system certificate store..."
    update-ca-certificates >/dev/null 2>&1 || true
    
    # Configure Node.js/Claude CLI to use complete certificate bundle
    log_info "Configuring Node.js certificate path..."
    export NODE_EXTRA_CA_CERTS="$complete_bundle"
    
    # Add to shell profile for persistence
    local shell_profile
    if [ -n "$BASH_VERSION" ]; then
        shell_profile="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_profile="$HOME/.zshrc"
    else
        shell_profile="$HOME/.profile"
    fi
    
    # Remove old configuration and add new complete bundle configuration
    if [ -f "$shell_profile" ]; then
        sed -i '/# Claude SSL Fix/d' "$shell_profile" 2>/dev/null || true
        sed -i '/NODE_EXTRA_CA_CERTS.*claude-ssl-fix/d' "$shell_profile" 2>/dev/null || true
    fi
    
    echo "# Claude SSL Fix - Complete Certificate Bundle" >> "$shell_profile"
    echo "export NODE_EXTRA_CA_CERTS=\"$complete_bundle\"" >> "$shell_profile"
    log_success "Complete certificate bundle path added to $shell_profile"
    
    FIX_APPLIED=true
    return 0
}

# Alternative fixes for different environments
try_alternative_fixes() {
    log_header "Trying Alternative Fixes"
    
    # Fix 1: Update ca-certificates package
    log_info "Fix 1: Updating ca-certificates package..."
    if  apt-get update >/dev/null 2>&1 &&  apt-get install -y ca-certificates >/dev/null 2>&1; then
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
    if  apt-get install -y ca-certificates-java ca-certificates-mono >/dev/null 2>&1; then
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
    
    # Check if Claude CLI is installed
    if ! command -v claude >/dev/null 2>&1; then
        log_error "Claude CLI not found. Please install it first."
        return 1
    fi
    
    # Test basic CLI functionality
    log_info "Testing Claude CLI version..."
    if claude --version >/dev/null 2>&1; then
        local version
        version=$(claude --version 2>/dev/null | head -1)
        log_success "Claude CLI is working: $version"
    else
        log_error "Claude CLI version check failed"
        return 1
    fi
    
    # Test authentication status (don't try to login automatically)
    log_info "Checking Claude CLI authentication status..."
    if timeout 10 claude /status >/dev/null 2>&1; then
        log_success "Claude CLI authentication is working"
    else
        log_warn "Claude CLI authentication test failed or timed out"
        log_info "You may need to run 'claude /login' after fixing SSL issues"
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
        log_info "Next steps for authentication:"
        echo "  1. Restart your terminal or run: source ~/.bashrc"
        echo "  2. Test Claude CLI: claude --version"
        echo "  3. Try authentication with one of these methods:"
        echo "     a) NODE_OPTIONS='--use-system-ca' claude /login"
        echo "     b) claude /login (if method a doesn't work)"
        echo "     c) Temporarily disconnect VPN and try claude /login"
        echo "  4. Verify functionality: curl -v $CLAUDE_API_URL"
        echo
        log_info "🔧 OAuth Authentication Solutions:"
        echo "  • Use Node.js system CA: NODE_OPTIONS='--use-system-ca' claude /login"
        echo "  • Corporate proxy detected: Zscaler/corporate certificates now trusted"
        echo "  • If still failing, temporarily disconnect VPN for initial auth"
        echo "  • Contact IT to whitelist OAuth endpoints: *.anthropic.com, *.claude.ai"
        
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
        
        echo "  🔧 OAuth Authentication Solutions:"
        echo "     • Try: NODE_OPTIONS='--use-system-ca' claude /login"
        echo "     • Switch to personal network temporarily for initial auth"
        echo "     • Use mobile hotspot to complete 'claude /login'"
        echo "     • Once authenticated, tokens are cached for corporate network use"
        echo "     • Temporarily disconnect VPN for initial authentication"
        echo
        
        echo "  📋 Manual Certificate Bundle Creation:"
        echo "     1. Extract corporate certificates: openssl s_client -connect api.anthropic.com:443 -showcerts"
        echo "     2. Create bundle: cat /etc/ssl/certs/ca-certificates.crt extracted-certs.crt > complete-bundle.crt"
        echo "     3. Export: NODE_EXTRA_CA_CERTS=/path/to/complete-bundle.crt"
        echo "     4. Add to shell profile for persistence"
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