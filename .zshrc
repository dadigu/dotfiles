# Path to this repo
export DOTFILES_PATH="$HOME/dotfiles"

# Configure NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Update $PATH
export PATH=$HOME/.pyenv/shims:/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/opt/mysql@5.7/bin:/opt/homebrew/sbin:$PATH

# Set default text editor
export EDITOR='nano'

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set docker default platform
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Set path to starship's config file
export STARSHIP_CONFIG="$DOTFILES_PATH/starship.toml"

export DISABLE_AUTO_TITLE="true"

# Ohmyzsh Custom folder
ZSH_CUSTOM="$DOTFILES_PATH"/zsh-custom

# ZSH plugins
plugins=(
  git
  gitfast
  npm
  common-aliases
  zsh-autosuggestions
  zsh-syntax-highlighting
  macos
  # vscode
  # npm
  # osx
  # common-aliases
)

source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"

# Load alieses etc..
for conf in "$DOTFILES_PATH/zsh/"*.zsh; do
  source "${conf}"
done
unset conf
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
