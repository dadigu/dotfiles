_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

# alias ag='alias | awk -F= '\''{ printf "%s\t%s\n", $1, $2 }'\'' | fzf'

# Fuzzy search aliases
alias ag="alias | awk -F= '{ gsub(/'\''/, \"\", \$2); gsub(/\"/, \"\", \$2); printf \"%s\t\t%s\n\", \$1, \$2 }' | fzf"

# alias fzf_aliases="alias | awk -F= '{ gsub(/'\''/, \"\", \$2); gsub(/\"/, \"\", \$2); printf \"%s\t%s\n\", \$1, \$2 }' | fzf --height 40% --preview 'echo {} | awk -F= '\''{ print \$2 }'\'' | bat --style=numbers --color=always --paging=always'"
