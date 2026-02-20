[CmdletBinding()]
param(
    [string]$ProjectPath = ".",
    [string]$CentralPath = "$HOME\.agent-orchestration",
    [ValidateSet("Link", "Copy")]
    [string]$Mode = "Link",
    [switch]$Force,
    [switch]$EnableClaudeLocal
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Ensure-Removed {
    param([string]$Path)
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

function New-LinkOrCopyDirectory {
    param(
        [string]$Source,
        [string]$Target,
        [string]$ModeValue,
        [switch]$ForceValue
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Source directory missing: $Source"
    }

    if (Test-Path -LiteralPath $Target) {
        if (-not $ForceValue) {
            throw "Target already exists: $Target (use -Force to replace)"
        }
        Ensure-Removed -Path $Target
    }

    if ($ModeValue -eq "Link") {
        try {
            New-Item -ItemType Junction -Path $Target -Target $Source -Force | Out-Null
            return "link"
        }
        catch {
            Write-Warning "Could not create junction for $Target. Falling back to copy."
        }
    }

    Copy-Item -LiteralPath $Source -Destination $Target -Recurse -Force
    return "copy"
}

function New-LinkOrCopyFile {
    param(
        [string]$Source,
        [string]$Target,
        [string]$ModeValue,
        [switch]$ForceValue
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Source file missing: $Source"
    }

    if (Test-Path -LiteralPath $Target) {
        if (-not $ForceValue) {
            throw "Target already exists: $Target (use -Force to replace)"
        }
        Ensure-Removed -Path $Target
    }

    if ($ModeValue -eq "Link") {
        try {
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
            return "link"
        }
        catch {
            Write-Warning "Could not create file symlink for $Target. Falling back to copy."
        }
    }

    Copy-Item -LiteralPath $Source -Destination $Target -Force
    return "copy"
}

function Build-ProjectAgentsMarkdown {
    param([hashtable]$Registry)

    $lines = @()
    $lines += "# AGENTS.md instructions for $($Registry.projectName)"
    $lines += ""
    $lines += "<INSTRUCTIONS>"
    $lines += "Central Agent Orchestration Inheritance"
    $lines += ""
    $lines += "Scope: This project and all subfolders."
    $lines += ""
    $lines += "Base location"
    $lines += "- Linked/cached core at `.agent-orchestration`."
    $lines += "- Codex registry at `.codex/registry.json`."
    $lines += "- Kilo modes at `.kilocodemodes`."
    $lines += ""
    $lines += "Usage"
    $lines += "- Use the shared base as default behavior."
    $lines += "- Prefer skill files under `.agent-orchestration/plugins/...`."
    $lines += "- Project-specific rules can be added in `AGENTS.project.md`."
    $lines += ""
    $lines += "## Skills"
    $lines += "A skill is a set of local instructions stored in a `SKILL.md` file."
    $lines += "### Available skills"

    foreach ($plugin in $Registry.plugins) {
        foreach ($skill in $plugin.skills) {
            $path = ".agent-orchestration/" + $skill.path
            $desc = [string]$skill.description
            $desc = ($desc -replace "\s+", " ").Trim()
            $lines += "- $($skill.slug): $desc (plugin: ``$($plugin.name)``; file: ``$path``)"
        }
    }

    $lines += "### How to use skills"
    $lines += "- Trigger when the user names a skill or the task clearly matches a listed skill."
    $lines += "- Open only the skill files needed for the current task."
    $lines += "- Resolve relative references from each skill's folder."
    $lines += "- Prefer shared scripts/assets under `.agent-orchestration/plugins/*`."
    $lines += "</INSTRUCTIONS>"
    $lines += ""
    return ($lines -join "`n")
}

$resolvedProject = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $ProjectPath).Path)
$resolvedCentral = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $CentralPath).Path)

$centralRegistryPath = Join-Path $resolvedCentral ".codex\registry.json"
$centralModesPath = Join-Path $resolvedCentral ".kilocodemodes"
$centralCodexPath = Join-Path $resolvedCentral ".codex"
$centralClaudePath = Join-Path $resolvedCentral ".claude-plugin"
$centralPluginsPath = Join-Path $resolvedCentral "plugins"

if (-not (Test-Path -LiteralPath $centralRegistryPath)) {
    throw "Central registry not found: $centralRegistryPath"
}

Write-Host "Binding project to central Agent Orchestration base..."
Write-Host "  Project: $resolvedProject"
Write-Host "  Central: $resolvedCentral"
Write-Host "  Mode:    $Mode"

$projectCoreLink = Join-Path $resolvedProject ".agent-orchestration"
$projectCodex = Join-Path $resolvedProject ".codex"
$projectModes = Join-Path $resolvedProject ".kilocodemodes"
$projectAgents = Join-Path $resolvedProject "AGENTS.md"
$projectClaude = Join-Path $resolvedProject ".claude-plugin"
$projectPlugins = Join-Path $resolvedProject "plugins"

$coreStatus = New-LinkOrCopyDirectory -Source $resolvedCentral -Target $projectCoreLink -ModeValue $Mode -ForceValue:$Force
$codexStatus = New-LinkOrCopyDirectory -Source $centralCodexPath -Target $projectCodex -ModeValue $Mode -ForceValue:$Force
$modesStatus = New-LinkOrCopyFile -Source $centralModesPath -Target $projectModes -ModeValue $Mode -ForceValue:$Force

$registryRaw = Get-Content -LiteralPath $centralRegistryPath -Raw -Encoding UTF8
$registry = $registryRaw | ConvertFrom-Json -AsHashtable
$registry.projectName = Split-Path -Leaf $resolvedProject
$agentsContent = Build-ProjectAgentsMarkdown -Registry $registry

if ((Test-Path -LiteralPath $projectAgents) -and (-not $Force)) {
    throw "Target already exists: $projectAgents (use -Force to replace)"
}

Set-Content -LiteralPath $projectAgents -Value $agentsContent -Encoding UTF8

if ($EnableClaudeLocal) {
    $claudeStatus = New-LinkOrCopyDirectory -Source $centralClaudePath -Target $projectClaude -ModeValue $Mode -ForceValue:$Force
    if (Test-Path -LiteralPath $projectPlugins) {
        Write-Warning "Skipped linking `plugins` because it already exists in project."
        $pluginsStatus = "skipped"
    }
    else {
        $pluginsStatus = New-LinkOrCopyDirectory -Source $centralPluginsPath -Target $projectPlugins -ModeValue $Mode -ForceValue:$Force
    }
}
else {
    $claudeStatus = "disabled"
    $pluginsStatus = "disabled"
}

Write-Host ""
Write-Host "Bind complete."
Write-Host "  .agent-orchestration : $coreStatus"
Write-Host "  .codex               : $codexStatus"
Write-Host "  .kilocodemodes       : $modesStatus"
Write-Host "  AGENTS.md            : generated"
Write-Host "  .claude-plugin       : $claudeStatus"
Write-Host "  plugins              : $pluginsStatus"
Write-Host ""
Write-Host "To sync core updates later, rerun this command with -Force."
