# dotfiles

Personal dotfiles and machine setup scripts for **Windows** and **Linux (Ubuntu)**.

## Repository layout

```
.
├── windows/          Windows-specific configs and installer
│   ├── install.ps1
│   └── powershell/   PowerShell + Oh My Posh configuration
├── linux/            Linux-specific configs and installer
│   ├── install.sh
│   ├── bash/         bash configuration
│   ├── zsh/          zsh configuration (optional)
│   ├── git/          Linux-specific git tweaks (if any)
│   ├── vscode/       Linux-specific VS Code settings (if any)
│   └── setup/        Numbered scripts to install dev tooling
├── shared/           Cross-platform configs (used on both)
│   ├── git/          gitconfig
│   └── vscode/       VS Code settings.json, keybindings.json
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

You'll also need to install **Hack Nerd Font** manually from
[nerdfonts.com](https://www.nerdfonts.com).

PowerShell prompt setup is based on
[this video](https://youtu.be/5-aK2_WwrmM) (Oh My Posh on Windows 11).

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

## Fonts

See [`fonts/README.md`](fonts/README.md).
