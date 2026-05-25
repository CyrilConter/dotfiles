<#
.SYNOPSIS
    Windows dotfiles installer.

.DESCRIPTION
    Symlinks config files into the user profile, then runs the
    numbered setup scripts in .\setup\ to install development tooling
    via winget. Mirrors the structure of linux/install.sh.

.PARAMETER NoSetup
    Skip the numbered setup scripts; only create symlinks.

.PARAMETER DryRun
    Print actions without performing them.

.EXAMPLE
    .\install.ps1
    .\install.ps1 -NoSetup
    .\install.ps1 -DryRun

.NOTES
    Requires PowerShell 7+ (pwsh).
    Symlinks require either administrator privileges OR Windows 10/11
    Developer Mode enabled (Settings > For developers).
#>

[CmdletBinding()]
param(
    [switch]$NoSetup,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

# ---- Path resolution --------------------------------------------------------
$ScriptDir     = Split-Path -Parent $MyInvocation.MyCommand.Path
$DotfilesRoot  = Split-Path -Parent $ScriptDir
$WindowsDir    = $ScriptDir
$SharedDir     = Join-Path $DotfilesRoot 'shared'

# ---- Helpers ----------------------------------------------------------------
function Write-Step  { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Warn2 { param($Msg) Write-Host "!!  $Msg" -ForegroundColor Yellow }

function New-Link {
    param(
        [string]$Source,
        [string]$Target
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Warn2 "Source missing, skipping: $Source"
        return
    }

    if ($DryRun) {
        Write-Host "  (dry-run) link $Target -> $Source"
        return
    }

    # If a non-symlink already exists at the target, back it up once.
    if (Test-Path -LiteralPath $Target) {
        $item = Get-Item -LiteralPath $Target -Force
        if (-not $item.LinkType) {
            $backup = "$Target.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Move-Item -LiteralPath $Target -Destination $backup
            Write-Warn2 "Backed up existing $Target to $backup"
        } else {
            # Existing symlink — remove so we can recreate
            Remove-Item -LiteralPath $Target -Force
        }
    }

    $parent = Split-Path -Parent $Target
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        Write-Host "  linked $Target -> $Source"
    } catch {
        Write-Warn2 "Failed to create symlink (need Developer Mode or admin): $Target"
        Write-Warn2 "  $($_.Exception.Message)"
    }
}

Write-Step "Dotfiles root: $DotfilesRoot"

# ---- Symlinks ---------------------------------------------------------------
Write-Step "Linking Starship config"
$starshipSource = Join-Path $SharedDir 'starship\starship.toml'
$starshipTarget = Join-Path $env:USERPROFILE '.config\starship.toml'
New-Link -Source $starshipSource -Target $starshipTarget

Write-Step "Linking git config"
$gitconfigSource = Join-Path $SharedDir 'git\gitconfig'
$gitconfigTarget = Join-Path $env:USERPROFILE '.gitconfig'
New-Link -Source $gitconfigSource -Target $gitconfigTarget

$gitignoreSource = Join-Path $SharedDir 'git\gitignore_global'
$gitignoreTarget = Join-Path $env:USERPROFILE '.gitignore_global'
New-Link -Source $gitignoreSource -Target $gitignoreTarget

Write-Step "Linking VS Code settings"
$vscodeDir = Join-Path $env:APPDATA 'Code\User'
New-Link -Source (Join-Path $SharedDir 'vscode\settings.json')    -Target (Join-Path $vscodeDir 'settings.json')
New-Link -Source (Join-Path $SharedDir 'vscode\keybindings.json') -Target (Join-Path $vscodeDir 'keybindings.json')

Write-Step "Linking PowerShell profile"
# PowerShell 7+ profile location
$pwshProfileDir    = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'
$pwshProfileTarget = Join-Path $pwshProfileDir 'Microsoft.PowerShell_profile.ps1'
New-Link -Source (Join-Path $WindowsDir 'powershell\profile.ps1') -Target $pwshProfileTarget

# ---- Setup scripts ----------------------------------------------------------
if (-not $NoSetup) {
    Write-Step "Running setup scripts"
    $setupScripts = Get-ChildItem -Path (Join-Path $WindowsDir 'setup') -Filter '[0-9]*.ps1' | Sort-Object Name
    foreach ($script in $setupScripts) {
        Write-Step "Running $($script.Name)"
        if ($DryRun) {
            Write-Host "  (dry-run) pwsh $($script.FullName)"
        } else {
            & $script.FullName
        }
    }
} else {
    Write-Step "Skipping setup scripts (-NoSetup)"
}

Write-Step "Done. Open a new PowerShell window so the new profile is picked up."
