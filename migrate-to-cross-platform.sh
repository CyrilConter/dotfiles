#!/usr/bin/env bash
#
# migrate-to-cross-platform.sh
# -----------------------------
# Run this ONCE against your existing dotfiles checkout to move the
# current Windows content into windows/ and lay down the new
# Linux/shared structure on a feature branch.
#
# Usage:
#   cd ~/dotfiles                    # your existing checkout
#   bash /path/to/migrate-to-cross-platform.sh
#
# After it finishes:
#   git status                       # review the changes
#   git push -u origin reorg-cross-platform
#   # then open a PR on GitHub and merge it
#
set -euo pipefail

# Confirm we are in the dotfiles repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: run this from inside your dotfiles git checkout." >&2
  exit 1
fi
if [[ ! -f install.ps1 ]] || [[ ! -d powershell ]]; then
  echo "ERROR: expected install.ps1 and powershell/ at repo root." >&2
  echo "       are you in the right repo?" >&2
  exit 1
fi

BRANCH="reorg-cross-platform"
if git show-ref --quiet "refs/heads/$BRANCH"; then
  echo "Branch $BRANCH already exists; checking it out."
  git checkout "$BRANCH"
else
  echo "Creating branch $BRANCH"
  git checkout -b "$BRANCH"
fi

echo "==> Moving Windows files into windows/"
mkdir -p windows
git mv install.ps1   windows/install.ps1
git mv powershell    windows/powershell

echo "==> Creating the new directory layout"
mkdir -p linux/bash linux/zsh linux/git linux/vscode linux/setup
mkdir -p shared/git shared/vscode
mkdir -p fonts

echo
echo "Directory moves are staged. Next:"
echo "  1. Copy the new files (linux/install.sh, setup scripts, configs,"
echo "     README.md, etc.) from the archive into this checkout."
echo "  2. git add -A"
echo "  3. git commit -m 'Reorganize repo for Windows/Linux'"
echo "  4. git push -u origin $BRANCH"
echo "  5. Open a PR on GitHub and merge to main."
