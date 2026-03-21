#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

BATTERY_INFO="$(pmset -g batt)"
PERCENTAGE=$(echo "$BATTERY_INFO" | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(echo "$BATTERY_INFO" | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then
	exit 0
fi

COLOR=$WHITE
case ${PERCENTAGE} in
	9[0-9]|100) ICON=$BATTERY_100;  COLOR=$WHITE  ;;
	[6-8][0-9]) ICON=$BATTERY_75;   COLOR=$GREEN  ;;
	[3-5][0-9]) ICON=$BATTERY_50;   COLOR=$GREEN  ;;
	[1-2][0-9]) ICON=$BATTERY_25;   COLOR=$ORANGE ;;
	*)          ICON=$BATTERY_0;    COLOR=$RED    ;;
esac

if [ -n "$CHARGING" ]; then
	ICON=$BATTERY_CHARGING
	sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label.drawing=off icon.padding_right=8
else
	sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%" label.color="$COLOR" label.drawing=on
fi
