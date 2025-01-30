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
zmodload zsh/complist
# +----------+
# Keybindings
# +----------+
# Up and down to search history
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
# Accept auto suggestion [shift+tab]
bindkey '^[[Z' autosuggest-accept 
# use the vi navigation keys in menu completion
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

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
eval "$(zoxide init zsh --cmd cd)" # Load zoxide
source <(fzf --zsh) # Load fzf
eval "$(oh-my-posh init zsh --config $ZDOTDIR/omp-zen.toml)" # Load prompt
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh # Load zsh-autosuggestions
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # Load zsh-syntax-highlighting
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh # Load zsh-vi-mode
