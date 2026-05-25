#!/usr/bin/env bash
#
# 02 - Development tools
# VS Code, Docker, GitHub CLI, Node version manager (nvm), Rust.
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

sudo install -d -m 0755 /etc/apt/keyrings

# --- VS Code ------------------------------------------------------------------
if ! command -v code >/dev/null 2>&1; then
  log "Installing VS Code"
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
  echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
  sudo apt update
  sudo apt install -y code
else
  log "VS Code already installed, skipping"
fi

# --- GitHub CLI ---------------------------------------------------------------
if ! command -v gh >/dev/null 2>&1; then
  log "Installing GitHub CLI"
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh
else
  log "GitHub CLI already installed, skipping"
fi

# --- Docker -------------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  log "Installing Docker Engine"
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
  warn "You must log out and back in for docker group membership to take effect."
else
  log "Docker already installed, skipping"
fi

# --- nvm (Node version manager) ----------------------------------------------
if [[ ! -d "$HOME/.nvm" ]]; then
  log "Installing nvm"
  # See https://github.com/nvm-sh/nvm#installing-and-updating for the latest version.
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
else
  log "nvm already installed, skipping"
fi

# --- Rust (rustup) ------------------------------------------------------------
if ! command -v rustup >/dev/null 2>&1; then
  log "Installing Rust (rustup)"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
else
  log "rustup already installed, skipping"
fi

log "Dev tools setup complete"
