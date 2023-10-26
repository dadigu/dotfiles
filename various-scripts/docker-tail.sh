#!/bin/bash

# Get the current timestamp
timestamp=$(date +%s)

# Array of random color codes
color_codes=("196" "46" "226" "21" "201" "51" "198" "129" "87")

# Loop through each specified container name and run 'docker logs' to tail the stdout
for container_name in "$@"; do
  container_id=$(docker ps -qf "name=$container_name")
  
  if [[ -z "$container_id" ]]; then
    echo "Container not found: $container_name"
  else
    # Select a random color code
    color_code="${color_codes[$RANDOM % ${#color_codes[@]}]}"

    # Display the container name with a colored prefix and container ID
    printf "\033[38;5;%smTailing logs for container: %s - %s\033[0m\n" "$color_code" "$container_name" "$container_id"

    # Tail the logs and prepend each log message with the colored container name prefix
    docker logs --since "$timestamp" -f "$container_id" | awk -v name="$container_name" -v color_code="$color_code" '{print "\033[38;5;" color_code "m" name " | " "\033[0m" $0}' &
  fi
done

# Wait for the interrupt signal (Ctrl + C)
trap 'kill $(jobs -p)' SIGINT
wait


