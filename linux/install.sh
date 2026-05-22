#!/usr/bin/env bash
#
# Linux dotfiles installer
# ------------------------
# Symlinks config files into $HOME, then runs the numbered setup
# scripts in ./setup/ to install development tooling.
#
# Usage:
#   ./install.sh             # full install (symlinks + all setup scripts)
#   ./install.sh --no-setup  # only symlinks, skip setup scripts
#   ./install.sh --dry-run   # print actions without doing them
#
set -euo pipefail

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LINUX_DIR="$SCRIPT_DIR"
SHARED_DIR="$DOTFILES_ROOT/shared"

# Flags
RUN_SETUP=1
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --no-setup) RUN_SETUP=0 ;;
    --dry-run)  DRY_RUN=1 ;;
    -h|--help)
      sed -n '2,12p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

# Helpers
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

link() {
  local src="$1" dst="$2"
  if [[ ! -e "$src" ]]; then
    warn "Source missing, skipping: $src"
    return
  fi
  if [[ "$DRY_RUN" == 1 ]]; then
    echo "ln -sfn $src $dst"
    return
  fi
  # Backup any pre-existing real file (not a symlink) once
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "$dst.backup.$(date +%Y%m%d-%H%M%S)"
    warn "Backed up existing $dst"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
  echo "  linked $dst -> $src"
}

log "Dotfiles root: $DOTFILES_ROOT"

# ---- Symlinks ----------------------------------------------------------------
log "Linking shell configs"
link "$LINUX_DIR/bash/bashrc"        "$HOME/.bashrc"
link "$LINUX_DIR/bash/bash_aliases"  "$HOME/.bash_aliases"

# Optional zsh — only link if user has zsh installed
if command -v zsh >/dev/null 2>&1; then
  link "$LINUX_DIR/zsh/zshrc" "$HOME/.zshrc"
fi

log "Linking git config"
link "$SHARED_DIR/git/gitconfig"   "$HOME/.gitconfig"
link "$SHARED_DIR/git/gitignore_global" "$HOME/.gitignore_global"

log "Linking VS Code settings"
VSCODE_USER_DIR="$HOME/.config/Code/User"
link "$SHARED_DIR/vscode/settings.json"    "$VSCODE_USER_DIR/settings.json"
link "$SHARED_DIR/vscode/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"

# ---- Setup scripts -----------------------------------------------------------
if [[ "$RUN_SETUP" == 1 ]]; then
  log "Running setup scripts"
  shopt -s nullglob
  for script in "$LINUX_DIR/setup/"[0-9]*.sh; do
    log "Running $(basename "$script")"
    if [[ "$DRY_RUN" == 1 ]]; then
      echo "bash $script"
    else
      bash "$script"
    fi
  done
else
  log "Skipping setup scripts (--no-setup)"
fi

log "Done. Open a new terminal so the new shell config is picked up."
