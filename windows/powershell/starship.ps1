# Starship integration for PowerShell
# ------------------------------------
# Add the contents of this file to your PowerShell $PROFILE
# (or `. path\to\starship.ps1` to source it).
#
# Install Starship on Windows with one of:
#   winget install --id Starship.Starship
#   scoop install starship

# Point Starship at the shared config in the dotfiles repo.
# Adjust the path if your repo lives elsewhere.
$env:STARSHIP_CONFIG = "$HOME\dotfiles\shared\starship\starship.toml"

# Activate Starship as the prompt.
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}
