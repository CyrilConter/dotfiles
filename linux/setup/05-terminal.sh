#!/usr/bin/env bash
#
# 05 - Terminal stack
# tmux (terminal multiplexer) + Ghostty (terminal emulator) + herdr
# (background runtime for coding agents).
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
# Ubuntu 26.04+ ships Ghostty in its own archive (universe), so a plain apt
# install is enough — no snap, no third-party repo. This repo targets 26.04+.
#
# If a snap Ghostty is already present, it's left alone; switch with:
#   sudo snap remove ghostty && sudo apt install -y ghostty
if ! command -v ghostty >/dev/null 2>&1; then
  log "Installing Ghostty (Ubuntu archive)"
  sudo apt install -y ghostty
else
  log "Ghostty already installed ($(command -v ghostty)), skipping"
fi

# --- herdr --------------------------------------------------------------------
# Background runtime for coding agents (https://herdr.dev): keeps agents
# running across projects when you disconnect, with a sidebar showing which
# ones are working / blocked / idle. Complements tmux and claude-swarm.
# The official installer verifies the SHA-256 and drops the binary in
# ~/.local/bin (already on PATH via bashrc). Update later with `herdr update`.
if ! command -v herdr >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/herdr" ]]; then
  log "Installing herdr"
  curl -fsSL https://herdr.dev/install.sh | sh
else
  log "herdr already installed, skipping (update with: herdr update)"
fi

log "Terminal stack setup complete"
log ""
log "Next steps:"
log "  1. Open a new terminal and run: tmux"
log "  2. Press Ctrl-a then capital I to install tmux plugins"
log "  3. (Optional) Set Ghostty as your default terminal in GNOME settings"
log "  4. Run: herdr   (update later with: herdr update)"
