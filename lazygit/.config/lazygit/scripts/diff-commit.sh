#!/usr/bin/env bash
# Open a commit's version of a file in neovim's diffview.nvim
# (before = parent commit, after = this commit) via `<hash>^!`.
#   - Inside tmux: float it in a popup on top of lazygit.
#   - Outside tmux: open in the current terminal (lazygit suspends via
#     `output: terminal`).
# Quit the diff with :tabclose or :qa.
set -euo pipefail

commit="$1"
file="$2"

# Single -c arg, kept intact through word-splitting by quoting it as one token.
launch="nvim -c $(printf '%q' "DiffviewOpen ${commit}^! -- ${file}")"

if [ -n "${TMUX:-}" ]; then
  tmux display-popup -w 90% -h 90% -d "$PWD" -E "$launch"
else
  eval "$launch"
fi
