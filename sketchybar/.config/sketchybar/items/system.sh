#!/bin/bash

source "$CONFIG_DIR/colors.sh"

cpu=(
    icon=􀧓
    update_freq=15
    popup.align=right
    script="$PLUGIN_DIR/system.sh"
    label.font="$FONT:Semibold:14.0"
    padding_right=0
)

ram=(
    icon=􀫦
    popup.align=right
    script="$PLUGIN_DIR/system.sh"
    label.font="$FONT:Semibold:14.0"
    padding_left=0
)

sketchybar --add item cpu right                \
           --set cpu "${cpu[@]}"               \
           --subscribe cpu mouse.clicked       \
                           mouse.exited.global \
           --add item ram right                \
           --set ram "${ram[@]}"               \
           --subscribe ram mouse.clicked       \
                           mouse.exited.global
