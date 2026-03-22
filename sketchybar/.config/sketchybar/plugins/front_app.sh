#!/bin/bash

source "$CONFIG_DIR/colors.sh"

update() {
  sketchybar --set "$NAME" label="$INFO" icon="$($CONFIG_DIR/helpers/icon_map_fn.sh "$INFO")"
}

popup() {
  args=(--remove '/front_app.window\..*/')

  APP=$(sketchybar --query front_app | jq -r '.label.value')

  COUNTER=0
  while IFS=$'\t' read -r wid wtitle; do
    [ -z "$wid" ] && continue
    COUNTER=$((COUNTER + 1))

    # Truncate long titles
    if [ ${#wtitle} -gt 50 ]; then
      wtitle="${wtitle:0:47}..."
    fi

    args+=(
      --add item front_app.window.$COUNTER popup.front_app
      --set front_app.window.$COUNTER
            label="$wtitle"
            label.color="$WHITE"
            icon.drawing=off
            background.color=$TRANSPARENT
            background.border_width=0
            padding_left=4
            padding_right=4
            click_script="yabai -m window --focus $wid; sketchybar --set front_app popup.drawing=off"
    )
  done <<< "$(yabai -m query --windows | jq -r --arg app "$APP" '.[] | select(.app == $app and ."is-minimized" == false) | [.id, .title] | @tsv')"

  if [ $COUNTER -eq 0 ]; then
    args+=(
      --add item front_app.window.1 popup.front_app
      --set front_app.window.1
            label="No windows"
            label.color="$GREY"
            icon.drawing=off
            background.color=$TRANSPARENT
            background.border_width=0
    )
  fi

  sketchybar -m "${args[@]}"
  sketchybar --set front_app popup.drawing=toggle
}

case "$SENDER" in
  "front_app_switched") update ;;
  "mouse.clicked") "$CONFIG_DIR/helpers/popup_dismiss.sh" front_app; popup ;;
  "mouse.exited.global") sketchybar --set front_app popup.drawing=off ;;
esac
