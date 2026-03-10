# Git aliases
alias gaa='git add --all'
alias gb='git branch'
alias gc='git commit -v -m'
alias gd='git diff'
alias gp='git pull'
alias gs='git status'
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"

# Github cli aliases
alias ghd='gh dash'

# Lazygit
alias lg='lazygit'

# Replace bare git command with lazygit
git() {
    if [ "$#" -eq 0 ]; then
        lazygit  # Launch lazygit if no arguments are provided
    else
        command git "$@"  # Execute the normal git command with arguments
    fi
}
