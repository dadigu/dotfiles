#!/bin/bash

yabai=(
	script="$PLUGIN_DIR/yabai.sh"
	display=active
)

sketchybar --add event layout_changed       \
	--add event window_focus                  \
	--add event temp_float_toggle             \
	--add item yabai left                     \
	--set yabai "${yabai[@]}"                 \
	--subscribe yabai space_change            \
	                  layout_changed          \
	                  window_focus            \
	                  temp_float_toggle       \
	                  system_woke
