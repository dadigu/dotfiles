#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
trap 'echo "Error on line $LINENO" >&2' ERR

# Brew install helper
brew_install() {
  local -a cmd=(brew install)

  if [[ "${1:-}" == "--cask" ]]; then
    cmd+=(--cask)
    shift
  fi

  if ! "${cmd[@]}" "$@"; then
    printf 'brew install failed: %s\n' "$*" >&2
    return 0
  fi
}

# Xcode CLT
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools..."
  xcode-select --install
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
  done
fi

# Rosetta (Apple Silicon)
if [ "$(uname -m)" = "arm64" ]; then
  echo "Installing Rosetta 2..."
  softwareupdate --install-rosetta --agree-to-license || true
fi

# Git config (optional interactive)
read -r -p "Configure global git identity? [Y/n]: " gitcfg
gitcfg="${gitcfg:-Y}"

if [[ "$gitcfg" =~ ^[Yy]$ ]]; then
  read -r -p "[Git config] Enter Your Name: " gituser
  read -r -p "[Git config] Enter Your Email: " gitemail

  git config --global user.name "$gituser"
  git config --global user.email "$gitemail"
  git config --global pull.rebase false
else
  echo "Skipping git global config."
fi

# Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add Homebrew to path during setup
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)" # Apple Silicon
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)" # Intel
fi

# Update homebrew
brew update

# Tap fonts
brew tap homebrew/cask-fonts || true

fonts=(
  font-caskaydia-cove-nerd-font
  font-caskaydia-mono-nerd-font
  font-fira-code
  font-fira-code-nerd-font
  font-hack-nerd-font
  font-sf-pro
  font-space-mono-nerd-font
)

formulae=(
  bat
  btop
  diff-so-fancy
  eza
  fd
  fzf
  gh
  git-delta
  jq
  lazydocker
  lazygit
  lazysql
  neovim
  nmap
  ripgrep
  sketchybar
  starship
  stow
  tmux
  tree
  yazi
  zellij
  zoxide
  zsh-syntax-highlighting
  zsh-autosuggestions
  zsh-vi-mode
)

casks=(
  1password
  appcleaner
  beekeeper-studio
  brave-browser
  bruno
  cleanshot
  claude
  claude-code
  codex
  codex-app
  docker
  displaylink
  ferdium
  figma
  firefox
  ghostty
  google-chrome
  homerow
  imageoptim
  iterm2
  karabiner-elements
  leader-key
  linear-linear
  lunar
  logi-options-plus
  microsoft-edge
  mockoon
  nordvpn
  obsidian
  onyx
  raycast
  sf-symbols
  shortcat
  spotify
  sublime-text
  tableplus
  the-unarchiver
  visual-studio-code
  vivaldi
  vlc
  warp
  wezterm
  zed
)

echo "Install homebrew fonts"
for font in "${fonts[@]}"; do
  brew_install --cask "$font"
done

echo "Install homebrew formulas"
for f in "${formulae[@]}"; do
  brew_install "$f"
done

echo "Install homebrew casks"
for c in "${casks[@]}"; do
  brew_install --cask "$c"
done

echo "Install tapped (3rd-party) formulae..."
brew_install koekeishiya/formulae/yabai
brew_install koekeishiya/formulae/skhd

# FelixKratz tools (borders, sketchybar extras, etc.)
brew_install FelixKratz/formulae/borders
brew_install FelixKratz/formulae/sketchybar

# Oh My Posh (author-maintained tap)
brew_install jandedobbeleer/oh-my-posh/oh-my-posh

# Taproom
brew_install gromgit/brewtils/taproom

# DiffNav
brew_install dlvhdr/formulae/diffnav

# Brew clean up
brew cleanup || true

# Install nvm and node
echo "Install NVM"
mkdir -p ~/.nvm
NVM_LATEST=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_LATEST}/install.sh" | bash

# Load nvm and install latest LTS Node
echo "Install Node (latest lts)"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts

# default-writes
echo Setting default-writes...
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dadigu/dotfiles/main/setup/default-writes.sh)"

# Clone dotfiles into home directory
read -r -p "Clone dotfiles repo? [Y/n]: " answer
answer="${answer:-Y}"

if [[ "$answer" =~ ^[Yy]$ ]]; then
  read -r -p "Destination directory [~/dotfiles]: " dest
  dest="${dest:-~/dotfiles}"
  dest="${dest/#\~/$HOME}" # expand leading ~

  if [[ -e "$dest" && -n "$(ls -A "$dest" 2>/dev/null)" ]]; then
    echo "Skip: destination exists and is not empty: $dest"
  else
    mkdir -p "$(dirname "$dest")"
    git clone --recurse-submodules git@github.com:dadigu/dotfiles.git "$dest"
  fi
fi
