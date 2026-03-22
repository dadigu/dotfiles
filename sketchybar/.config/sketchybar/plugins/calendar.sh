#!/bin/bash

source "$CONFIG_DIR/colors.sh"

update() {
  sketchybar --set "$NAME" label="$(date '+%d %b %H:%M')"

  args=(--remove '/calendar.cal\..*/')

  # Custom header instead of cal's truncated one
  HEADER=$(date '+%B %Y')
  TODAY=$(date '+%-d')

  args+=(
    --add item calendar.cal.header popup.calendar
    --set calendar.cal.header
          label="$HEADER"
          label.font="Menlo:Bold:15.0"
          label.color="$BLUE"
          label.padding_left=14
          label.padding_right=14
          icon.drawing=off
          background.color=0x00000000
          background.border_width=0
          background.height=36
          padding_left=0
          padding_right=0
  )

  args+=(
    --add item calendar.cal.daynames popup.calendar
    --set calendar.cal.daynames
          label="Su Mo Tu We Th Fr Sa"
          label.font="Menlo:Regular:14.0"
          label.color="$GREY"
          label.padding_left=14
          label.padding_right=14
          icon.drawing=off
          background.color=0x00000000
          background.border_width=0
          background.height=30
          padding_left=0
          padding_right=0
  )

  args+=(
    --add item calendar.cal.sep popup.calendar
    --set calendar.cal.sep
          label="─────────────────────"
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

  # Skip header (line 1) and day names (line 2) from cal output
  COUNTER=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    COUNTER=$((COUNTER + 1))
    # Skip first 2 lines (header + day names)
    [ $COUNTER -le 2 ] && continue

    COLOR=$WHITE
    FONT_STYLE="Regular"

    if echo " $line " | grep -qw "$TODAY"; then
      COLOR=$MAGENTA
      FONT_STYLE="Bold"
    fi

    args+=(
      --add item calendar.cal.week$COUNTER popup.calendar
      --set calendar.cal.week$COUNTER
            label="$line"
            label.font="Menlo:${FONT_STYLE}:14.0"
            label.color="$COLOR"
            label.padding_left=14
            label.padding_right=14
            icon.drawing=off
            background.color=0x00000000
            background.border_width=0
            background.height=32
            padding_left=0
            padding_right=0
    )
  done <<< "$(cal)"

  sketchybar -m "${args[@]}"
}

case "$SENDER" in
  "routine"|"forced") update ;;
  "mouse.clicked") "$CONFIG_DIR/helpers/popup_dismiss.sh" "$NAME"; sketchybar --set "$NAME" popup.drawing=toggle ;;
  "mouse.exited.global") sketchybar --set "$NAME" popup.drawing=off ;;
esac
