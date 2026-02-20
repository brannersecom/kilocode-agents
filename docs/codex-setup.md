# Codex Setup Guide

This guide explains how to use this repository with Codex-compatible adapter assets.

For shared, cross-project installation under your user profile, see [docs/centralized-setup.md](centralized-setup.md).

## 1) Clone and Checkout the Codex Branch

```bash
git clone https://github.com/byronbranfield/kilocode-agents.git
cd kilocode-agents
git checkout codex
```

If your fork uses a different branch name, switch to that branch instead.

## 2) Generate Codex Assets

Run from repository root:

```bash
python scripts/generate_codex_assets.py
```

Generated files:

- `AGENTS.md`
- `.codex/registry.json`
- `.codex/skills-index.md`
- `.codex/agents-index.md`

## 3) Keep Codex Assets in Sync

When plugin content changes, regenerate Codex assets:

```bash
python scripts/generate_codex_assets.py
```

The generator reads `.claude-plugin/marketplace.json` as the source of truth.

CI also validates generated adapter files on pull requests via `.github/workflows/validate-generated-adapters.yml`.

## 4) Tool Adapter Generation Model

This repository uses a single source with per-tool generated adapters:

- Claude Code adapter: `.claude-plugin/marketplace.json`
- Kilo Code adapter: `.kilocodemodes`
- Codex adapter: `AGENTS.md` + `.codex/*`

Recommended update flow:

1. Update plugin assets under `plugins/*`.
2. Regenerate Kilo and Codex adapters:
   - `python scripts/generate_kilocodemodes.py`
   - `python scripts/generate_codex_assets.py`
3. Commit source and generated adapter outputs together.
