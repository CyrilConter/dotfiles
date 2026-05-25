# Fonts

The Starship prompt (used on both Linux and Windows) and the VS Code
settings reference a **Nerd Font** — Hack on Linux, Hack or
JetBrainsMono on Windows.

## Install

### Linux (Ubuntu)

```bash
mkdir -p ~/.local/share/fonts
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip
unzip Hack.zip -d ~/.local/share/fonts/Hack
fc-cache -fv
```

Then set your terminal/VS Code font to `Hack Nerd Font`.

### Windows

Download from [nerdfonts.com](https://www.nerdfonts.com), unzip, then
right-click the `.ttf` files → *Install for all users*.

Then set your terminal (Windows Terminal, etc.) font to
`Hack Nerd Font`.
