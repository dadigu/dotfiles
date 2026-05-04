# Yabai aliases & helpers
#
# yabai-upgrade — upgrade yabai and refresh the SA sudoers rule in one shot
# -------------------------------------------------------------------------
# Why this exists
#   yabai's scripting addition (SA) is what lets `yabai -m window --space N`
#   actually move windows between Mission Control spaces. The startup line in
#   .yabairc is `sudo yabai --load-sa`, made passwordless via
#   /etc/sudoers.d/yabai — a rule that pins the SHA256 of the yabai binary.
#
#   Every `brew upgrade yabai` produces a new binary with a new hash, which
#   invalidates the sudoers rule. Symptom: shift+alt+1..6 silently stops
#   moving windows until the rule is regenerated and the SA reloaded.
#
#   This function does the upgrade and the regeneration together, so the
#   breakage window is zero.
#
# What it does
#   1. brew upgrade yabai
#   2. shasum -a 256 the new binary
#   3. build the new sudoers line
#   4. write it to a temp file and validate with `visudo -cf`
#      (a typo here can break sudo itself, so validation is non-negotiable)
#   5. if valid, install over /etc/sudoers.d/yabai (mode 0440, root:wheel)
#   6. sudo yabai --load-sa && yabai --restart-service
#
# Usage:  yabai-upgrade
#         (one sudo prompt for the install + SA load; rest is unprivileged)

function yabai-upgrade {
  local yabai_bin
  yabai_bin="$(command -v yabai)" || {
    echo "yabai-upgrade: yabai not found on PATH" >&2
    return 1
  }

  echo "→ brew upgrade yabai"
  brew upgrade yabai

  local sha
  sha="$(shasum -a 256 "$yabai_bin" | awk '{print $1}')"
  [[ -n "$sha" ]] || {
    echo "yabai-upgrade: failed to compute SHA256 of $yabai_bin" >&2
    return 1
  }

  local line tmpfile
  line="$(whoami) ALL=(root) NOPASSWD: sha256:${sha} ${yabai_bin} --load-sa"
  tmpfile="$(mktemp -t yabai-sudoers.XXXXXX)" || return 1
  print -r -- "$line" > "$tmpfile"

  echo "→ validating sudoers syntax"
  if ! sudo visudo -cf "$tmpfile" >/dev/null; then
    echo "yabai-upgrade: visudo validation failed; aborting (no changes made)" >&2
    rm -f "$tmpfile"
    return 1
  fi

  echo "→ installing /etc/sudoers.d/yabai"
  if ! sudo install -m 0440 -o root -g wheel "$tmpfile" /etc/sudoers.d/yabai; then
    echo "yabai-upgrade: install to /etc/sudoers.d/yabai failed" >&2
    rm -f "$tmpfile"
    return 1
  fi
  rm -f "$tmpfile"

  echo "→ reloading scripting addition"
  sudo yabai --load-sa || return 1

  echo "→ restarting yabai service"
  yabai --restart-service || return 1

  echo "✓ yabai upgraded and SA reloaded"
}
