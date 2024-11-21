#!/bin/bash

sketchybar --add item front_app left                                            \
           --set front_app       background.color=$BACKGROUND_2                 \
                                 icon.color=$ICON_COLOR                         \
                                 icon.font="sketchybar-app-font:Regular:16.0"   \
                                 label.color=$LABEL_COLOR                       \
                                 display="active"                               \
                                 script="$PLUGIN_DIR/front_app.sh"              \
           --subscribe front_app front_app_switched