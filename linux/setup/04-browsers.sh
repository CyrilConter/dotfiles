#!/usr/bin/env bash
#
# 04 - Browsers
# Installs Firefox (Mozilla's official .deb, not the snap) and
# Google Chrome.
#
# Why not the Ubuntu snap Firefox? Slower startup, sandbox quirks
# with extensions accessing local files, and Mozilla now ships its
# own properly-signed APT repository.
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

sudo install -d -m 0755 /etc/apt/keyrings

# --- Firefox (official Mozilla APT repo) -------------------------------------
# Prefer this over the Ubuntu snap. If the snap is already installed it's
# left alone; you can `sudo snap remove firefox` later to clean it up.
if ! dpkg -s firefox >/dev/null 2>&1; then
  log "Installing Firefox from Mozilla's APT repo"

  # 1. Add Mozilla's signing key
  wget -qO- https://packages.mozilla.org/apt/repo-signing-key.gpg \
    | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

  # 2. Add the repo
  echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" \
    | sudo tee /etc/apt/sources.list.d/mozilla.list > /dev/null

  # 3. Pin Mozilla's package above the Ubuntu snap-transition package, so
  #    `apt install firefox` resolves to the real deb, not the snap stub.
  sudo tee /etc/apt/preferences.d/mozilla > /dev/null <<'EOF'
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
EOF

  sudo apt update
  sudo apt install -y firefox
else
  log "Firefox already installed, skipping"
fi

# --- Google Chrome (official Google APT repo) --------------------------------
if ! command -v google-chrome >/dev/null 2>&1; then
  log "Installing Google Chrome"
  wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/google-chrome.gpg > /dev/null
  echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list > /dev/null
  sudo apt update
  sudo apt install -y google-chrome-stable
else
  log "Google Chrome already installed, skipping"
fi

log "Browsers setup complete"
log "If you previously had the snap Firefox, remove it with:"
log "  sudo snap remove firefox"
