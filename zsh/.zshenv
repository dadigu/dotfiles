# Set global variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export DOTFILES_PATH="$HOME/dotfiles"
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export NVM_DIR="$HOME/.nvm"
export DISABLE_AUTO_TITLE="true"

# Configure shell history
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file
export HISTDUP=erase                    # Erases duplicates from history.

# Set editor
export EDITOR="nvim"
export VISUAL="nvim"

