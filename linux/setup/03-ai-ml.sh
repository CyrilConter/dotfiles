#!/usr/bin/env bash
#
# 03 - AI / ML tools
# uv (Python package manager), Ollama (local LLM runner).
# NVIDIA driver / CUDA setup is deliberately NOT automated — see notes below.
#
set -euo pipefail

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!  %s\033[0m\n' "$*"; }

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

# --- NVIDIA / CUDA hint -------------------------------------------------------
# Detect WSL: under WSL, the GPU is provided by the *Windows* NVIDIA driver
# (exposed at /usr/lib/wsl/lib). Installing the Linux nvidia-driver inside
# WSL is wrong and will break the GPU passthrough.
if command -v nvidia-smi >/dev/null 2>&1; then
  log "NVIDIA driver detected:"
  nvidia-smi | head -15 || true
else
  if grep -qi microsoft /proc/version 2>/dev/null; then
    warn "Running under WSL and 'nvidia-smi' is not on PATH."
    warn "Do NOT install nvidia-driver inside WSL — install the NVIDIA driver"
    warn "on Windows. It exposes the GPU to WSL via /usr/lib/wsl/lib, and"
    warn "'nvidia-smi' should then work here without any Linux-side driver."
    warn "Reference: https://docs.nvidia.com/cuda/wsl-user-guide/"
  else
    warn "No NVIDIA driver detected."
    warn "If this machine has an NVIDIA GPU, install the driver manually:"
    warn "  sudo ubuntu-drivers install"
    warn "  reboot"
    warn "  nvidia-smi   # verify"
  fi
  warn "Most ML frameworks (PyTorch, JAX) bundle their own CUDA runtime,"
  warn "so you usually do not need the full CUDA toolkit unless compiling."
fi

log "AI/ML tools setup complete"
log "Next steps:"
log "  - Try 'ollama run llama3.2' to download and chat with a small local model."
log "  - In a project: 'uv init && uv add torch transformers' to start fresh."
