# Open hosts file in vscode
alias edithosts="sudo code /private/etc/hosts"

# Reload Oh mt zsh
alias src='omz reload' 

# Git aliases
alias gs='git status'
alias ga='git add .'
alias gd='git diff'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias h='cd $HOME'

# Misc
alias c='clear'
alias x='exit'
alias please='sudo $(fc -ln -1)' # Rerun prev command with sudo
alias grep='grep --color' # Grep colorized
alias ls="ls --color -l -h" # ls: adding colors, verbose listign and humanize the file sizes:
alias dotfiles="code -n $DOTFILES_PATH" # Open this repo in vscode
alias kill_md="launchctl unload /Library/LaunchAgents/com.microsoft.wdav.tray.plist"

# Just for fun
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

# Docker aliases
function dnames-fn {
	for ID in `docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
	do
    	docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
	done
}

function dip-fn {
    echo "IP addresses of all named running containers"

    for DOC in `dnames-fn`
    do
        IP=`docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$DOC"`
        OUT+=$DOC'\t'$IP'\n'
    done
    echo -e $OUT | column -t
    unset OUT
}

function dlf-fn {
    container_name=$1
    tail_len=${2:-50}

    container_id=$(docker container ls -f "name=$container_name" --format "{{.ID}}")

     # Validate container existence
    if [[ -z $container_id ]]; then
        echo "Container '$container_name' does not exist."
        return 1
    fi

     # Validate tail length
    if ! [[ "$tail_len" =~ ^[1-9][0-9]*$ ]]; then
        echo "Invalid tail length: '$tail_len'. Using default value: 50"
        tail_len=50
    fi

    docker logs -f --tail="$tail_len" "$container_id"
}

function dex-fn {
	container_name=$1
    command=${2:-/bin/sh}
    docker exec -it "$container_name" "$command"
}

alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dkip=dip-fn
alias dknames=dnames-fn
alias dkex=dex-fn
alias dklf=dlf-fn
alias dktail='sh $DOTFILES_PATH/various-scripts/docker-tail.sh'
