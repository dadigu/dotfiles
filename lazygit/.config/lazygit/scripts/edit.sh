#!/usr/bin/env bash
# Open a file (passed by lazygit) in neovim.
#   - Inside tmux: float it in a popup on top of lazygit.
#   - Outside tmux: open in the current terminal (lazygit is suspended
#     because the custom command uses `output: terminal`).
set -euo pipefail

file="$1"

if [ -n "${TMUX:-}" ]; then
  # printf %q keeps filenames with spaces/quotes intact inside the -E string.
  qfile=$(printf '%q' "$file")
  tmux display-popup -w 90% -h 90% -d "$PWD" -E "nvim $qfile"
else
  nvim "$file"
fi
