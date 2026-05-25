# First-time setup: SSH keys and git identity

This guide walks through setting up SSH authentication for **GitHub**
and **Azure DevOps** on a new machine, plus how to keep your real
email addresses out of this public repo.

These steps are intentionally not scripted — they're one-time per
machine, they involve secrets, and you want to know exactly what
ends up where.

## 1. Generate SSH keys

One key per machine. Never copy private keys between machines —
generate fresh ones each time.

**You need two keys**, because GitHub and Azure DevOps don't agree on
key algorithms:

- **GitHub**: ed25519 (modern, short, fast).
- **Azure DevOps**: RSA. Microsoft's docs are explicit: *"The only
  SSH key type supported by Azure DevOps is RSA."* ed25519 is
  rejected.

### ed25519 key (for GitHub)

```bash
ssh-keygen -t ed25519 -C "<machine-label>"
```

Accept the default path (`~/.ssh/id_ed25519`).

### RSA key (for Azure DevOps)

```bash
ssh-keygen -t rsa-sha2-512 -f ~/.ssh/id_rsa_azure -C "<machine-label>-azuredevops"
```

- `-t rsa-sha2-512` selects the modern RSA signature algorithm. (`-t
  rsa` works too — same key material, different default signature.)
- `-f ~/.ssh/id_rsa_azure` keeps it separate from the ed25519 key so
  `~/.ssh/config` can route each host to the right one.

For both:
- `-C` is just a comment stored in the public key. A machine label
  (e.g. `personal-desktop`, `work-laptop`) is fine and avoids putting
  your email there. The comment is visible to anyone you share the
  public key with.
- Set a passphrase. The ssh-agent will cache it for the session so
  you only type it once per login.

## 2. Configure `~/.ssh/config`

Copy the template from this repo and adjust:

```bash
mkdir -p ~/.ssh
cp ~/dotfiles/linux/ssh/config.template ~/.ssh/config
chmod 600 ~/.ssh/config
```

The template routes GitHub to `~/.ssh/id_ed25519` and Azure DevOps to
`~/.ssh/id_rsa_azure`, with `IdentitiesOnly yes` so each host only
tries its own key (Azure DevOps will fail authentication on the first
wrong key offered — see troubleshooting below).

## 3. Add the public keys to each service

### GitHub (ed25519)

Print the ed25519 public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

1. https://github.com/settings/keys → **New SSH key**
2. Title: the machine label (e.g. `personal-desktop`)
3. Paste the public key, save
4. If your organization uses SAML SSO, click **Configure SSO** next
   to the key and authorize it for each org

Test:
```bash
ssh -T git@github.com
# Expected: "Hi <username>! You've successfully authenticated..."
```

### Azure DevOps (RSA)

Print the RSA public key:

```bash
cat ~/.ssh/id_rsa_azure.pub
```

1. Top-right user menu → **User settings** → **SSH public keys**
2. **+ New Key** → paste the public key, give it a name, save
3. Avoid leading/trailing whitespace or newlines when pasting — Azure
   DevOps is picky about this.

Note: you must repeat the upload for **each Azure DevOps organization**
you connect to (the key is scoped to one org).

Test:
```bash
ssh -T git@ssh.dev.azure.com
# Expected: a multi-line response listing your account
```

## 4. Set up git identity WITHOUT committing emails

The repo's `shared/git/gitconfig` sets `user.name` but deliberately
leaves `user.email` unset. Email and any per-machine settings live in
`~/.gitconfig.local`, which is **not** tracked by git.

Create `~/.gitconfig.local` on each machine:

```bash
cat > ~/.gitconfig.local <<'EOF'
[user]
    email = <your-email-for-this-machine>

# Optional: load a different email automatically when working in
# Azure DevOps repos. Uses git's "hasconfig" conditional include.
[includeIf "hasconfig:remote.*.url:git@ssh.dev.azure.com:**/**"]
    path = ~/.gitconfig-work
EOF
```

If you want the per-host email split, also create
`~/.gitconfig-work`:

```bash
cat > ~/.gitconfig-work <<'EOF'
[user]
    email = <your-work-email>
EOF
```

