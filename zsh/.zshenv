# Set global variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export DOTFILES_PATH="$HOME/dotfiles"
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export NVM_DIR="$HOME/.nvm"
export DISABLE_AUTO_TITLE="true"
export KEYTIMEOUT=1

# Stop macOS Terminal writing .zsh_sessions/ into $ZDOTDIR (the repo).
# Must be set here in .zshenv — /etc/zshrc reads it before ~/.zshrc runs.
export SHELL_SESSIONS_DISABLE=1

# NOTE: shell history is configured in .zshrc, not here. macOS /etc/zshrc
# forcibly sets HISTFILE/HISTSIZE/SAVEHIST *after* .zshenv, so anything set
# here is silently overridden. .zshrc runs last and wins.

# Set editor
export EDITOR="nvim"
export VISUAL="nvim"

# Add user-local bin (claude and other tools install here) to PATH
export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.cargo/env"
