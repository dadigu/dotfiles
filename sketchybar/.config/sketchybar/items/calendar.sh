#!/bin/bash

source "$CONFIG_DIR/colors.sh"

calendar=(
    icon=􀧞
    update_freq=30
    popup.align=right
    popup.horizontal=off
    script=$PLUGIN_DIR/calendar.sh
)

sketchybar --add item calendar right            \
           --set calendar "${calendar[@]}"       \
           --subscribe calendar mouse.clicked    \
                                mouse.exited.global
