#!/usr/bin/env bash
#
# 09 - Cloud / DevOps CLIs
# Azure CLI (`az`) and the Azure DevOps extension (`az devops`).
#
# GitHub CLI (`gh`) is already installed by 02-dev-tools.sh.
#
# Useful commands after install:
#   az login                       # browser-based login
#   az devops configure --defaults organization=https://dev.azure.com/<your-org> project=<your-project>
#   az repos list                  # list repos in default project
#   az pipelines list              # list pipelines
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

sudo install -d -m 0755 /etc/apt/keyrings

# --- Azure CLI ----------------------------------------------------------------
if ! command -v az >/dev/null 2>&1; then
  log "Installing Azure CLI"

  # Microsoft's signing key (same one used for VS Code, but stored under its
  # own keyring file so each repo references the right key explicitly).
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null

  # Azure CLI repo — pinned to the system's Ubuntu codename.
  AZ_REPO="$(lsb_release -cs)"
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" \
    | sudo tee /etc/apt/sources.list.d/azure-cli.list > /dev/null

  sudo apt update
  sudo apt install -y azure-cli
else
  log "Azure CLI already installed ($(az version --query \"\\\"azure-cli\\\"\" -o tsv 2>/dev/null || echo unknown)), skipping"
fi

# --- Azure DevOps extension ---------------------------------------------------
if ! az extension list --query "[?name=='azure-devops'] | length(@)" -o tsv 2>/dev/null | grep -q '^1$'; then
  log "Installing Azure DevOps extension"
  az extension add --name azure-devops --upgrade
else
  log "Azure DevOps extension already installed, skipping"
fi

log "Cloud CLI setup complete"
log ""
log "Next steps:"
log "  az login                 # sign in to Azure"
log "  gh auth login            # sign in to GitHub (gh is from 02-dev-tools)"
log ""
log "For Azure DevOps, set your default org/project to avoid passing them every time:"
log "  az devops configure --defaults organization=https://dev.azure.com/<org> project=<project>"
