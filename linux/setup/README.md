# linux/setup

Numbered scripts run by `linux/install.sh` in order. Each is
idempotent — safe to re-run.

| Script               | What it installs                                            |
| -------------------- | ----------------------------------------------------------- |
| `01-apt-base.sh`     | build-essential, common libs, CLI tools (ripgrep, fzf, jq…) |
| `02-dev-tools.sh`    | VS Code, GitHub CLI, Docker, nvm, rustup                    |
| `03-ai-ml.sh`        | NVIDIA driver (only if an NVIDIA GPU is found), uv, Ollama  |
| `04-browsers.sh`     | Firefox (Mozilla APT, not snap) and Google Chrome           |
| `05-terminal.sh`     | tmux + TPM, Ghostty (apt), herdr (agent runtime)            |
| `06-prompt.sh`       | Starship prompt (config in `shared/starship/`)              |
| `07-apps.sh`         | Extension Manager, EasyEffects, Resources, nvtop, pgAdmin 4 |
| `08-gnome.sh`        | GNOME extensions + desktop settings (`linux/gnome/*.ini`)   |
| `09-cloud-cli.sh`    | Azure CLI + `az devops` extension                           |

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
