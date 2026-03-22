#!/bin/bash

# Close all popups except the one passed as $1
EXCLUDE="$1"

args=()
while read -r item; do
  [ "$item" = "$EXCLUDE" ] && continue
  args+=(--set "$item" popup.drawing=off)
done <<< "$(sketchybar --query bar | jq -r '.items[]')"

[ ${#args[@]} -gt 0 ] && sketchybar -m "${args[@]}" 2>/dev/null
