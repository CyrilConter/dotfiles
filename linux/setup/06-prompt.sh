#!/usr/bin/env bash
#
# 06 - Prompt (Starship)
# Starship is a cross-platform prompt that works the same in bash, zsh,
# fish, and PowerShell. We keep the config in shared/starship/ so both
# Linux and Windows render the same prompt.
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

# --- Starship binary ----------------------------------------------------------
if ! command -v starship >/dev/null 2>&1; then
  log "Installing Starship"
  # Official installer; drops the binary in /usr/local/bin.
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
else
  log "Starship already installed ($(starship --version | head -1)), skipping"
fi

# --- Font requirement ---------------------------------------------------------
# Starship uses powerline glyphs from a Nerd Font for icons/separators.
# fonts/README.md covers the install steps. Reminder, not enforced.
if ! fc-list 2>/dev/null | grep -qi "nerd"; then
  warn "No Nerd Font detected. Starship icons will look broken."
  warn "Install Hack Nerd Font — see fonts/README.md."
fi

log "Starship setup complete"
log ""
log "Activation is handled by .bashrc (added by install.sh). Open a new"
log "terminal to see the new prompt. Config lives in shared/starship/starship.toml."
