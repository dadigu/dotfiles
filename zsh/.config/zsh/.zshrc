autoload edit-command-line; zle -N edit-command-line

# +----------+
# Keybindings
# +----------+
# Enable vim mode
# bindkey -v
# Bind v while in vim mode to edit promt with $EDITOR
# bindkey -M vicmd v edit-command-line
# Up and down to search history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
# Fix backspace bug when switching modes
# bindkey "^?" backward-delete-char

# Change cursor shape for different vi modes.
# https://unix.stackexchange.com/questions/433273/changing-cursor-style-based-on-mode-in-both-zsh-and-vim
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]] ||
#      [[ $1 = 'block' ]]; then
#     echo -ne '\e[2 q'
#   elif [[ ${KEYMAP} == main ]] ||
#        [[ ${KEYMAP} == viins ]] ||
#        [[ ${KEYMAP} = '' ]] ||
#        [[ $1 = 'beam' ]]; then
#     echo -ne '\e[6 q'
#   fi
# }
# zle -N zle-keymap-select
# echo -ne '\e[6 q' # Use beam shape cursor on startup.

# +----------------+
# Set shell options
# +----------------+
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups 
setopt hist_ignore_dups
setopt hist_find_no_dups

# +-----------------+
# Completion styling
# +-----------------+
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':completion:*' menu select

# +-------------+
# Source aliases
# +-------------+
for conf in "$ZDOTDIR/aliases/"*.zsh; do
  source "${conf}"
done
unset conf


# +-----------------+
# Shell integrations
# +-----------------+
eval "$(/opt/homebrew/bin/brew shellenv)" # Load homebrew
source <(fzf --zsh) # Load fzf
eval "$(oh-my-posh init zsh --config $ZDOTDIR/omp-zen.toml)" # Load prompt
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh # Load zsh-autosuggestions
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # Load zsh-syntax-highlighting
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh # Load zsh-vi-mode