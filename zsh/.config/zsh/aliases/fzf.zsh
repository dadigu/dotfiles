_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}


# alias ag="alias | awk -F= '{ gsub(/'\''/, \"\", \$2); gsub(/\"/, \"\", \$2); printf \"%s\t\t%s\n\", \$1, \$2 }' | fzf"


# Fuzzy search aliases and pasting alias to prompt on selection
fzfalias() {
    # Use fzf to select an alias, showing both the alias name and command
    local selected
    selected=$(alias | \
        awk -F'=' '{gsub(/'\''/, ""); gsub(/"/, ""); print $1 "\t" $2}' | \
        fzf --delimiter="\t" --with-nth=1,2 --height=50%)
    if [[ -n $selected ]]; then
        # Extract the alias name, splitting on the tab character
        local alias_name="${selected%%$'\t'*}"  # This gets the alias name before the tab
        # Insert the alias name into the command line using print -z
        print -z -- "$alias_name"
    fi
}

skhd_fzf_cheatsheet() {
  local len
  len=$(awk '
    function clean(s) { gsub(/\t+/, " ", s); gsub(/[[:space:]]+/, " ", s); gsub(/^ +| +$/, "", s); return s }
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
    /^[^#].*:/ { split($0, a, ":"); s=clean(a[1]); if(length(s)>l) l=length(s) }
    END { print l }' ~/.skhdrc)

  awk -v slen="$len" '
    function clean(s) { gsub(/\t+/, " ", s); gsub(/[[:space:]]+/, " ", s); gsub(/^ +| +$/, "", s); return s }
    /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
    /^[^#].*:/ {
      if(inblock) printf("%-*s  %s\n", slen, shortcut, clean(action))
      split($0, a, ":"); shortcut=clean(a[1]); action=clean(substr($0, index($0, ":")+1)); inblock=1
      if(action ~ /\\$/) action=substr(action,1,length(action)-1)
      else { printf("%-*s  %s\n", slen, shortcut, clean(action)); inblock=0 }
      next
    }
    inblock {
      line=clean($0)
      if(line !~ /^#/) {
        if(line ~ /\\$/) action=action " " substr(line,1,length(line)-1)
        else { action=action " " line; printf("%-*s  %s\n", slen, shortcut, clean(action)); inblock=0 }
      }
    }
    END { if(inblock) printf("%-*s  %s\n", slen, shortcut, clean(action)) }
  ' ~/.skhdrc | fzf
}

alias ag=fzfalias
alias skhdkeys="skhd_fzf_cheatsheet"

## Cheatsheet command
cs() {
  local -a items=(
    "skhd|Show skhd shortcuts|skhd_fzf_cheatsheet"
    "alias|List all aliases|fzfalias"
    # Add more here
  )

  local selection=$(printf '%s\n' "${items[@]}" | awk -F'|' '{printf "%-10s %s\n", $1, $2}' |
    fzf --height="~40%" --layout=reverse --prompt="Choose: " --border)

  [[ -z "$selection" ]] && return

  local selkey="${selection%% *}"
  local fn
  for item in "${items[@]}"; do
    [[ "${item%%|*}" = "$selkey" ]] && fn="${item##*|}" && break
  done

  [[ -n "$fn" && $(type -w "$fn") ]] && "$fn" || echo "No handler for $selkey"
}

