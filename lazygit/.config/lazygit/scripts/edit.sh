#!/usr/bin/env bash
# Open a file (passed by lazygit) in neovim.
#   - Inside tmux: float it in a popup on top of lazygit.
#   - Outside tmux: open in the current terminal (lazygit is suspended
#     because the custom command uses `output: terminal`).
set -euo pipefail

file="$1"

# Jump to the first changed line so you land on the diff, not line 1.
# Check the unstaged diff first, then the staged (index) diff; fall back to 1.
first_changed_line() {
  local diff
  diff=$(git diff -U0 -- "$file" 2>/dev/null)
  [ -n "$diff" ] || diff=$(git diff --cached -U0 -- "$file" 2>/dev/null)
  # `|| true` so a no-match grep (e.g. untracked file) doesn't trip `set -e`.
  printf '%s\n' "$diff" | grep -m1 '^@@' | sed -E 's/.*\+([0-9]+).*/\1/' || true
}
line=$(first_changed_line || true)
line=${line:-1}

# printf %q keeps filenames with spaces/quotes intact inside the -E string.
qfile=$(printf '%q' "$file")

if [ -n "${TMUX:-}" ]; then
  tmux display-popup -w 90% -h 90% -d "$PWD" -T " $file " -E "nvim +${line} $qfile"
else
  nvim "+${line}" "$file"
fi
