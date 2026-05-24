# PowerShell profile — managed by dotfiles repo
# This file is symlinked from windows/powershell/profile.ps1 to
# $PROFILE (the PowerShell 7+ user profile location).
# Edit in the repo, not in $PROFILE.

# ---- Starship prompt --------------------------------------------------------
# Point Starship at the shared config (same one Linux uses).
$env:STARSHIP_CONFIG = Join-Path $env:USERPROFILE '.config\starship.toml'

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

# ---- PSReadLine: better command-line editing --------------------------------
# Built into PowerShell 7. These tweaks make it feel modern.
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue

    # History-based autosuggestions (fish-style ghost text)
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView

    # Emacs-style keys (Ctrl-A start of line, Ctrl-E end, etc.) —
    # matches what bash does on Linux.
    Set-PSReadLineOption -EditMode Emacs

    # Avoid duplicate history entries
    Set-PSReadLineOption -HistoryNoDuplicates

    # Up/Down arrows search history matching what you've typed so far
    Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# ---- Aliases (matching Linux .bash_aliases where possible) ------------------
# Note: PowerShell already aliases ls, cat, etc., differently.
# Use functions for things that take args.

function gs  { git status @args }
function gd  { git diff @args }
function gl  { git log --oneline --graph --decorate -n 20 @args }
function gp  { git pull @args }
function gco { git checkout @args }

function .. { Set-Location .. }
function ... { Set-Location ..\.. }

# ---- Machine-specific overrides --------------------------------------------
# Put work-vs-personal differences here. NOT tracked in git.
$localProfile = Join-Path (Split-Path -Parent $PROFILE) 'profile.local.ps1'
if (Test-Path -LiteralPath $localProfile) {
    . $localProfile
}
