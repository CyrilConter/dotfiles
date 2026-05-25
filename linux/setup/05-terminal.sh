#!/usr/bin/env bash
#
# 05 - Terminal stack
# tmux (terminal multiplexer) + Ghostty (terminal emulator).
#
# Why both: tmux gives session persistence and multi-pane management
# (critical for running multiple Claude Code agents in parallel and
# for surviving SSH drops). Ghostty replaces GNOME Terminal with a
# faster, GPU-accelerated emulator with sensible defaults.
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

# --- tmux ---------------------------------------------------------------------
if ! command -v tmux >/dev/null 2>&1; then
  log "Installing tmux"
  sudo apt install -y tmux
else
  log "tmux already installed (version: $(tmux -V)), skipping"
fi

# --- TPM (Tmux Plugin Manager) -----------------------------------------------
# Lets the tmux config below load plugins like tmux-resurrect (save/restore
# sessions across reboots) and tmux-yank (system clipboard integration).
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  log "Installing TPM (tmux plugin manager)"
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  log "After first tmux start, press prefix + I (capital i) to install plugins."
else
  log "TPM already installed, skipping"
fi

# --- Ghostty ------------------------------------------------------------------
# Ghostty doesn't yet have an official apt repo for Ubuntu, but there's a
# community-maintained build path. Easiest reliable install is via the
# official install script which fetches a prebuilt binary.
#
# If you prefer to skip Ghostty (e.g. you're happy with GNOME Terminal),
# comment out this block.
if ! command -v ghostty >/dev/null 2>&1; then
  log "Installing Ghostty"
  # Snap is currently Ghostty's recommended Linux distribution method.
  if command -v snap >/dev/null 2>&1; then
    sudo snap install ghostty --classic
  else
    warn "snap not available — install Ghostty manually from https://ghostty.org"
    warn "Skipping Ghostty install."
  fi
else
  log "Ghostty already installed, skipping"
fi

log "Terminal stack setup complete"
log ""
log "Next steps:"
log "  1. Open a new terminal and run: tmux"
log "  2. Press Ctrl-a then capital I to install tmux plugins"
log "  3. (Optional) Set Ghostty as your default terminal in GNOME settings"
