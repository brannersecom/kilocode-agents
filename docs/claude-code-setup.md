# Claude Code Setup Guide

This guide explains how to use this repository with **Claude Code** plugin marketplace support.

## 1) Clone and Checkout the Claude-Compatible Branch

```bash
git clone https://github.com/byronbranfield/kilocode-agents.git
cd kilocode-agents
git checkout main
```

`main` is the canonical source branch for plugin definitions.

## 2) Add the Marketplace in Claude Code

```bash
/plugin marketplace add byronbranfield/kilocode-agents
```

If you are using your own fork, replace with your repo path.

## 3) Browse and Install Plugins

```bash
/plugin
/plugin install python-development
/plugin install backend-development
```

The marketplace is defined in `.claude-plugin/marketplace.json`.

## 4) Keep Plugin Catalog Updated

When you add agents, commands, or skills under `plugins/`, update `.claude-plugin/marketplace.json` accordingly so Claude Code can discover them.
