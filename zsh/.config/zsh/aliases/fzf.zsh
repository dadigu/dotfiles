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

alias ag=fzfalias

