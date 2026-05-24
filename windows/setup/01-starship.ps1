<#
.SYNOPSIS
    Install Starship prompt via winget.

.DESCRIPTION
    The profile.ps1 already wires Starship into PowerShell. This
    script just installs the binary.
#>

$ErrorActionPreference = 'Stop'

function Write-Step  { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Warn2 { param($Msg) Write-Host "!!  $Msg" -ForegroundColor Yellow }

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Write-Step "Starship already installed ($(starship --version | Select-Object -First 1)), skipping"
    return
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warn2 "winget not found. Install 'App Installer' from the Microsoft Store first."
    return
}

Write-Step "Installing Starship"
winget install --id Starship.Starship --accept-source-agreements --accept-package-agreements -e

Write-Step "Starship installed. Restart PowerShell to see the new prompt."
Write-Step "Make sure a Nerd Font is installed (see fonts/README.md)."
