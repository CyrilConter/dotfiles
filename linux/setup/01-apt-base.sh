#!/usr/bin/env bash
#
# 01 - Base apt packages
# Build toolchain, common libraries, and friendly CLI tools.
#
set -euo pipefail

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }

log "Updating apt index"
sudo apt update

log "Installing base packages"
sudo apt install -y \
  build-essential \
  curl \
  wget \
  unzip \
  zip \
  git \
  pkg-config \
  libssl-dev \
  ca-certificates \
  gnupg \
  apt-transport-https \
  software-properties-common

log "Installing friendly CLI tools"
sudo apt install -y \
  ripgrep \
  fd-find \
  bat \
  fzf \
  jq \
  htop \
  tree \
  tmux \
  zsh

# Ubuntu installs these under different names — create the expected aliases.
# (fd → fdfind, bat → batcat). The aliases live in bash_aliases so they persist.
log "Base apt setup complete"
