# Git aliases
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit -v -m'
alias gd='git diff'
alias gp='git pull'
alias gs='git status'

# Replace bare git command with lazygit
git() {
    if [ "$#" -eq 0 ]; then
        lazygit  # Launch lazygit if no arguments are provided
    else
        command git "$@"  # Execute the normal git command with arguments
    fi
}