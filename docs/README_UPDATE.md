# README update — add this section near "Per-machine overrides"

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
   `docs/gitconfig.local.example` to `~/.gitconfig.local` and edit it
3. **Nerd Font** — see [`fonts/README.md`](fonts/README.md)
