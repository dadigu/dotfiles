# Dotfiles & Setup

This is where I keep my dotfiles and setup scripts with my preferred apps and configurations.

```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dadigu/dotfiles/main/setup/setup.sh)"```

## GNU Stow

Use GNU stow to symlink your dotfiles with `stow <package-name>`

Available packages:
- zsh
- vim
- nvim
- wezterm
- tmux
- skhd
- yabai
- yazi

### Karabiner elements
- Run `npm install` inside /karabiner
- Run `npm run build` to generate config

## Macbook reinstall checklist

- [ ] Have you commited and pushed any changes on your Git repos?
- [ ] Have you gone over all git stashes and convert them to patch files if they're important
- [ ] Have you saved all important documents from directories that aren't synced to iCloud
- [ ] Have you backed up work from apps that don't sync via iCloud
- [ ] Have you exported critical data from your local database
- [ ] Have you backed up any important ssh keys
