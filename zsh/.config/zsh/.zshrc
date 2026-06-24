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
setopt hist_reduce_blanks

# +----------------+
# Shell history
# +----------------+
# Set here (not .zshenv): macOS /etc/zshrc overrides HISTFILE/HISTSIZE/SAVEHIST
# after .zshenv, so .zshrc is the only place these reliably stick.
# History is *state*, so it lives in XDG_STATE_HOME, outside the dotfiles repo.
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
export HISTDUP=erase                    # Erases duplicates from history.

# +-----------------+
# Completion styling
# +-----------------+
# Initialize completion with the dump cached outside the repo (it's a cache,
# not config). Without an explicit -d it lands in $ZDOTDIR and pollutes git.
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
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
# eval "$(oh-my-posh init zsh --config $ZDOTDIR/omp-zen.toml)" # Load prompt
eval "$(starship init zsh)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh # Load zsh-autosuggestions
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # Load zsh-syntax-highlighting
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh # Load zsh-vi-mode
