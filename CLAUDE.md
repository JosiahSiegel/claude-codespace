# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository hosts Claude Code within a DevContainer, making it available to Roo Code on the Windows host via port forwarding.

## Architecture

Claude Code runs as an MCP server inside the DevContainer and is exposed to the Windows host:

```
Windows Host (Roo Code) → Port 8947 → DevContainer → Claude Code MCP Server
```

## Common Commands

### Test Connection
```bash
curl http://localhost:8947
```

### Manual Start (if needed)
```bash
node claude-mcp-server.js
```

## Configuration

- Claude Code MCP server starts automatically when DevContainer starts
- Port 8947 is forwarded to Windows host
- Roo Code connects to `http://localhost:8947`
- Server logs are written to `/tmp/claude-mcp-server.log`