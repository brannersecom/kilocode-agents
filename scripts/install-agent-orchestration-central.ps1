[CmdletBinding()]
param(
    [string]$CentralPath = "$HOME\.agent-orchestration",
    [string]$SourcePath = "",
    [string]$SourceZip = "",
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRoot {
    param(
        [string]$CandidatePath,
        [string]$CandidateZip
    )

    if ($CandidatePath -and $CandidateZip) {
        throw "Use either -SourcePath or -SourceZip, not both."
    }

    if ($CandidateZip) {
        if (-not (Test-Path -LiteralPath $CandidateZip)) {
            throw "Source zip not found: $CandidateZip"
        }

        $expandPath = Join-Path ([System.IO.Path]::GetTempPath()) ("agent-orchestration-" + [guid]::NewGuid().ToString("N"))
        New-Item -ItemType Directory -Path $expandPath -Force | Out-Null
        Expand-Archive -LiteralPath $CandidateZip -DestinationPath $expandPath -Force

        $roots = @(Get-ChildItem -LiteralPath $expandPath -Directory)
        foreach ($root in $roots) {
            $marketplace = Join-Path $root.FullName ".claude-plugin\marketplace.json"
            if (Test-Path -LiteralPath $marketplace) {
                return $root.FullName
            }
        }

        $fallbackMarketplace = Join-Path $expandPath ".claude-plugin\marketplace.json"
        if (Test-Path -LiteralPath $fallbackMarketplace) {
            return $expandPath
        }

        throw "Could not find repo root in zip. Expected .claude-plugin/marketplace.json."
    }

    if (-not $CandidatePath) {
        $CandidatePath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
    }

    $resolved = (Resolve-Path -LiteralPath $CandidatePath).Path
    $marketplace = Join-Path $resolved ".claude-plugin\marketplace.json"
    if (-not (Test-Path -LiteralPath $marketplace)) {
        throw "Source path does not look like this repo: $resolved"
    }

    return $resolved
}

function Sync-Item {
    param(
        [string]$SourceRoot,
        [string]$DestinationRoot,
        [string]$RelativePath
    )

    $source = Join-Path $SourceRoot $RelativePath
    $destination = Join-Path $DestinationRoot $RelativePath

    if (-not (Test-Path -LiteralPath $source)) {
        throw "Required source item missing: $RelativePath"
    }

    $destParent = Split-Path -Parent $destination
    if ($destParent) {
        New-Item -ItemType Directory -Path $destParent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $destination) {
        Remove-Item -LiteralPath $destination -Recurse -Force
    }

    Copy-Item -LiteralPath $source -Destination $destination -Recurse -Force
}

$repoRoot = Resolve-RepoRoot -CandidatePath $SourcePath -CandidateZip $SourceZip
$centralRoot = [System.IO.Path]::GetFullPath($CentralPath)

Write-Host "Installing central Agent Orchestration base..."
Write-Host "  Source:  $repoRoot"
Write-Host "  Target:  $centralRoot"

if ((Test-Path -LiteralPath $centralRoot) -and $Force) {
    Remove-Item -LiteralPath $centralRoot -Recurse -Force
}

New-Item -ItemType Directory -Path $centralRoot -Force | Out-Null

$itemsToSync = @(
    ".claude-plugin",
    ".codex",
    "plugins",
    "scripts",
    "docs",
    ".kilocodemodes",
    "AGENTS.md",
    "README.md",
    "LICENSE"
)

foreach ($item in $itemsToSync) {
    Sync-Item -SourceRoot $repoRoot -DestinationRoot $centralRoot -RelativePath $item
}

Push-Location $centralRoot
try {
    python scripts/generate_kilocodemodes.py
    python scripts/generate_codex_assets.py
}
finally {
    Pop-Location
}

$manifest = @{
    name = "Agent Orchestration"
    sourcePath = $repoRoot
    installedAtUtc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    version = @{}
}

if (Test-Path -LiteralPath (Join-Path $repoRoot ".git")) {
    Push-Location $repoRoot
    try {
        $commit = (git rev-parse HEAD).Trim()
        $branch = (git rev-parse --abbrev-ref HEAD).Trim()
        $manifest.version = @{
            branch = $branch
            commit = $commit
        }
    }
    catch {
        $manifest.version = @{
            branch = ""
            commit = ""
        }
    }
    finally {
        Pop-Location
    }
}

$manifestPath = Join-Path $centralRoot "central-install.json"
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $manifestPath -Encoding UTF8

Write-Host ""
Write-Host "Central base installed successfully."
Write-Host "Location: $centralRoot"
Write-Host "Next step (per project):"
Write-Host "  pwsh -File scripts/bind-agent-orchestration-project.ps1 -ProjectPath <path-to-project> -CentralPath `"$centralRoot`""