Both files live outside the repo, so your real emails never end up in
git history or on GitHub.

## 5. Hide your GitHub email in commit metadata (optional but recommended)

Even with the setup above, the email you put in `user.email` shows up
in every commit you push. For public repos, this can leak your real
email to the world.

GitHub provides a privacy email of the form:

```
<id>+<username>@users.noreply.github.com
```

Find yours at https://github.com/settings/emails (look for **Keep my
email addresses private**). Use that as your GitHub `user.email`
instead of your real one:

```ini
# ~/.gitconfig.local
[user]
    email = 12345678+yourusername@users.noreply.github.com
```

Your commits will still show up under your GitHub account, but the
real email is never exposed. You can also tick **Block command line
pushes that expose my email** on the same settings page — git will
refuse to push if you accidentally use your real email.

Azure DevOps doesn't have an equivalent privacy email, but Azure
DevOps repos aren't typically public, so it matters less.

## 6. Switching existing repos from HTTPS to SSH

If you already cloned repos over HTTPS, you don't need to re-clone:

```bash
cd path/to/repo
git remote -v                                  # check current URLs
git remote set-url origin git@github.com:<owner>/<repo>.git
# Azure DevOps format is unusual; copy the exact URL from the
# "Clone" button in the web UI (SSH tab):
git remote set-url origin git@ssh.dev.azure.com:v3/<org>/<project>/<repo>
```

## 7. ssh-agent: type your passphrase once

The `~/.ssh/config` template includes `AddKeysToAgent yes`. With
that, the first `git` command in a session prompts for your
passphrase, and subsequent commands use the cached key.

On Ubuntu with GNOME, the agent is usually running automatically. If
not, this in your `.bashrc` (or `.bashrc.local`) starts one:

```bash
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi
```

## Troubleshooting

**`Permission denied (publickey)` on first push.** The key isn't
loaded in the agent. Run `ssh-add ~/.ssh/id_ed25519` (GitHub) or
`ssh-add ~/.ssh/id_rsa_azure` (Azure DevOps).

**`Permission denied (publickey)` on Azure DevOps specifically.**
Azure DevOps rejects ed25519 — make sure you uploaded the contents of
`~/.ssh/id_rsa_azure.pub`, not `~/.ssh/id_ed25519.pub`. Also confirm
your `~/.ssh/config` has `IdentityFile ~/.ssh/id_rsa_azure` and
`IdentitiesOnly yes` under the `ssh.dev.azure.com` block — without
`IdentitiesOnly`, SSH may offer the ed25519 key first and Azure
DevOps fails immediately on the wrong key rather than trying the next
one.

**`no matching host key type found` on Azure DevOps.** Older Azure
DevOps *Server* (self-hosted) versions only served `ssh-rsa` host
keys. Modern Azure DevOps *Services* (cloud) uses `rsa-sha2-256/512`
and works with default OpenSSH 8.8+ settings. If you genuinely hit
this on a self-hosted server, add the legacy workaround:

```
Host <your-server-host>
    HostkeyAlgorithms +ssh-rsa
    PubkeyAcceptedAlgorithms +ssh-rsa
```

Do **not** add these lines for `ssh.dev.azure.com` — Microsoft's
current docs explicitly recommend removing them.

**`ssh-rsa is about to be deprecated`** warning from Azure DevOps.
You're authenticating with the legacy `ssh-rsa` signature instead of
`rsa-sha2-256/512`. Make sure your RSA key was generated with
`ssh-keygen -t rsa-sha2-512` (or use `-t rsa` on OpenSSH 8.2+ which
defaults to the sha2 signatures), and remove any `+ssh-rsa` overrides
from `~/.ssh/config`.

**GitHub says "successfully authenticated, but...".** You haven't
authorized the key for your SAML SSO organization. Go to
https://github.com/settings/keys and click **Configure SSO** next to
the key.

**Wrong email in commits.** Check what git is using:
```bash
git config user.email
```
If it's wrong, check that `~/.gitconfig.local` exists and is being
loaded — `git config --list --show-origin` will show every file git
read and which value won.
