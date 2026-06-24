#!/usr/bin/env bash
# Switch to another tmux session via fzf (excludes the current one).
current=$(tmux display-message -p '#S')
target=$(tmux list-sessions -F '#S' | grep -vx "$current" | fzf --reverse --header 'Switch session')
[ -n "$target" ] && tmux switch-client -t "$target"
