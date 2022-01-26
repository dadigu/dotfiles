#!/usr/bin/env sh
# Install Xcode developer command line tool
if test ! $(which xcode-select); then
    echo "Installing Xcode Developer Command Line Tool..."
    xcode-select --install
fi

# Install Rosetta 2
if [[ "`pkgutil --files com.apple.pkg.RosettaUpdateAuto`" == "" ]]; then 
	echo "Installing Rosetta..."
    softwareupdate --install-rosetta
fi

# Setup gitconfig
echo "[Git config] Enter Your Name: "
read gituser
echo "[Git config] Enter Your Email: "
read gitemail
git config --global user.name "$gituser"
git config --global user.email "$gitemail"
# Fix issue when installing homebrew
# @see https://programmerah.com/solved-mac-install-homebrew-error-error-not-a-valid-ref-refs-remotes-origin-master-44606/
git config --global core.compression 0
git config --global http.postBuffer 1048576000

echo Installing Homebrew...
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH=/opt/homebrew/bin:$PATH
brew update

echo Adding homebrew taps...
brew tap homebrew/cask
brew tap homebrew/cask-fonts
brew tap homebrew/core
brew tap homebrew/services

echo Install fonts...
brew install font-fira-code
brew install font-hack-nerd-font

echo Installing basic homebrew softwares...
brew install redis
brew install tmux
brew install tmuxinator
brew install node
brew install npm
brew install php
brew install mysql@5.7
brew install python
brew install speedtest-cli
brew install zsh
brew install starship

# apps
echo Installing desktop apps...
brew install --cask figma
brew install --cask drawio
brew install --cask firefox
brew install --cask google-chrome
brew install --cask microsoft-edge
brew install --cask sublime-text
brew install --cask visual-studio-code
brew install --cask spotify
brew install --cask vlc
brew install --cask alfred
brew install --cask imageoptim
brew install --cask microsoft-teams
brew install --cask ferdi
brew install --cask fork
brew install --cask iterm2
brew install --cask postman
brew install --cask tableplus
brew install --cask 1password
brew install --cask appcleaner
brew install --cask the-unarchiver
brew install --cask nordvpn

# Brew clean up
brew update && brew upgrade && brew cleanup

# default-writes
echo Setting default-writes...
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dadigu/dotfiles/main/default-writes.sh)"

# oh-my-zsh
echo Installing Oh-my-zsh...
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# To upgrade all softwares installed by cask later, just run this below command:
# brew upgrade --cask --greedy
