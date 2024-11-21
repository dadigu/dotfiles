#!/bin/sh

# The $SELECTED variable is available for space components and indicates if
# the space invoking this script (with name: $NAME) is currently selected:
# https://felixkratz.github.io/SketchyBar/config/components#space----associate-mission-control-spaces-with-an-item

source "$CONFIG_DIR/colors.sh" # Loads all defined colors

if [ $SELECTED = true ]; then
  sketchybar --set $NAME background.drawing=on \
                         background.color=$BACKGROUND_2 \
                         label.color=$BLUE \
                         icon.color=$LABEL_COLOR
else
  sketchybar --set $NAME background.drawing=off \
                         label.color=$GREY \
                         icon.color=$GREY
fi