# Kilo Code Setup Guide

This guide explains how to use this repository with the **Kilo Code** VS Code extension.

For shared, cross-project installation under your user profile, see [docs/centralized-setup.md](centralized-setup.md).

## Install Kilo Code

Install from VS Code Marketplace:

```text
Extension ID: kilocode.kilo-code
```

Or search for **Kilo Code** in Extensions (`Ctrl+Shift+X` / `Cmd+Shift+X`).

## 1) Clone and Checkout the Kilo-Compatible Branch

```bash
git clone https://github.com/byronbranfield/kilocode-agents.git
cd kilocode-agents
git checkout copilot/add-kilo-code-compatibility
```

Note: If your fork uses a different branch name for Kilo compatibility, checkout that branch instead.

## 2) Open in VS Code

```bash
code .
```

## 3) Kilo Code Loads Modes from `.kilocodemodes`

Kilo Code automatically loads custom modes from `.kilocodemodes` at repo root.

This branch contains a full conversion of marketplace agents into Kilo modes:

- Source of truth: `.claude-plugin/marketplace.json`
- Generated output: `.kilocodemodes`
- Current generated mode count: `152`

## 4) Select and Use Modes

- Open Kilo Code from the activity bar.
- Open the mode selector in the chat panel.
- Choose a mode (for example `python-pro`, `backend-architect`, `kubernetes-architect`).

Kilo injects the selected mode's `roleDefinition` as the active system prompt.

## Regenerating Kilo Modes After Catalog Changes

When plugins/agents are added or updated, regenerate modes:

```bash
python scripts/generate_kilocodemodes.py
```

The generator converts all agent definitions from the marketplace catalog into `.kilocodemodes`.

CI also validates generated adapter files on pull requests via `.github/workflows/validate-generated-adapters.yml`.

## Model Notes

Kilo Code is model-agnostic. Configure your provider/model in Kilo settings.

Agent files in `plugins/*/agents/*.md` can include a `model` frontmatter value for Claude Code guidance. Kilo ignores that field and uses your configured provider/model.
