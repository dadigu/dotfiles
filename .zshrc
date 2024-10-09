# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Path to this repo
export DOTFILES_PATH="$HOME/dotfiles"

# Configure NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Update $PATH
export PATH=$HOME/.pyenv/shims:/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/opt/mysql@5.7/bin:/opt/homebrew/sbin:$PATH

# Set default text editor
export EDITOR='nano'

# Set docker default platform
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Set path to starship's config file
export STARSHIP_CONFIG="$DOTFILES_PATH/config/starship.toml"

export DISABLE_AUTO_TITLE="true"

eval "$(starship init zsh)"

# Load alieses etc..
for conf in "$DOTFILES_PATH/zsh/"*.zsh; do
  source "${conf}"
done
unset conf

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[[ -f "$HOME/fig-export/dotfiles/dotfile.zsh" ]] && builtin source "$HOME/fig-export/dotfiles/dotfile.zsh"

# Init zsh-autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Init zsh-syntax-highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
