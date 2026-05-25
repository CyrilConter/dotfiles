# dotfiles

Personal dotfiles and machine setup scripts for **Windows** and **Linux (Ubuntu)**.

## Repository layout

```
.
├── windows/          Windows-specific configs and installer
│   ├── install.ps1
│   ├── powershell/   PowerShell profile + Starship loader
│   └── setup/        Numbered scripts to install tooling (winget)
├── linux/            Linux-specific configs and installer
│   ├── install.sh
│   ├── bash/         bash configuration
│   ├── zsh/          zsh configuration (optional)
│   ├── bin/          personal scripts symlinked into ~/.local/bin
│   ├── git/          Linux-specific git tweaks (if any)
│   ├── ssh/          ~/.ssh/config template
│   ├── tmux/         tmux configuration
│   ├── vscode/       Linux-specific VS Code settings (if any)
│   └── setup/        Numbered scripts to install dev tooling
├── shared/           Cross-platform configs (used on both)
│   ├── git/          gitconfig
│   ├── starship/     Starship prompt config (bash/zsh/pwsh)
│   └── vscode/       VS Code settings.json, keybindings.json
├── docs/             First-time setup notes (SSH, identity)
└── fonts/            Notes on fonts (Hack Nerd Font, etc.)
```

The `shared/` directory holds anything that works identically on both
systems. The OS-specific folders only contain things that genuinely
differ (shells, package managers, paths).

## Usage

### Windows

```powershell
git clone https://github.com/CyrilConter/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles\windows
.\install.ps1
```

You'll also need to install a **Nerd Font** (Hack or JetBrainsMono)
manually — see [`fonts/README.md`](fonts/README.md).

The PowerShell prompt is **Starship**, configured cross-platform from
[`shared/starship/starship.toml`](shared/starship/starship.toml).

### Linux (Ubuntu 24.04+)

```bash
sudo apt update && sudo apt install -y git
git clone https://github.com/CyrilConter/dotfiles.git ~/dotfiles
cd ~/dotfiles/linux
./install.sh
```

The installer will:

1. Symlink config files from this repo into `$HOME`
2. Run the numbered scripts in `linux/setup/` to install dev tooling
   (build-essential, VS Code, Docker, uv, etc.)

You can run individual setup scripts instead of the full installer if
you only want part of the stack. See `linux/setup/README.md`.

## Per-machine overrides

For settings that differ between work laptop and personal desktop
(git email, signing keys, machine-specific tools), use a local file
that is **not** committed:

- Git: `~/.gitconfig.local` — included automatically by the shared
  gitconfig.
- Shell: `~/.bashrc.local` — sourced at the end of `.bashrc` if
  present.

Drop sensitive or machine-specific values there. They will not be
tracked by git.

## Privacy: keeping personal data out of this public repo

This repo is public. Nothing in it should contain:

- Your real email addresses
- Your real name (optional — name *is* public on GitHub commits, but
  keeping it out of the repo keeps the template reusable)
- API keys, tokens, SSH keys, or credentials of any kind
- Internal hostnames, project names, or company-specific URLs

All of those live in **local override files** that are deliberately
not tracked:

| File                       | Purpose                                |
| -------------------------- | -------------------------------------- |
| `~/.gitconfig.local`       | git identity (name, email, signing)    |
| `~/.gitconfig-work`        | work-specific git overrides (optional) |
| `~/.bashrc.local`          | shell tweaks specific to one machine   |
| `~/.ssh/config` (per host) | SSH connection settings                |

The `.gitignore` at the repo root also blocks `*.local`, `*.secret`,
and `.env*` as belt-and-braces.

## First-time setup on a new machine

After running `./linux/install.sh`, you'll have all the configs
symlinked but no identity set. To finish setup:

1. **SSH keys and git identity** — see
   [`docs/SSH_AND_IDENTITY.md`](docs/SSH_AND_IDENTITY.md)
2. **Local git config** — copy
   [`docs/gitconfig.local.example`](docs/gitconfig.local.example) to
   `~/.gitconfig.local` and edit it
3. **Nerd Font** — see [`fonts/README.md`](fonts/README.md)

## Fonts

See [`fonts/README.md`](fonts/README.md).
