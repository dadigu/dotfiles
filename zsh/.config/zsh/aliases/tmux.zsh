# Tmux aliases

# Create a new tmux session, optionally named: tm ['name']
# Inside tmux: creates a sibling session and switches to it (no nesting)
# Outside tmux: creates and attaches directly
function tm-fn {
  if [ -n "$TMUX" ]; then
    if [ -n "$1" ]; then
      tmux new -d -s "$1" && tmux switch-client -t "$1"
    else
      local new_session
      new_session=$(tmux new -d -P -F '#{session_name}') && tmux switch-client -t "$new_session"
    fi
  else
    [ -n "$1" ] && tmux new -s "$1" || tmux
  fi
}

# Attach to a session: tma ['name']
# With a name arg: attach directly to that session
# No arg: delegate to the picker (auto-attaches if only one session)
function tma-fn {
  if [ -n "$1" ]; then
    tmux attach-session -t "$1"
  else
    tms-fn
  fi
}

# Fuzzy session picker (requires fzf)
# No sessions: error. One session: attach/switch directly. Several: fzf picker.
function tms-fn {
  local sessions count session
  sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null) || return
  count=$(printf '%s\n' "$sessions" | grep -c .)

  if [ "$count" -eq 0 ]; then
    echo "No tmux sessions running" >&2
    return 1
  elif [ "$count" -eq 1 ]; then
    session="$sessions"
  else
    # Show name, window count, path, and attached marker; pass only the name on
    session=$(tmux list-sessions -F \
      '#{session_name}'$'\t''#{session_windows}w'$'\t''#{session_path}'$'\t''#{?session_attached,(attached),}' \
      | column -t -s $'\t' \
      | fzf --height 40% --reverse \
      | awk '{print $1}') || return
    [ -n "$session" ] || return
  fi

  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

alias tm=tm-fn
alias tma=tma-fn
alias tmls='tmux list-sessions'
alias tmn='tmux new -s'
alias tmd='tmux detach-client'
alias tms=tms-fn

# Session management
alias tmks='tmux kill-session'
alias tmdie='tmux kill-server'
alias tmrn='tmux rename-session'
alias tmsw='tmux switch-client -t'

# Window management
alias tmnw='tmux new-window'
alias tmlw='tmux list-windows'
