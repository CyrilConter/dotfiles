# Windows setup

PowerShell 7+ configuration and tooling. Mirrors the Linux side
where it makes sense; uses winget as the package manager.

## Structure

```
windows/
├── install.ps1                Main installer (symlinks + setup scripts)
├── powershell/
│   └── profile.ps1            PowerShell profile (Starship + aliases)
└── setup/
    ├── 01-starship.ps1        Install Starship prompt
    └── 02-clis.ps1            Install GitHub CLI + Azure CLI + DevOps ext
```

The installer symlinks the shared cross-platform configs (Starship,
git, VS Code) from `shared/` into your user profile, then runs the
numbered setup scripts.

## Prerequisites

- **PowerShell 7+** (`pwsh`). Install via winget if missing:
  ```powershell
  winget install --id Microsoft.PowerShell -e
  ```
  Then close and reopen as `pwsh`, not `powershell`.

- **Symlink support.** You need either:
  - **Windows Developer Mode enabled** (Settings → For developers),
    which lets non-admin users create symlinks. This is the
    recommended path. *or*
  - Run `install.ps1` as Administrator.

- **Git for Windows** if not already installed:
  ```powershell
  winget install --id Git.Git -e
  ```

- **A Nerd Font** for Starship icons. See `fonts/README.md`.
  Recommended:
  ```powershell
  winget install --id DEVCOM.JetBrainsMonoNerdFont -e
  # or
  winget install --id sharkdp.HackNerdFont -e
  ```
  Then set your terminal (Windows Terminal etc.) font to the Nerd
  Font variant.

## Usage

```powershell
# Clone (or pull) the repo
git clone https://github.com/<your-user>/dotfiles.git $HOME\dotfiles
cd $HOME\dotfiles\windows

# Run the installer
.\install.ps1               # full install (symlinks + setup)
.\install.ps1 -NoSetup      # only symlinks, skip winget installs
.\install.ps1 -DryRun       # preview actions
```

After install, open a **new** PowerShell window. The Starship prompt
should be active and `gh` / `az` should be on your PATH.

## First-time sign-ins

```powershell
gh auth login
az login
az devops configure --defaults organization=https://dev.azure.com/<your-org> project=<your-project>
```

## Per-machine overrides (NOT committed)

| File                              | Purpose                          |
| --------------------------------- | -------------------------------- |
| `~/.gitconfig.local`              | git identity (name, email)       |
| `Documents\PowerShell\profile.local.ps1` | shell tweaks for this machine    |

The shared gitconfig deliberately omits `user.name` and
`user.email`. Create `~/.gitconfig.local` after install — see
`docs/SSH_AND_IDENTITY.md` and `docs/gitconfig.local.example`.

## What this doesn't install (intentionally)

To keep the setup minimal, this script does **not** install:

- VS Code
- Docker Desktop
- Node / Python / Rust toolchains
- WSL2

Install those manually as needed:
```powershell
winget install --id Microsoft.VisualStudioCode -e
winget install --id Docker.DockerDesktop -e
winget install --id OpenJS.NodeJS.LTS -e
winget install --id Python.Python.3.12 -e
winget install --id Rustlang.Rustup -e
```

Or, for a development-heavy workflow on Windows, consider doing dev
inside WSL2 and using these Linux dotfiles there instead — that's
the path the Linux side of this repo is built for.
