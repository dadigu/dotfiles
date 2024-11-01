#!/usr/bin/env sh

# Install Xcode developer command line tool
if test ! $(which xcode-select); then
    echo "Installing Xcode Developer Command Line Tool..."
    xcode-select --install
fi

# Install Rosetta 2
if [[ `uname -m` == 'arm64' ]]; then
    echo "Installing Rosetta 2..."
    softwareupdate --install-rosetta --agree-to-license
fi

# Setup gitconfig
echo "[Git config] Enter Your Name: "
read gituser
echo "[Git config] Enter Your Email: "
read gitemail
git config --global user.name "$gituser"
git config --global user.email "$gitemail"
git config --global pull.rebase false
git config --global init.defaultBranch master
# Fix issue when installing homebrew
# @see https://programmerah.com/solved-mac-install-homebrew-error-error-not-a-valid-ref-refs-remotes-origin-master-44606/
git config --global core.compression 0
git config --global http.postBuffer 1048576000

# Check for homebrew, install if you don't have it
if test ! $(which brew); then
    echo Installing Homebrew...
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add homebrew into $PATH
export PATH=/opt/homebrew/bin:$PATH

# Update homebrew
brew update

echo Adding homebrew taps...
brew tap homebrew/cask
brew tap homebrew/cask-fonts
brew tap homebrew/core
brew tap homebrew/services

echo Install fonts...
brew install font-fira-code
brew install font-fira-code-nerd-font
brew install font-hack-nerd-font
brew install font-sf-pro

echo Installing basic homebrew softwares...
brew install bat
brew install btop
brew install eza
brew install font-sf-pro
brew install fzf
brew install gh
brew install jq
brew install lazygit
brew install neovim
brew install nvm
brew install ripgrep
brew install speedtest-cli
brew install sketchybar
brew install starship
brew install stow
brew install tmux
brew install yazi
brew install zsh
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions
brew install zsh-vi-mode

# window manager
brew install koekeishiya/formulae/yabai
brew install koekeishiya/formulae/skhd

# prompt
brew install jandedobbeleer/oh-my-posh/oh-my-posh

# apps
echo Installing desktop apps...
brew install --cask 1password
brew install --cask alfred
brew install --cask appcleaner
brew install --cask brave-browser
brew install --cask cleanshot
brew install --cask docker
brew install --cask ferdium
brew install --cask figma
brew install --cask firefox
brew install --cask fork
brew install --cask google-chrome
brew install --cask imageoptim
brew install --cask iterm2
brew install --cask karabiner-elements
brew install --cask logi-options-plus
brew install --cask microsoft-edge
brew install --cask mockoon
brew install --cask nordvpn
brew install --cask obsidian
brew install --cask onyx
brew install --cask postman
brew install --cask raycast
brew install --cask sf-symbols
brew install --cask shottr
brew instakk --cask superkey
brew install --cask spotify
brew install --cask sublime-text
brew install --cask tableplus
brew install --cask the-unarchiver
brew install --cask visual-studio-code
brew install --cask vlc
brew install --cask warp
brew install --cask wezterm
brew install --cask zed

# Brew clean up
brew update && brew upgrade && brew cleanup

# default-writes
echo Setting default-writes...
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dadigu/dotfiles/main/setup/default-writes.sh)"

# oh-my-zsh
# echo Installing Oh-my-zsh...
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# To upgrade all softwares installed by cask later, just run this below command:
# brew upgrade --cask --greedy

# Finally we clone this repository into our home folder
git clone --recurse-submodules git@github.com:dadigu/dotfiles.git ~/dotfiles

# Run symlinking for various dotfiles included in the repo
sh ~/dotfiles/setup/symlink.sh
