# Path to this repo
export DOTFILES_PATH="$HOME/dotfiles"

# Configure NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Update $PATH
# export PATH=$HOME/.pyenv/shims:/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/opt/mysql@5.7/bin:/opt/homebrew/sbin:$PATH

# Set default text editor
export EDITOR='vim'

# Set docker default platform
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Set path to starship's config file
export STARSHIP_CONFIG="$DOTFILES_PATH/config/starship.toml"

export DISABLE_AUTO_TITLE="true"

# Keybindings
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# History 
HISTSIZE=5000
HISTFILE=$HOME/.zhistory
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups 
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Load alieses etc..
for conf in "$DOTFILES_PATH/zsh/"*.zsh; do
  source "${conf}"
done
unset conf

# Shell integrations
eval "$(/opt/homebrew/bin/brew shellenv)"
source <(fzf --zsh)
# eval "$(starship init zsh)"
eval "$(oh-my-posh init zsh --config $HOME/dotfiles/ohmyposh/zen.toml)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
