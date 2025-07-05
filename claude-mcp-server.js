#!/usr/bin/env node

// Example MCP server wrapper for Claude Code
const { spawn } = require('child_process');
const http = require('http');

const PORT = process.env.PORT || 8947;

// Start Claude Code MCP server
const claudeServer = spawn('claude', ['mcp', 'serve'], {
  stdio: ['inherit', 'inherit', 'inherit']
});

// Simple HTTP wrapper to expose Claude Code via HTTP
const server = http.createServer((req, res) => {
  res.writeHead(200, { 
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  });
  
  if (req.method === 'OPTIONS') {
    res.end();
    return;
  }
  
  res.end(JSON.stringify({
    status: 'Claude Code MCP Server is running',
    port: PORT,
    endpoint: `http://localhost:${PORT}`
  }));
});

server.listen(PORT, () => {
  console.log(`Claude Code MCP Server HTTP wrapper running on port ${PORT}`);
});

process.on('SIGTERM', () => {
  claudeServer.kill();
  server.close();
});