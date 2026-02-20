# Centralized Setup (Agent Orchestration)

This setup keeps one shared base under your user profile, then binds each project to it.

## Why This Model

- One central base to maintain and update
- Fast project onboarding
- Optional link mode (lightweight) or copy mode (portable)

Recommended central location:

```text
%USERPROFILE%\.agent-orchestration
```

## 1) Install/Update the Central Base

From this repository:

```powershell
pwsh -File scripts/install-agent-orchestration-central.ps1 -CentralPath "$HOME\.agent-orchestration"
```

From a zip bundle:

```powershell
pwsh -File scripts/install-agent-orchestration-central.ps1 `
  -SourceZip "C:\path\to\multi-agent-codex-bundle.zip" `
  -CentralPath "$HOME\.agent-orchestration"
```

Use `-Force` to replace an existing central install.

## 2) Bind a Project to the Central Base

Run inside the target project (or pass `-ProjectPath`):

```powershell
pwsh -File scripts/bind-agent-orchestration-project.ps1 `
  -ProjectPath "E:\MyProjects\project-a" `
  -CentralPath "$HOME\.agent-orchestration" `
  -Mode Link `
  -Force
```

This creates/updates:

- `.agent-orchestration` (link/copy of central base)
- `.codex` (link/copy of central `.codex`)
- `.kilocodemodes` (link/copy)
- `AGENTS.md` (generated for this project, pointing to `.agent-orchestration/plugins/...`)

If you want local Claude plugin files as well:

```powershell
pwsh -File scripts/bind-agent-orchestration-project.ps1 `
  -ProjectPath "E:\MyProjects\project-a" `
  -CentralPath "$HOME\.agent-orchestration" `
  -Mode Link `
  -EnableClaudeLocal `
  -Force
```

## Syncing Core Updates

After central base changes:

1. Re-run central install script.
2. Re-run bind script in each project with `-Force`, or use the sync wrapper script:

```powershell
pwsh -File scripts/sync-agent-orchestration-project.ps1 `
  -ProjectPath "E:\MyProjects\project-a" `
  -CentralPath "$HOME\.agent-orchestration" `
  -Mode Link
```

If a project is in `Link` mode, most updates flow automatically; rerunning bind ensures `AGENTS.md` refreshes from the latest registry.

## Notes and Tradeoffs

- `Link` mode is lightweight and recommended for single-machine setups.
- `Copy` mode is more portable but duplicates files per project.
- Keeping core outside the project is fine for Codex/Kilo as long as project root has expected adapter files (`AGENTS.md`, `.codex`, `.kilocodemodes`), which the bind script ensures.
