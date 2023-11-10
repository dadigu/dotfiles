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

# Homebrew aliases
alias bup='brew update && brew upgrade'
alias bout='brew outdated'
alias bin='brew install'
alias bun='brew uninstall'
alias bls='brew list'
alias bsr='brew search'
alias binf='brew info'
alias bidr='brew doctor'

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

# Check for file changes and run a command
# https://davidwalsh.name/git-hook-npm-install-package-json-modified
# Usage: check_run package-lock.json "npm ci"
check_run() {
    changed_files="$(git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD)"
	echo "$changed_files" | grep --quiet "$1" && eval "$2"
}

# List all running container names
function dnames-fn {
	for ID in `docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
	do
    	docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
	done
}

# Get all ip addresses from containers
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

# Tail logs on docker container by container name
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

# Exectute command inside docker container
# Defaults to logging you into container
# Usage: dex-fn <containerName> <optional: command>
function dex-fn {
	container_name=$1
    command=${2:-/bin/sh}
    docker exec -it "$container_name" "$command"
}

# Run docker tail on multiple containers and open in tmux session
docker-tail-tmux() {
    tmux new-session -d -s dockerlogs

    # Calculate the total number of containers
    num_containers=$#

    # Set the initial pane index
    pane_index=0

    # Loop through the container names and open logs in separate panes
    for container_name in "$@"; do
        # Increment the pane index
        pane_index=$((pane_index+1))

        # Create a new pane and run Docker logs
        tmux split-window -h "docker logs -f --tail=50 $container_name"

        # Rename the pane to the container name
        tmux select-pane -t $pane_index -T "$container_name"
    done

    # Close the extra empty pane
    tmux kill-pane -t 0

    # Adjust the pane sizes to evenly distribute them
    if [ $num_containers -gt 3 ]; then
        tmux select-layout tiled
    else
        tmux select-layout even-horizontal
    fi

    tmux attach-session -t dockerlogs
}


alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dkip=dip-fn
alias dknames=dnames-fn
alias dkex=dex-fn
alias dklf=dlf-fn
alias dktail=docker-tail-tmux
