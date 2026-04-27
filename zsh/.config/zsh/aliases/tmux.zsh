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

# Fuzzy session picker (requires fzf)
function tms-fn {
  local session
  session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --height 40% --reverse) || return
  if [ -n "$TMUX" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

alias tm=tm-fn
alias tma='tmux attach-session -t'
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
