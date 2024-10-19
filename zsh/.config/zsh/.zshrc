
# +----------+
# Keybindings
# +----------+
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward


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