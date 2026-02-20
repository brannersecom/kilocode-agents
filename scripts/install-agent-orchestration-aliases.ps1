[CmdletBinding()]
param(
    [string]$CentralPath = "$HOME\.agent-orchestration",
    [string]$ProfilePath = "",
    [switch]$AllHosts
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-TargetProfiles {
    param(
        [string]$SingleProfilePath,
        [switch]$IncludeAllHosts
    )

    if ($SingleProfilePath) {
        return @([System.IO.Path]::GetFullPath($SingleProfilePath))
    }

    if ($IncludeAllHosts) {
        return @($PROFILE.CurrentUserCurrentHost, $PROFILE.CurrentUserAllHosts)
    }

    return @($PROFILE.CurrentUserCurrentHost)
}

function Ensure-ProfilePath {
    param([string]$Path)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType File -Path $Path -Force | Out-Null
    }
}

function Remove-ExistingBlock {
    param(
        [string]$Content,
        [string]$StartMarker,
        [string]$EndMarker
    )

    $pattern = [regex]::Escape($StartMarker) + ".*?" + [regex]::Escape($EndMarker)
    $regex = [regex]::new($pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    return $regex.Replace($Content, "").TrimEnd()
}

$resolvedCentral = [System.IO.Path]::GetFullPath($CentralPath)
$bindScript = Join-Path $resolvedCentral "scripts\bind-agent-orchestration-project.ps1"
$syncScript = Join-Path $resolvedCentral "scripts\sync-agent-orchestration-project.ps1"
$installScript = Join-Path $resolvedCentral "scripts\install-agent-orchestration-central.ps1"

if (-not (Test-Path -LiteralPath $bindScript)) {
    throw "Missing bind script at central path: $bindScript"
}
if (-not (Test-Path -LiteralPath $syncScript)) {
    throw "Missing sync script at central path: $syncScript"
}
if (-not (Test-Path -LiteralPath $installScript)) {
    throw "Missing install script at central path: $installScript"
}

$escapedCentral = $resolvedCentral.Replace("'", "''")
$startMarker = "# >>> Agent Orchestration Aliases >>>"
$endMarker = "# <<< Agent Orchestration Aliases <<<"

$block = @"
$startMarker
`$env:AGENT_ORCHESTRATION_HOME = '$escapedCentral'

function ao-bind {
    [CmdletBinding()]
    param(
        [string]`$ProjectPath = '.',
        [ValidateSet('Link', 'Copy')]
        [string]`$Mode = 'Link',
        [switch]`$EnableClaudeLocal,
        [switch]`$Force
    )

    `$params = @{
        ProjectPath = `$ProjectPath
        CentralPath = `$env:AGENT_ORCHESTRATION_HOME
        Mode = `$Mode
        EnableClaudeLocal = `$EnableClaudeLocal.IsPresent
        Force = `$Force.IsPresent
    }

    & "`$env:AGENT_ORCHESTRATION_HOME\scripts\bind-agent-orchestration-project.ps1" @params
}

function ao-sync {
    [CmdletBinding()]
    param(
        [string]`$ProjectPath = '.',
        [ValidateSet('Link', 'Copy')]
        [string]`$Mode = 'Link',
        [switch]`$EnableClaudeLocal
    )

    `$params = @{
        ProjectPath = `$ProjectPath
        CentralPath = `$env:AGENT_ORCHESTRATION_HOME
        Mode = `$Mode
        EnableClaudeLocal = `$EnableClaudeLocal.IsPresent
    }

    & "`$env:AGENT_ORCHESTRATION_HOME\scripts\sync-agent-orchestration-project.ps1" @params
}

function ao-central-update {
    [CmdletBinding()]
    param(
        [string]`$SourcePath = '',
        [string]`$SourceZip = '',
        [switch]`$Force
    )

    `$params = @{
        CentralPath = `$env:AGENT_ORCHESTRATION_HOME
        SourcePath = `$SourcePath
        SourceZip = `$SourceZip
        Force = `$Force.IsPresent
    }

    & "`$env:AGENT_ORCHESTRATION_HOME\scripts\install-agent-orchestration-central.ps1" @params
}

function ao-help {
    Write-Host 'Agent Orchestration commands:'
    Write-Host '  ao-bind -ProjectPath "." -Mode Link -Force'
    Write-Host '  ao-sync -ProjectPath "." -Mode Link'
    Write-Host '  ao-central-update -SourcePath "<repo-path>" -Force'
}
$endMarker
"@

$profiles = Resolve-TargetProfiles -SingleProfilePath $ProfilePath -IncludeAllHosts:$AllHosts

foreach ($profileFile in $profiles) {
    Ensure-ProfilePath -Path $profileFile

    $current = Get-Content -LiteralPath $profileFile -Raw -Encoding UTF8
    $cleaned = Remove-ExistingBlock -Content $current -StartMarker $startMarker -EndMarker $endMarker

    if ($cleaned) {
        $updated = $cleaned + "`r`n`r`n" + $block + "`r`n"
    }
    else {
        $updated = $block + "`r`n"
    }

    Set-Content -LiteralPath $profileFile -Value $updated -Encoding UTF8
    Write-Host "Updated profile: $profileFile"
}

Write-Host ""
Write-Host "Aliases installed. Open a new shell or run:"
Write-Host "  . `$PROFILE"
Write-Host "Then use:"
Write-Host "  ao-bind -ProjectPath '.' -Mode Link -Force"
Write-Host "  ao-sync -ProjectPath '.' -Mode Link"
Write-Host "  ao-help"
