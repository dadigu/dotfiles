#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

SPACE=$(yabai -m query --spaces --space 2>/dev/null)
WINDOW=$(yabai -m query --windows --window 2>/dev/null)
STACK_INDEX=$(echo "$WINDOW" | jq -r '.["stack-index"]' 2>/dev/null)
SPACE_TYPE=$(echo "$SPACE" | jq -r '.type' 2>/dev/null)
IS_FLOATING=$(echo "$WINDOW" | jq -r '.["is-floating"]' 2>/dev/null)

COLOR=$BAR_BORDER_COLOR
ICON=""
LABEL=""

if [ "$IS_FLOATING" = "true" ]; then
	ICON=$YABAI_FLOAT
	COLOR=$RED
elif [ "$SPACE_TYPE" = "float" ]; then
	ICON=$YABAI_FLOAT
	COLOR=$RED
elif [ "$SPACE_TYPE" = "bsp" ]; then
	ICON=$YABAI_GRID
	COLOR=$BLUE
elif [ "${STACK_INDEX:-0}" -gt 0 ]; then
	LAST_STACK_INDEX=$(yabai -m query --windows --window stack.last | jq -r '.["stack-index"]')
	ICON=$YABAI_STACK
	LABEL="[$STACK_INDEX/$LAST_STACK_INDEX]"
	COLOR=$MAGENTA
fi

args=(--set "$NAME" icon.color="$COLOR")

if [ -n "$ICON" ]; then
	args+=(icon="$ICON" icon.width=30)
else
	args+=(icon.width=0)
fi

if [ -n "$LABEL" ]; then
	args+=(label="$LABEL" label.color="$COLOR")
else
	args+=(label.width=0)
fi

sketchybar -m "${args[@]}"
