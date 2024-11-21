#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

BATT_PERCENT=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE=$(echo "$BATTERY_INFO" | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(echo "$BATTERY_INFO" | grep 'AC Power')
LABEL="${BATT_PERCENT}%"

if [ "$PERCENTAGE" = "" ]; then
	exit 0
fi

DRAWING=on
COLOR=$WHITE
case ${PERCENTAGE} in
9[0-9] | 100)
	ICON=$BATTERY_100
	COLOR=$WHITE
	;;
[6-8][0-9])
	ICON=$BATTERY_75
	COLOR=$GREEN
	;;
[3-5][0-9])
	ICON=$BATTERY_50
	COLOR=$GREEN
	;;
[1-2][0-9])
	ICON=$BATTERY_25
	COLOR=$ORANGE
	;;
*)
	ICON=$BATTERY_0
	COLOR=$RED
	;;
esac

if [[ $CHARGING != "" ]]; then
	ICON=$BATTERY_CHARGING
	LABEL=""
	# DRAWING=off
fi

battery=(
	drawing="$DRAWING" 
	icon="$ICON"
	icon.color="$COLOR"
	label="${LABEL}"
	label.color="$COLOR"	
)
if [ -z "$LABEL" ]; then
    battery+=("label.drawing=off")
	battery+=("icon.padding_right=8")
fi

sketchybar --set "$NAME" "${battery[@]}"