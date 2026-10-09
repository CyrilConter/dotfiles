#!/usr/bin/env bash
#
# 08 - GNOME desktop
# Installs GNOME Shell extensions from extensions.gnome.org and applies the
# desktop + extension settings stored in linux/gnome/*.ini (dconf format).
#
# Must run inside a logged-in GNOME session (dconf needs the session bus);
# it skips itself otherwise, e.g. over SSH.
#
# To refresh the .ini files after changing settings on a machine, dump the
# relevant section and copy over only the keys you care about, e.g.:
#   dconf dump /org/gnome/shell/extensions/dash-to-dock/
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GNOME_DIR="$(cd "$SCRIPT_DIR/../gnome" && pwd)"

# Extensions from extensions.gnome.org (Ubuntu's own dock, tiling assistant,
# desktop icons and appindicators come preinstalled).
EXTENSIONS=(
  dash-to-dock@micxgx.gmail.com   # Dash to Dock
  blur-my-shell@aunetx            # Blur my Shell
  monitor@astraext.github.io      # Astra Monitor (CPU/GPU/RAM/sensors in top bar)
)

if ! command -v gnome-shell >/dev/null 2>&1 || [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  warn "No GNOME session detected — skipping GNOME setup."
  warn "Re-run from a terminal inside the desktop: bash $0"
  exit 0
fi

# --- Extensions ---------------------------------------------------------------
SHELL_VERSION="$(gnome-shell --version | awk '{print $3}' | cut -d. -f1)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

NEW_EXTENSIONS=0
for uuid in "${EXTENSIONS[@]}"; do
  if gnome-extensions info "$uuid" >/dev/null 2>&1; then
    log "Extension $uuid already installed, skipping"
    continue
  fi
  log "Installing extension $uuid (GNOME $SHELL_VERSION)"
  url="$(curl -fsSL "https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${SHELL_VERSION}" \
    | jq -r '.download_url // empty')" || url=""
  if [[ -z "$url" ]]; then
    warn "No build of $uuid for GNOME $SHELL_VERSION — install it later with Extension Manager."
    continue
  fi
  curl -fsSL "https://extensions.gnome.org${url}" -o "$TMP/$uuid.zip"
  gnome-extensions install --force "$TMP/$uuid.zip"
  NEW_EXTENSIONS=1
done

# --- Settings -----------------------------------------------------------------
# dconf load only writes the keys present in the file; everything else is
# left untouched. Re-running just re-applies the same values.
log "Applying desktop settings"
dconf load /org/gnome/ < "$GNOME_DIR/desktop-settings.ini"

log "Applying extension settings (and enabled extensions list)"
dconf load /org/gnome/shell/ < "$GNOME_DIR/extensions.ini"

log "GNOME setup complete"
if [[ "$NEW_EXTENSIONS" == 1 ]]; then
  warn "Log out and back in to activate the new extensions (Wayland can't"
  warn "reload GNOME Shell in place)."
fi
