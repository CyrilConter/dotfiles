# Prompt
Import-Module Terminal-Icons
Import-Module posh-git

# Load prompt config
function Get-ScriptDirectory { Split-Path $MyInvocation.ScriptName }
$PROMPT_CONFIG = Join-Path(Get-ScriptDirectory) 'cyril.omp.json'
oh-my-posh --init --shell pwsh --config $PROMPT_CONFIG | Invoke-Expression

# Alias
Set-Alias vim nvim