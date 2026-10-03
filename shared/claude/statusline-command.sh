#!/bin/bash
# Replicates the oh-my-zsh "robbyrussell" theme (ZSH_THEME in ~/.zshrc:11),
# which is what the interactive zsh prompt actually looks like:
#
#   PROMPT="%(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} ) %{$fg[cyan]%}%c%{$reset_color%}"
#   PROMPT+=' $(git_prompt_info)'
#   PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"  DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"  CLEAN="%{$fg[blue]%})"
#
# The arrow is always green: a status line has no previous exit code to test,
# so the %(?:...) conditional collapses to its success branch.

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# %c — trailing path component, or "~" when the directory is $HOME itself
if [ "$cwd" = "$HOME" ]; then
    dir="~"
else
    dir=$(basename "$cwd")
fi

printf '\033[1;32m\xe2\x9e\x9c\033[0m  \033[0;36m%s\033[0m' "$dir"

# git_prompt_info — silent outside a work tree
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
      || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

if [ -n "$branch" ]; then
    printf ' \033[1;34mgit:(\033[0;31m%s' "$branch"
    if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]; then
        printf '\033[0;34m) \033[0;33m\xe2\x9c\x97\033[0m'
    else
        printf '\033[0;34m)\033[0m'
    fi
fi
