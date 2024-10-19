# Reload zshrc
alias src='source $ZDOTDIR/.zshrc' 

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Go to home folder
alias h='cd $HOME'

# Clear shell
alias c='clear'

# Exit shell
alias x='exit'

# Rerun prev command with sudo
alias please='sudo $(fc -ln -1)'

# Grep colorized
alias grep='grep --color'

# Overwrite ls with eza
alias ls='eza --icons=auto --group-directories-first'
alias la='ls --long'
alias laa='la -a'

# Kill MS Defender launch agent
alias kill_md="launchctl unload /Library/LaunchAgents/com.microsoft.wdav.tray.plist"

# Fix ssh
alias ssh-fix="ssh-add -K ~/.ssh/id_rsa"

# Output weather forecast
alias weather="curl -4 https://wttr.in/\?M"

# Improved touch - creates folder path
mtouch () {
    if [ $# -lt 1 ]; then
        echo "Missing argument";
        return 1;
    fi

    for f in "$@"; do
        mkdir -p -- "$(dirname -- "$f")"
        touch -- "$f"
    done
}

# Check for file changes and run a command
# https://davidwalsh.name/git-hook-npm-install-package-json-modified
# Usage: check_run package-lock.json "npm ci"
check_run() {
    changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"
	echo "$changed_files" | grep --quiet "$1" && eval "$2"
}