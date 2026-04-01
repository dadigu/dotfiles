#!/usr/bin/env bash
# Keybinding lookup for tmux - shows all bindings via fzf
# Custom bindings (marked with * in -N descriptions) are shown first in yellow

tmux list-keys -N \
  | sed -e 's/C-Space/[Prefix]/' -e 's/^        /  [Root] /' \
  | awk '
    /  \*/ { custom = custom "\033[33m" $0 "\033[0m\n"; next }
           { defaults = defaults $0 "\n" }
    END    { printf "%s%s", custom, defaults }
  ' \
  | fzf --ansi --reverse --header 'Tmux Keybindings (* = custom)' --no-info
