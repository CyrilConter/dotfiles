#!/usr/bin/env bash
#
# 03 - AI / ML tools
# uv (Python package manager), Ollama (local LLM runner).
# Also installs the NVIDIA driver when (and only when) an NVIDIA GPU is
# detected on bare-metal Linux. CUDA toolkit is deliberately NOT installed.
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

# --- NVIDIA driver -----------------------------------------------------------
# Runs first so Ollama (below) can see the GPU after the next reboot.
# Machines without an NVIDIA GPU (e.g. AMD/Intel laptops) need nothing: the
# Mesa drivers shipped with Ubuntu already cover them.
#
# Under WSL the GPU comes from the *Windows* NVIDIA driver (exposed at
# /usr/lib/wsl/lib). Installing the Linux nvidia-driver inside WSL is wrong
# and breaks the GPU passthrough.
if grep -qi microsoft /proc/version 2>/dev/null; then
  if ! command -v nvidia-smi >/dev/null 2>&1; then
    warn "Running under WSL and 'nvidia-smi' is not on PATH."
    warn "Do NOT install nvidia-driver inside WSL — install the NVIDIA driver"
    warn "on Windows. It exposes the GPU to WSL via /usr/lib/wsl/lib."
    warn "Reference: https://docs.nvidia.com/cuda/wsl-user-guide/"
  fi
# (lspci output is captured first: piping it into `grep -q` under pipefail
# fails with SIGPIPE as soon as grep finds a match.)
elif grep -Eqi '(vga|3d|display).*nvidia' <<<"$(lspci 2>/dev/null)"; then
  if command -v nvidia-smi >/dev/null 2>&1; then
    log "NVIDIA driver already installed ($(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)), skipping"
  else
    log "NVIDIA GPU detected — installing the recommended driver"
    sudo ubuntu-drivers install
    warn "Reboot, then run 'nvidia-smi' to verify the driver."
  fi
else
  log "No NVIDIA GPU detected, skipping driver install"
fi

# --- uv -----------------------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  log "Installing uv (Python package + project manager)"
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  log "uv already installed, skipping"
fi

# --- Ollama -------------------------------------------------------------------
# Easiest way to run local LLMs (Llama, Mistral, Qwen, etc.).
if ! command -v ollama >/dev/null 2>&1; then
  log "Installing Ollama"
  curl -fsSL https://ollama.com/install.sh | sh
else
  log "Ollama already installed, skipping"
fi

log "AI/ML tools setup complete"
log "Next steps:"
log "  - Try 'ollama run llama3.2' to download and chat with a small local model."
log "  - In a project: 'uv init && uv add torch transformers' to start fresh."
log "  - PyTorch/JAX bundle their own CUDA runtime; the full CUDA toolkit is"
log "    only needed when compiling CUDA code."
