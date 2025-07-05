# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This repository provides Claude Code CLI access within a DevContainer for use with Roo Code extension running inside the same DevContainer.

## Claude CLI Path

The Claude CLI is available at `/usr/bin/claude` inside the DevContainer.

## Setup for Roo Code Extension in DevContainer

**Roo Code Configuration**: Configure Roo Code extension to use:
```
/usr/bin/claude
```

**Installation**: Make sure Roo Code extension is installed in the DevContainer VS Code instance.

## Common Commands

### Test Claude CLI
```bash
claude --version
```

### Run Claude interactively
```bash
claude
```