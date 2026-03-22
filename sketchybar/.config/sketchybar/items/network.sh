#!/bin/bash

source "$CONFIG_DIR/colors.sh"

network=(
    icon=􀙇
    update_freq=30
    popup.align=right
    script="$PLUGIN_DIR/network.sh"
    label.drawing=off
)

sketchybar --add item network right              \
           --set network "${network[@]}"         \
           --subscribe network wifi_change       \
                               system_woke       \
                               mouse.clicked     \
                               mouse.exited.global
