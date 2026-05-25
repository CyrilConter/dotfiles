<#
.SYNOPSIS
    Install GitHub CLI and Azure CLI via winget.

.DESCRIPTION
    Also installs the Azure DevOps extension for `az devops` /
    `az repos` / `az pipelines` commands.

    Auth (do these once after install, manually):
        gh auth login
        az login
        az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>
#>

$ErrorActionPreference = 'Stop'

function Write-Step  { param($Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Warn2 { param($Msg) Write-Host "!!  $Msg" -ForegroundColor Yellow }

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Warn2 "winget not found. Install 'App Installer' from the Microsoft Store first."
    return
}

# ---- GitHub CLI -------------------------------------------------------------
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Step "Installing GitHub CLI"
    winget install --id GitHub.cli --accept-source-agreements --accept-package-agreements -e
} else {
    Write-Step "GitHub CLI already installed, skipping"
}

# ---- Azure CLI --------------------------------------------------------------
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Step "Installing Azure CLI"
    winget install --id Microsoft.AzureCLI --accept-source-agreements --accept-package-agreements -e
} else {
    Write-Step "Azure CLI already installed, skipping"
}

# ---- Azure DevOps extension -------------------------------------------------
# `az` needs to be on PATH first — winget installs may require restarting
# the shell. Refresh PATH for this session so the next command works.
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [System.Environment]::GetEnvironmentVariable('Path', 'User')

if (Get-Command az -ErrorAction SilentlyContinue) {
    $hasExt = (az extension list --query "[?name=='azure-devops'] | length(@)" -o tsv 2>$null)
    if ($hasExt -ne '1') {
        Write-Step "Installing Azure DevOps extension"
        az extension add --name azure-devops --upgrade
    } else {
        Write-Step "Azure DevOps extension already installed, skipping"
    }
} else {
    Write-Warn2 "az not on PATH in this session — open a new shell and run:"
    Write-Warn2 "  az extension add --name azure-devops"
}

Write-Step "CLIs installed. Sign in with:"
Write-Step "  gh auth login"
Write-Step "  az login"
