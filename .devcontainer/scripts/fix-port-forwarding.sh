#!/bin/bash

# Port forwarding diagnostics and fix script for DevContainer
# Addresses common port forwarding issues that cause container startup problems

set -e

echo "🔍 Diagnosing DevContainer port forwarding issues..."

# Function to check if port is in use
check_port() {
    local port=$1
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "⚠️  Port $port is in use"
        return 0
    else
        echo "✅ Port $port is available"
        return 1
    fi
}

# Function to kill processes using specific ports
kill_port_processes() {
    local port=$1
    echo "🔪 Killing processes using port $port..."
    
    # Find and kill processes using the port
    local pids=$(lsof -ti:$port 2>/dev/null || true)
    if [ -n "$pids" ]; then
        echo "   Found processes: $pids"
        for pid in $pids; do
            echo "   Killing process $pid..."
            kill -9 $pid 2>/dev/null || true
        done
        sleep 1
    else
        echo "   No processes found using port $port"
    fi
}

# Function to check VSCode port forwarding status
check_vscode_ports() {
    echo "📋 Checking VSCode port forwarding status..."
    
    # Check if we're in a DevContainer
    if [ -n "$REMOTE_CONTAINERS" ] || [ -n "$CODESPACES" ]; then
        echo "✅ Running in DevContainer/Codespaces environment"
        
        # Check for port forwarding conflicts
        if pgrep -f "vscode-server" > /dev/null; then
            echo "✅ VSCode server is running"
        else
            echo "⚠️  VSCode server not detected"
        fi
        
    else
        echo "⚠️  Not running in DevContainer environment"
    fi
}

# Function to restart VSCode port forwarding
restart_vscode_forwarding() {
    echo "🔄 Attempting to restart VSCode port forwarding..."
    
    # This is a graceful approach - we can't directly restart VSCode from inside
    # But we can clear any conflicting processes and prepare the environment
    
    # Clear any stale port forwarding processes
    pkill -f "ssh.*port-forward" 2>/dev/null || true
    pkill -f "code-server.*port" 2>/dev/null || true
    
    echo "✅ Cleared potential port forwarding conflicts"
    echo "💡 You may need to restart VSCode or rebuild the container for full effect"
}

# Function to check common problematic ports
check_common_ports() {
    echo "🔍 Checking common problematic ports..."
    
    local ports=(8080 10000 10001 10002 3000 3001 4000 5000 8000 8001 9000)
    local conflicts=0
    
    for port in "${ports[@]}"; do
        if check_port $port; then
            conflicts=$((conflicts + 1))
        fi
    done
    
    if [ $conflicts -gt 0 ]; then
        echo "⚠️  Found $conflicts port conflicts"
        return 1
    else
        echo "✅ No port conflicts detected"
        return 0
    fi
}

# Function to apply port forwarding fixes
apply_port_fixes() {
    echo "🔧 Applying port forwarding fixes..."
    
    # Kill processes on configured forwarded ports
    local configured_ports=(8080 10000 10001 10002)
    
    for port in "${configured_ports[@]}"; do
        if check_port $port; then
            kill_port_processes $port
        fi
    done
    
    # Clear any orphaned network namespaces
    echo "🧹 Cleaning up network namespaces..."
    sudo ip netns list 2>/dev/null | grep -v "^$" | while read ns; do
        sudo ip netns delete "$ns" 2>/dev/null || true
    done
    
    # Reset iptables if needed (be careful with this)
    if command -v iptables &> /dev/null; then
        echo "🔥 Flushing iptables rules..."
        sudo iptables -F 2>/dev/null || true
        sudo iptables -X 2>/dev/null || true
        sudo iptables -t nat -F 2>/dev/null || true
        sudo iptables -t nat -X 2>/dev/null || true
    fi
    
    echo "✅ Port forwarding fixes applied"
}

# Function to create systemd service to prevent port conflicts
create_port_manager_service() {
    echo "🛠️  Creating port manager service..."
    
    cat > /tmp/port-manager.service << 'EOF'
[Unit]
Description=DevContainer Port Manager
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for port in 8080 10000 10001 10002; do lsof -ti:$port | xargs -r kill -9; done'
RemainAfterExit=yes
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Install the service if systemd is available
    if command -v systemctl &> /dev/null; then
        sudo mv /tmp/port-manager.service /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable port-manager.service
        echo "✅ Port manager service installed"
    else
        echo "⚠️  Systemd not available, skipping service installation"
        rm -f /tmp/port-manager.service
    fi
}

# Function to show troubleshooting tips
show_troubleshooting_tips() {
    echo ""
    echo "🔧 Troubleshooting Tips:"
    echo "========================"
    echo ""
    echo "1. **Container Rebuild**: If issues persist, rebuild the container:"
    echo "   - Command Palette: 'Dev Containers: Rebuild Container'"
    echo ""
    echo "2. **Manual Port Check**: Check specific ports manually:"
    echo "   - Run: lsof -i :PORT_NUMBER"
    echo "   - Kill: sudo kill -9 PID"
    echo ""
    echo "3. **VSCode Port Forwarding**: Manage ports in VSCode:"
    echo "   - Go to Ports tab in terminal panel"
    echo "   - Right-click problematic ports and select 'Stop Forwarding'"
    echo ""
    echo "4. **Docker Network Reset**: Reset Docker networking:"
    echo "   - Run: docker network prune -f"
    echo "   - Restart Docker daemon if needed"
    echo ""
    echo "5. **Host Port Conflicts**: Check host machine ports:"
    echo "   - Ensure ports 8080, 10000-10002 are available on host"
    echo "   - Stop conflicting services on host machine"
    echo ""
    echo "6. **Alternative Configuration**: Use different ports:"
    echo "   - Modify forwardPorts in devcontainer.json"
    echo "   - Use ports above 10000 to avoid common conflicts"
    echo ""
}

# Main execution
main() {
    echo "🚀 DevContainer Port Forwarding Diagnostics"
    echo "==========================================="
    echo ""
    
    # Check VSCode environment
    check_vscode_ports
    echo ""
    
    # Check for port conflicts
    if ! check_common_ports; then
        echo ""
        echo "🔧 Port conflicts detected. Applying fixes..."
        apply_port_fixes
        echo ""
        
        # Restart port forwarding
        restart_vscode_forwarding
        echo ""
        
        # Create service to prevent future conflicts
        create_port_manager_service
        echo ""
    fi
    
    # Show troubleshooting tips
    show_troubleshooting_tips
    
    echo "✅ Port forwarding diagnostics completed!"
    echo ""
    echo "💡 If issues persist, try rebuilding the container or restarting VSCode"
}

# Run main function
main "$@"