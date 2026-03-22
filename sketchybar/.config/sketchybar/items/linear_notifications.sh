#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

linear_bell=(
  update_freq=180
  icon.font="sketchybar-app-font:Regular:16.0"
  icon=$LINEAR_ICON
  icon.color=$WHITE
  label="..."
  popup.align=right
  script="$PLUGIN_DIR/linear_notifications.sh"
)

sketchybar --add item linear.bell right               \
           --set linear.bell "${linear_bell[@]}"      \
           --subscribe linear.bell mouse.clicked      \
                                   mouse.exited.global
