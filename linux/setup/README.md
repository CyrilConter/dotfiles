# linux/setup

Numbered scripts run by `linux/install.sh` in order. Each is
idempotent — safe to re-run.

| Script               | What it installs                                            |
| -------------------- | ----------------------------------------------------------- |
| `01-apt-base.sh`     | build-essential, common libs, CLI tools (ripgrep, fzf, jq…) |
| `02-dev-tools.sh`    | VS Code, GitHub CLI, Docker, nvm, rustup                    |
| `03-ai-ml.sh`        | uv (Python), Ollama (local LLMs), NVIDIA driver hint        |

## Running individual scripts

You can run any of these standalone if you only want part of the
stack:

```bash
bash linux/setup/01-apt-base.sh
```

## Adding more

Drop another numbered script in this folder
(e.g. `04-databases.sh`, `05-fonts.sh`) and `install.sh` will pick it
up automatically — it globs `[0-9]*.sh` in sorted order.
