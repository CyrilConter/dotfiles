# Install Scoop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod get.scoop.sh | Invoke-Expression

# Add extras bucket
scoop bucket add extras

# Install tools using scoop
scoop install oh-my-posh
scoop install posh-git
scoop install azure-cli
scoop install azurestorageexplorer
scoop install powertoys
scoop install draw.io
