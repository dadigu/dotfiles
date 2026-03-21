#!/bin/bash

source "$CONFIG_DIR/colors.sh"

icon_for_volume() {
  case "$1" in
    [6-9][0-9]|100) echo "􀊩" ;;
    [3-5][0-9])     echo "􀊥" ;;
    [1-9]|[1-2][0-9]) echo "􀊡" ;;
    *)              echo "􀊣" ;;
  esac
}

set_muted() {
  sketchybar --set "$NAME" icon="􀊣" icon.color="$RED" label.drawing=off
}

set_unmuted() {
  local vol="$1"
  local icon
  icon=$(icon_for_volume "$vol")
  sketchybar --set "$NAME" icon="$icon" icon.color="$WHITE" label="$vol%" label.drawing=on
}

case "$SENDER" in
  "volume_change")
    if [ "$(osascript -e 'output muted of (get volume settings)')" = "true" ]; then
      set_muted
    else
      set_unmuted "$INFO"
    fi
    ;;
  "mouse.clicked")
    if [ "$(osascript -e 'output muted of (get volume settings)')" = "true" ]; then
      osascript -e 'set volume output muted false'
      set_unmuted "$(osascript -e 'output volume of (get volume settings)')"
    else
      osascript -e 'set volume output muted true'
      set_muted
    fi
    ;;
esac
