#!/usr/bin/env bash
#
# 07 - Desktop apps
# Day-to-day GUI/monitoring apps: Extension Manager (GNOME extensions),
# EasyEffects (audio effects/EQ), Resources and nvtop (system/GPU
# monitors), lm-sensors (temperatures), pgAdmin 4 (PostgreSQL GUI).
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

sudo install -d -m 0755 /etc/apt/keyrings

# --- Ubuntu archive apps ------------------------------------------------------
# nvtop works with NVIDIA, AMD and Intel GPUs, so it's useful on every machine.
log "Installing desktop apps from the Ubuntu archive"
sudo apt install -y \
  gnome-shell-extension-manager \
  easyeffects \
  resources \
  nvtop \
  lm-sensors

# --- pgAdmin 4 (official pgAdmin APT repo) -----------------------------------
if ! dpkg -s pgadmin4-desktop >/dev/null 2>&1; then
  log "Installing pgAdmin 4 (desktop mode)"
  wget -qO- https://www.pgadmin.org/static/packages_pgadmin_org.pub \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/packages-pgadmin-org.gpg > /dev/null
  echo "deb [signed-by=/etc/apt/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(. /etc/os-release && echo "$VERSION_CODENAME") pgadmin4 main" \
    | sudo tee /etc/apt/sources.list.d/pgadmin4.list > /dev/null
  sudo apt update
  sudo apt install -y pgadmin4-desktop
else
  log "pgAdmin 4 already installed, skipping"
fi

log "Desktop apps setup complete"

# --- Citrix Workspace (manual) ------------------------------------------------
# No APT repo and the download sits behind a license page, so it can't be
# scripted. Only remind about it when it's missing.
if ! dpkg -s icaclient >/dev/null 2>&1; then
  log ""
  log "Manual step — Citrix Workspace (if needed):"
  log "  1. Download the Debian package (icaclient_*_amd64.deb) from"
  log "     https://www.citrix.com/downloads/workspace-app/linux/"
  log "  2. sudo apt install ~/Downloads/icaclient_*_amd64.deb"
fi
