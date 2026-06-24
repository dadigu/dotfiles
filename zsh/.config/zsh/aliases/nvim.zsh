# Open neovim
alias n=nvim

nn() {
  # Assumes all configs exist in directories named ~/.config/nvim-*
  local config=$(fd --max-depth 1 --glob 'nvim-*' ~/.config | fzf --prompt="Neovim Configs > " --height=~50% --layout=reverse --border --exit-0)
 
  # If I exit fzf without selecting a config, don't open Neovim
  [[ -z $config ]] && echo "No config selected" && return
 
  # Open Neovim with the selected config
  NVIM_APPNAME=$(basename $config) nvim $@
}

# fzf-pick a file (respects .gitignore) and open it in neovim, with a bat preview
nf() {
  local f
  f=$(fd --type f --hidden --exclude .git \
       | fzf --height=~50% --reverse --border \
             --preview 'bat --color=always --style=numbers --line-range=:200 {}') || return
  [[ -n $f ]] && nvim "$f"
}

# Open every file with uncommitted changes (tracked WIP + untracked) in neovim.
# Defaults to tabs (-p); pass a flag to override the layout, e.g. `ng -O`.
#
# Neovim multi-file flags worth knowing:
#   -p   one tab page per file   (default here)
#   -o   horizontal splits (stacked)
#   -O   vertical splits (side by side)
#   -d   diff mode — opens the files diffed against each other
#   +N   start on line N           e.g. `ng -O +1`
#   -R   read-only view
ng() {
  local files=("${(@f)$(git diff --name-only; git ls-files --others --exclude-standard)}")
  (( ${#files} )) || { echo "No changed files"; return }
  nvim "${@:--p}" "${files[@]}"
}

