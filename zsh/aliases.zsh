# Open hosts file in vscode
alias edithosts="sudo code /private/etc/hosts"

# Reload Oh mt zsh
alias src='omz reload' 

# Git aliases
alias gs='git status'
alias ga='git add .'
alias gd='git diff'

# Rerun prev command with sudo
alias please='sudo $(fc -ln -1)'


# Misc
alias c='clear'
alias x='exit'
alias h='cd $HOME'
# ls: adding colors, verbose listign and humanize the file sizes:
alias ls="ls --color -l -h" 
alias dotfiles="code -n $DOTFILES_PATH" # Open this repo in vscode
alias kill_md="launchctl unload /Library/LaunchAgents/com.microsoft.wdav.tray.plist"
# Fun stuff
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