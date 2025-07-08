# Port Forwarding Troubleshooting Guide

## Problem Description

The error `Port forwarding 51139 > 42553 > 42553 stderr: Remote close` indicates VSCode's DevContainer port forwarding mechanism is encountering conflicts during container startup. This typically happens when:

1. **Port Conflicts**: Services are already running on the ports VSCode is trying to forward
2. **Network Namespace Issues**: Container networking is not properly initialized
3. **VSCode Extension Conflicts**: Multiple extensions trying to manage the same ports
4. **Docker Network Problems**: Docker's internal networking is conflicting with VSCode's port forwarding

## Root Causes

### 1. Automatic Port Forwarding Conflicts
- VSCode automatically detects and forwards ports that applications bind to
- This can conflict with explicitly configured port forwarding in `devcontainer.json`
- Multiple port forwarding attempts create race conditions

### 2. Container Initialization Timing
- Services start before VSCode's port forwarding is fully established
- Network configuration changes during container startup
- DevContainer features interfere with port forwarding setup

### 3. Host System Port Conflicts
- Host machine already has services running on the target ports
- Multiple containers trying to use the same host ports
- Corporate network policies blocking port forwarding

## Applied Solutions

### 1. DevContainer Configuration Updates

**File: `.devcontainer/devcontainer.json`**
```json
{
  "otherPortsAttributes": {
    "onAutoForward": "ignore"
  },
  "runArgs": [
    "--network=host"
  ]
}
```

**Benefits:**
- Prevents automatic port forwarding conflicts
- Uses host networking for more reliable port access
- Reduces container network complexity

### 2. Port Forwarding Fix Script

**File: `.devcontainer/scripts/fix-port-forwarding.sh`**

**Features:**
- Diagnoses port conflicts automatically
- Kills conflicting processes safely
- Cleans up network namespaces
- Provides comprehensive troubleshooting guidance
- Can be run manually or automatically

**Usage:**
```bash
# Run diagnostics and fixes
./.devcontainer/scripts/fix-port-forwarding.sh

# Make executable if needed
chmod +x .devcontainer/scripts/fix-port-forwarding.sh
```

### 3. Automatic Port Checking

**File: `.devcontainer/scripts/post-start.sh`**

**Integration:**
- Automatically checks for port conflicts during container startup
- Runs port forwarding fixes when conflicts are detected
- Provides status information in the startup summary

## Manual Troubleshooting Steps

### Step 1: Check Port Status
```bash
# Check if ports are in use
netstat -tuln | grep ":8080\|:10000\|:10001\|:10002"

# Check specific port
lsof -i :8080
```

### Step 2: Kill Conflicting Processes
```bash
# Kill processes using specific port
sudo lsof -ti:8080 | xargs -r kill -9

# Or use the automated script
./.devcontainer/scripts/fix-port-forwarding.sh
```

### Step 3: Restart VSCode Port Forwarding
```bash
# Clear VSCode port forwarding cache
pkill -f "ssh.*port-forward" 2>/dev/null || true

# Restart VSCode or rebuild container
# Command Palette: "Dev Containers: Rebuild Container"
```

### Step 4: Check Docker Networking
```bash
# Reset Docker networking
docker network prune -f

# Check Docker containers
docker ps

# Check container logs
docker logs <container-id>
```

## Prevention Strategies

### 1. Use Alternative Ports
If conflicts persist, modify the ports in `devcontainer.json`:
```json
{
  "forwardPorts": [8081, 10003, 10004, 10005],
  "portsAttributes": {
    "8081": { "label": "Web App" },
    "10003": { "label": "Azurite Blob" }
  }
}
```

### 2. Disable Automatic Port Forwarding
```json
{
  "otherPortsAttributes": {
    "onAutoForward": "ignore"
  }
}
```

### 3. Use Host Networking
```json
{
  "runArgs": ["--network=host"]
}
```

### 4. Implement Port Management Service
The fix script can create a systemd service to automatically manage port conflicts:
```bash
# Run with service creation
sudo ./.devcontainer/scripts/fix-port-forwarding.sh
```

## VSCode Port Management

### Ports Tab
- Access via Terminal panel → Ports tab
- Right-click ports to stop/start forwarding
- Check "Auto Forward" status

### Common Port Forwarding Issues
1. **"Port already in use"** - Run the fix script
2. **"Connection refused"** - Check if service is running in container
3. **"Remote close"** - Network configuration issue, rebuild container

## Corporate Network Considerations

### SSL/Proxy Issues
- Some corporate networks block port forwarding
- Use the SSL fix script in conjunction with port forwarding fixes
- Consider VPN disconnection during troubleshooting

### Firewall Rules
- Ensure ports 8080, 10000-10002 are allowed through corporate firewall
- Request IT support for persistent port forwarding issues

## Emergency Fixes

### Quick Reset
```bash
# Kill all port conflicts and restart
sudo pkill -f "ssh.*port-forward"
sudo lsof -ti:8080,10000,10001,10002 | xargs -r kill -9
```

### Container Rebuild
```bash
# Force rebuild container
# Command Palette: "Dev Containers: Rebuild Container"
```

### Docker Reset
```bash
# Reset Docker (use with caution)
sudo systemctl restart docker
```

## Verification

After applying fixes, verify the solution:

```bash
# Check port status
netstat -tuln | grep ":8080\|:10000\|:10001\|:10002"

# Check VSCode port forwarding
# Look at Ports tab in VSCode terminal panel

# Test connectivity
curl -v http://localhost:8080
```

## Getting Help

1. **Run diagnostics**: `.devcontainer/scripts/fix-port-forwarding.sh`
2. **Check logs**: Docker container logs and VSCode output
3. **Rebuild container**: If issues persist
4. **Contact IT**: For persistent corporate network issues

## Success Indicators

- Container starts without port forwarding errors
- Ports tab shows forwarded ports as "Available"
- No "Remote close" errors in output
- Applications accessible via forwarded ports