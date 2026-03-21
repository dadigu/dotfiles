#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

github_bell=(
  update_freq=180
  icon.font="$FONT:Bold:15.0"
  icon=$BELL
  icon.color=$BLUE
  label=$LOADING
  label.highlight_color=$BLUE
  popup.align=right
  script="$PLUGIN_DIR/github_notifications.sh"
)

sketchybar --add item github.bell right                 \
           --set github.bell "${github_bell[@]}"        \
           --subscribe github.bell mouse.clicked        \
                                   mouse.exited.global
