#!/bin/bash

source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/colors.sh"

get_icon_and_color() {
  case ${1} in
    9[0-9]|100) ICON=$BATTERY_100;  COLOR=$WHITE  ;;
    [6-8][0-9]) ICON=$BATTERY_75;   COLOR=$GREEN  ;;
    [3-5][0-9]) ICON=$BATTERY_50;   COLOR=$GREEN  ;;
    [1-2][0-9]) ICON=$BATTERY_25;   COLOR=$ORANGE ;;
    *)          ICON=$BATTERY_0;     COLOR=$RED    ;;
  esac
}

update() {
  BATTERY_INFO="$(pmset -g batt)"
  PERCENTAGE=$(echo "$BATTERY_INFO" | grep -Eo "\d+%" | cut -d% -f1)
  CHARGING=$(echo "$BATTERY_INFO" | grep 'AC Power')

  if [ -z "$PERCENTAGE" ]; then
    exit 0
  fi

  get_icon_and_color "$PERCENTAGE"

  if [ -n "$CHARGING" ]; then
    ICON=$BATTERY_CHARGING
    sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label.drawing=off icon.padding_right=8
  else
    sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%" label.color="$COLOR" label.drawing=on icon.padding_right=3
  fi
}

popup() {
  "$CONFIG_DIR/helpers/popup_dismiss.sh" "$NAME"

  args=(--remove '/battery.popup\..*/')

  BATTERY_INFO="$(pmset -g batt)"
  PERCENTAGE=$(echo "$BATTERY_INFO" | grep -Eo "\d+%" | cut -d% -f1)
  CHARGING=$(echo "$BATTERY_INFO" | grep 'AC Power')
  TIME_LEFT=$(echo "$BATTERY_INFO" | grep -Eo "\d+:\d+" | head -1)

  get_icon_and_color "$PERCENTAGE"

  # State
  if [ -n "$CHARGING" ]; then
    if [ "$PERCENTAGE" -eq 100 ]; then
      STATE="Full"
      STATE_COLOR=$GREEN
    else
      STATE="Charging"
      STATE_COLOR=$CYAN
    fi
  else
    STATE="On Battery"
    STATE_COLOR=$ORANGE
  fi

  # Time remaining
  if [ -n "$TIME_LEFT" ] && [ "$TIME_LEFT" != "0:00" ]; then
    HOURS=$(echo "$TIME_LEFT" | cut -d: -f1)
    MINS=$(echo "$TIME_LEFT" | cut -d: -f2)
    if [ -n "$CHARGING" ]; then
      TIME_LABEL="Full in ${HOURS}h ${MINS}m"
    else
      TIME_LABEL="${HOURS}h ${MINS}m remaining"
    fi
  else
    TIME_LABEL=""
  fi

  # Header
  args+=(
    --add item battery.popup.header popup.battery
    --set battery.popup.header
          icon="$ICON Battery"
          icon.font="$FONT:Bold:14.0"
          icon.color="$BLUE"
          icon.padding_left=14
          icon.padding_right=0
          label.drawing=off
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
  )

  # Percentage + state
  args+=(
    --add item battery.popup.pct popup.battery
    --set battery.popup.pct
          icon="${PERCENTAGE}%"
          icon.font="$FONT:Bold:18.0"
          icon.color="$COLOR"
          icon.padding_left=14
          icon.padding_right=6
          label="$STATE"
          label.font="$FONT:Regular:12.0"
          label.color="$STATE_COLOR"
          label.padding_left=0
          label.padding_right=14
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
  )

  # Time remaining
  if [ -n "$TIME_LABEL" ]; then
    args+=(
      --add item battery.popup.time popup.battery
      --set battery.popup.time
            icon.drawing=off
            label="$TIME_LABEL"
            label.font="$FONT:Regular:12.0"
            label.color="$GREY"
            label.padding_left=14
            label.padding_right=14
            background.color=0x00000000
            background.border_width=0
            padding_left=0
            padding_right=0
    )
  fi

  # Separator
  args+=(
    --add item battery.popup.sep popup.battery
    --set battery.popup.sep
          label="────────────────────────"
          label.font="Menlo:Regular:9.0"
          label.color="$GREY"
          label.padding_left=14
          label.padding_right=14
          icon.drawing=off
          background.color=0x00000000
          background.border_width=0
          background.height=16
          padding_left=0
          padding_right=0
  )

  # Battery health details (system_profiler is slow, only on click)
  POWER_DATA=$(system_profiler SPPowerDataType 2>/dev/null)
  CYCLE_COUNT=$(echo "$POWER_DATA" | grep "Cycle Count" | awk '{print $NF}')
  CONDITION=$(echo "$POWER_DATA" | grep "Condition" | awk -F': ' '{print $2}')
  MAX_CAPACITY=$(echo "$POWER_DATA" | grep "Maximum Capacity" | awk '{print $NF}')

  # Power source
  if [ -n "$CHARGING" ]; then
    POWER_SRC="AC Adapter"
    POWER_COLOR=$CYAN
  else
    POWER_SRC="Battery"
    POWER_COLOR=$ORANGE
  fi

  args+=(
    --add item battery.popup.source popup.battery
    --set battery.popup.source
          icon="Power"
          icon.font="$FONT:Regular:12.0"
          icon.color="$GREY"
          icon.padding_left=14
          icon.padding_right=0
          label="$POWER_SRC"
          label.font="$FONT:Semibold:12.0"
          label.color="$POWER_COLOR"
          label.padding_left=6
          label.padding_right=14
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
  )

  if [ -n "$CONDITION" ]; then
    COND_COLOR=$GREEN
    [ "$CONDITION" != "Normal" ] && COND_COLOR=$RED

    args+=(
      --add item battery.popup.health popup.battery
      --set battery.popup.health
            icon="Health"
            icon.font="$FONT:Regular:12.0"
            icon.color="$GREY"
            icon.padding_left=14
            icon.padding_right=0
            label="$CONDITION"
            label.font="$FONT:Semibold:12.0"
            label.color="$COND_COLOR"
            label.padding_left=6
            label.padding_right=14
            background.color=0x00000000
            background.border_width=0
            padding_left=0
            padding_right=0
    )
  fi

  if [ -n "$MAX_CAPACITY" ]; then
    args+=(
      --add item battery.popup.capacity popup.battery
      --set battery.popup.capacity
            icon="Max Capacity"
            icon.font="$FONT:Regular:12.0"
            icon.color="$GREY"
            icon.padding_left=14
            icon.padding_right=0
            label="$MAX_CAPACITY"
            label.font="$FONT:Semibold:12.0"
            label.color="$WHITE"
            label.padding_left=6
            label.padding_right=14
            background.color=0x00000000
            background.border_width=0
            padding_left=0
            padding_right=0
    )
  fi

  if [ -n "$CYCLE_COUNT" ]; then
    args+=(
      --add item battery.popup.cycles popup.battery
      --set battery.popup.cycles
            icon="Cycles"
            icon.font="$FONT:Regular:12.0"
            icon.color="$GREY"
            icon.padding_left=14
            icon.padding_right=0
            label="$CYCLE_COUNT"
            label.font="$FONT:Semibold:12.0"
            label.color="$WHITE"
            label.padding_left=6
            label.padding_right=14
            background.color=0x00000000
            background.border_width=0
            padding_left=0
            padding_right=0
    )
  fi

  sketchybar -m "${args[@]}"
  sketchybar --set "$NAME" popup.drawing=toggle
}

case "$SENDER" in
  "routine"|"forced"|"power_source_change"|"system_woke") update ;;
  "mouse.clicked") popup ;;
  "mouse.exited.global") sketchybar --set "$NAME" popup.drawing=off ;;
esac
