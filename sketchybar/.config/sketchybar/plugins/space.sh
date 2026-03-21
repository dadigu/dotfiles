#!/bin/bash

source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = true ]; then
  sketchybar --set "$NAME" background.drawing=on \
                           background.color=$BACKGROUND_2 \
                           label.color=$BLUE \
                           icon.color=$LABEL_COLOR
else
  sketchybar --set "$NAME" background.drawing=off \
                           label.color=$GREY \
                           icon.color=$GREY
fi
