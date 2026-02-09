# Dotfiles & Setup

Personal dotfiles + bootstrap scripts for setting up a new macOS machine with my preferred apps and configs.

## Quick install (bootstrap)

Run the setup script:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/dadigu/dotfiles/main/setup/init.sh)"
```

### Review before running (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/dadigu/dotfiles/main/setup/init.sh | less
```

> Note: This script installs software, applies macOS defaults, and may prompt for input. Some changes require a logout/restart and some apps require manual privacy approvals.

## GNU Stow

I use GNU Stow to symlink dotfiles:

```bash
cd ~/dotfiles
stow <package-name>
```

Useful commands:

* Dry run (see what would happen):
    ```bash
    stow --no --verbose=2 <package-name>
    ```
* Restow (apply changes to an already-stowed package):
    ```bash
    stow --restow <package-name>
    ```
* Unstow:
    ```bash
    stow --delete <package-name>
    ```

### Available packages

* aerospace
* ghostty
* lazygit
* leader-key[^1]
* nvim
* sketchybar
* skhd
* tmux
* vim
* wezterm
* yabai
* yazi
* zellij
* zsh

[^1]: Change config directory to `~/.config/leader-key` in app settings

## Post-install manual steps (macOS)

Some things can’t (or shouldn’t) be fully automated:

* **yabai / skhd**
    * System Settings → Privacy & Security → **Accessibility**
    * Enable for the relevant binaries/apps you use to launch them (Terminal/iTerm2, yabai, skhd).
* **Docker Desktop**
    * Launch Docker Desktop once to complete setup.
* **Login/setup apps**
    * 1Password, Raycast/Alfred, VPN, browsers, etc.

## Karabiner-Elements

If you use the Karabiner config in this repo:

```bash
cd karabiner
npm install
npm run build
```

## Macbook reinstall checklist

* [ ] Commit and push changes in all Git repos
* [ ] Review Git stashes and convert important ones to patch files
* [ ] Backup important documents not synced to iCloud/Drive
* [ ] Backup app data that doesn’t sync automatically
* [ ] Export critical data from local databases
* [ ] Backup SSH keys (`~/.ssh`) and config (`~/.ssh/config`)
* [ ] Backup GPG keys (if used)
* [ ] Confirm 2FA/authenticator backups (if applicable)
* [ ] Verify password manager vault is fully synced
* [ ] Note down/licenses for paid apps (if not account-based)

## Troubleshooting

### Homebrew installed but `brew` not found
Open a new terminal session, or run:

```bash
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
```

### Stow conflicts / “existing file” errors
Preview first:

```bash
stow --no --verbose=2 <package-name>
```

Then move/backup conflicting files and re-run `stow`.
