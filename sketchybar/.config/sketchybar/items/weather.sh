#!/bin/bash

source "$CONFIG_DIR/colors.sh"

weather=(
    icon=􀇀
    icon.font="$FONT:Bold:16.0"
    label="..."
    update_freq=1800
    popup.align=right
    script="$PLUGIN_DIR/weather.sh"
)

sketchybar --add item weather right            \
           --set weather "${weather[@]}"       \
           --subscribe weather mouse.clicked   \
                               mouse.exited.global
