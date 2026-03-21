#!/bin/bash

battery=(
	script="$PLUGIN_DIR/battery.sh"
	padding_right=0
	padding_left=0
	update_freq=120
	updates=on
)

status_bracket=(
	background.color="$BACKGROUND_1"
	background.border_color="$TRANSPARENT"
	background.border_width=2
	background.height=30
)

sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery power_source_change system_woke

sketchybar --add bracket status volume battery \
	--set status "${status_bracket[@]}"
