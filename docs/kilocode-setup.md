# Kilo Code Setup Guide

This guide explains how to use the agents in this repository with the **Kilo Code** VS Code extension.

## What is Kilo Code?

[Kilo Code](https://kilo.ai) is an open-source AI coding assistant for VS Code that supports custom agent modes, multiple AI providers, and project-specific configuration. It is model-agnostic — you can use any provider and API key (OpenAI, Anthropic, Google Gemini, AWS Bedrock, and more).

Install it from the VS Code Marketplace:

```
Extension ID: kilocode.kilo-code
```

Or search **"Kilo Code"** in the VS Code Extensions panel (`Ctrl+Shift+X` / `Cmd+Shift+X`).

## Using This Repo with Kilo Code

### 1. Clone the repo and check out the `kilocode` branch

```bash
git clone https://github.com/byronbranfield/kilocode-agents.git
cd kilocode-agents
git checkout kilocode
```

### 2. Open the folder in VS Code

```bash
code .
```

Make sure the Kilo Code extension is installed before opening the folder.

### 3. Kilo Code auto-detects custom modes

Kilo Code automatically reads the `.kilocodemodes` file at the project root and loads all custom modes defined there. No additional configuration is required.

### 4. Switch modes in the Kilo Code panel

- Open the Kilo Code panel from the Activity Bar (look for the Kilo Code icon).
- Click the **mode selector** (shown at the top of the chat panel) to see all available modes.
- Select a mode such as **Python Pro**, **FastAPI Pro**, or **Django Pro** to activate that agent.

The selected mode's `roleDefinition` is injected as the system prompt, giving the AI deep, specialised knowledge for that domain.

## Model Compatibility

Kilo Code is **model-agnostic**. You can use any supported provider and API key:

- Anthropic (Claude 3.5 Sonnet, Claude Opus, etc.)
- OpenAI (GPT-4o, o1, etc.)
- Google Gemini
- AWS Bedrock
- Local models via Ollama or LM Studio
- Any OpenAI-compatible endpoint

Configure your provider and API key in the Kilo Code settings (`Ctrl+,` → search "Kilo Code").

> **Note:** The agent `.md` files in `plugins/` include a `model` field (e.g. `opus`) that reflects the recommended model for Claude Code. Kilo Code ignores this field and uses whichever model you have configured.

## What's Included in This PoC

The `kilocode` branch ships with three agents from the **`python-development`** plugin:

| Slug | Name | Description |
|------|------|-------------|
| `python-pro` | Python Pro | Master Python 3.12+ with modern features, async programming, and production-ready practices |
| `fastapi-pro` | FastAPI Pro | Build high-performance async APIs with FastAPI, SQLAlchemy 2.0, and Pydantic V2 |
| `django-pro` | Django Pro | Master Django 5.x with async views, DRF, Celery, and Django Channels |

These are defined in `.kilocodemodes` at the repo root.

## What's Coming Next

This is a proof of concept. The plan is to port all **65 plugins** (91 agents) from this repository into `.kilocodemodes`, covering:

- JavaScript/TypeScript, Rust, Go, Java, and more
- Kubernetes, cloud infrastructure, CI/CD
- Security scanning, code review, observability
- Full-stack orchestration, AI/ML, data engineering
- And much more — see the full [Plugin Reference](plugins.md)

Contributions and feedback welcome!
