#!/usr/bin/env bash
APP="$HOME/Development/Learningbank/app"

sel=$(cd "$APP/repo" && git worktree list | awk '{print $1}' | while read -r p; do
  printf "%s\t%s\n" "${p#$APP/}" "$p"
done | fzf --reverse --header="Select worktree" --with-nth=1 --delimiter=$'\t')

[ -z "$sel" ] && exit 0

dir=$(echo "$sel" | cut -f2)
name=$(echo "$sel" | cut -f1)

tmux new-window -n "app: $name" -c "$dir" \; \
  split-window -h -p 40 -c "$dir" \; \
  split-window -v -c "$dir" \; \
  select-pane -t 1
