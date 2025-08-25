# List all running container names
function dkn-fn {
	for ID in `docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
	do
    	docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
	done
}

# Get all ip addresses from containers
function dkip-fn {
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
#
# Usage: dklf <container_name> <optional: tail_length>
function dklf-fn {
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

# Execute command inside docker container
# Defaults to logging you into container
# Usage: dex-fn <containerName> <optional: command>
function dkex-fn {
    container_name=$1
    shift  # Remove the first argument, which is the container name
    if [ "$#" -eq 0 ]; then
        # No command provided, default to shell
        docker exec -it "$container_name" /bin/sh
    else
        # Command provided, execute it through a shell
        docker exec -it "$container_name" /bin/sh -c "$*"
    fi
}

# Output all running containers port numbers
function dkpo-fn {
  printf "%-20s\t%s\n" "CONTAINER" "HOST PORTS"
  docker ps --format "{{.Names}}\t{{.Ports}}" | while IFS=$'\t' read -r name ports; do
    host_ports=$(echo "$ports" | grep -oE '[0-9]+->[0-9]+' | awk -F'->' '{print $1}' | paste -sd "," -)
    printf "%-20s\t%s\n" "$name:" "$host_ports"
  done
}

# Run docker tail on multiple containers and open in tmux session
dktail-fn() {
    if [ $# -eq 0 ]; then
        echo "Usage: dktmt-fn container1 [container2 ...]"
        return 1
    fi

    local session="dockerlogs"
    local first="$1"
    shift

    # Create session with the first container running in the initial (active) pane
    tmux new-session -d -s "$session" "docker logs -f --tail=50 $first"

    # Select the current window in that session and title the active pane
    tmux select-window -t "${session}:."
    tmux select-pane -t "${session}:" -T "$first"

    # Add remaining containers
    for name in "$@"; do
        tmux split-window -t "$session:" -h "docker logs -f --tail=50 $name"
        # After split, the new pane is active; title the active pane
        tmux select-pane -t "$session:" -T "$name"
        tmux select-layout -t "$session:" even-horizontal
    done

    # Final layout
    if [ $# -ge 3 ]; then
        tmux select-layout -t "$session:" tiled
    else
        tmux select-layout -t "$session:" even-horizontal
    fi

    if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session"
    else
        tmux attach-session -t "$session"
    fi
}

alias dk=oxker
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dkip=dkip-fn
alias dkn=dkn-fn
alias dkex=dkex-fn
alias dklf=dklf-fn
alias dktail=dktail-fn
alias dkst='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
alias dkpo=dkpo-fn
