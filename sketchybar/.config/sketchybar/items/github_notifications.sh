#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

github_bell=(
  update_freq=180
  icon.font="sketchybar-app-font:Regular:16.0"
  icon=$GITHUB_ICON
  icon.color=$WHITE
  label="..."
  popup.align=right
  script="$PLUGIN_DIR/github_notifications.sh"
)

sketchybar --add item github.bell right                 \
           --set github.bell "${github_bell[@]}"        \
           --subscribe github.bell mouse.clicked        \
                                   mouse.exited.global
