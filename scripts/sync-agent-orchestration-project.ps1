[CmdletBinding()]
param(
    [string]$ProjectPath = ".",
    [string]$CentralPath = "$HOME\.agent-orchestration",
    [ValidateSet("Link", "Copy")]
    [string]$Mode = "Link",
    [switch]$EnableClaudeLocal
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$bindScript = Join-Path $PSScriptRoot "bind-agent-orchestration-project.ps1"
& $bindScript `
    -ProjectPath $ProjectPath `
    -CentralPath $CentralPath `
    -Mode $Mode `
    -EnableClaudeLocal:$EnableClaudeLocal `
    -Force
