# Path to this repo
export DOTFILES_PATH="$HOME/dotfiles"

# Configure NVM
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Update $PATH
export PATH=$HOME/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/opt/mysql@5.7/bin:/opt/homebrew/sbin:$PATH

# Set default text editor
export EDITOR='vim'

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set path to starship's config file
export STARSHIP_CONFIG="$DOTFILES_PATH/starship.toml"

DISABLE_AUTO_TITLE="true"

# Ohmyzsh Custom folder
ZSH_CUSTOM="$DOTFILES_PATH"/zsh-custom

# ZSH plugins
plugins=(
  git
  npm
  common-aliases
  zsh-autosuggestions
  zsh-syntax-highlighting
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