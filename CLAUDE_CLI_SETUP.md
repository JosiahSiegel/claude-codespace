# Claude CLI Setup in DevContainer

## Installation Method

Claude CLI is installed via NPM package `@anthropic-ai/claude-code`, not from GitHub releases.

## DevContainer Configuration

The [`Dockerfile`](.devcontainer/Dockerfile) includes:

1. **Node.js Installation**: Uses NodeSource repository for latest LTS
2. **Claude CLI Installation**: `npm install -g @anthropic-ai/claude-code`
3. **Symlink Creation**: Ensures Claude is available at `/usr/bin/claude`

## Verification

After rebuilding the DevContainer, verify installation:

```bash
claude --version
```

## Troubleshooting

If Claude CLI is not found:
1. Rebuild the DevContainer: `Dev Containers: Rebuild Container`
2. Check if Node.js is installed: `node --version`
3. Check global NPM packages: `npm list -g --depth=0`

## Usage

The Claude CLI will be available at:
- `/usr/local/bin/claude` (primary NPM installation)
- `/usr/bin/claude` (symlink for compatibility)

Configure Roo Code extension to use the full path `/usr/bin/claude` for best compatibility.