#!/bin/bash

source "$CONFIG_DIR/colors.sh"

get_icon() {
  case $1 in
    113) echo "􀆮" ;;                 # Clear/Sunny
    116) echo "􀇀" ;;                 # Partly cloudy
    119|122) echo "􀇂" ;;             # Cloudy/Overcast
    143|248|260) echo "􀇊" ;;         # Fog/Mist
    176|263|266|293|296) echo "􀇄" ;; # Light rain/Drizzle
    299|302|353|356|359) echo "􀇆" ;; # Rain
    179|323|326|368) echo "􀇎" ;;     # Light snow
    227|230|329|332|335|338|371) echo "􀇎" ;; # Snow
    182|185|281|284|311|314|317|320|374|377) echo "􀇒" ;; # Sleet/Freezing
    200|386|389|392|395) echo "􀇘" ;; # Thunder
    *) echo "􀇀" ;;                   # Default
  esac
}

update() {
  DATA=$(curl -s --max-time 10 "wttr.in/?format=j1" 2>/dev/null)

  # Validate response
  if [ -z "$DATA" ] || ! echo "$DATA" | jq -e '.current_condition[0]' >/dev/null 2>&1; then
    sketchybar --set "$NAME" icon="􀇀" label="--"
    return
  fi

  # Current conditions for bar label
  TEMP=$(echo "$DATA" | jq -r '.current_condition[0].temp_C')
  CODE=$(echo "$DATA" | jq -r '.current_condition[0].weatherCode')
  ICON=$(get_icon "$CODE")

  sketchybar --set "$NAME" icon="$ICON" label="${TEMP}°"

  # Build popup
  args=(--remove '/weather.popup\..*/')

  # --- Location header ---
  LOCATION=$(echo "$DATA" | jq -r '.nearest_area[0].areaName[0].value')
  REGION=$(echo "$DATA" | jq -r '.nearest_area[0].region[0].value')

  args+=(
    --add item weather.popup.location popup.weather
    --set weather.popup.location
          label="$LOCATION, $REGION"
          label.font="$FONT:Bold:15.0"
          label.color="$BLUE"
          label.padding_left=14
          label.padding_right=14
          icon=􀋑
          icon.font="$FONT:Bold:14.0"
          icon.color="$BLUE"
          icon.padding_left=14
          icon.padding_right=6
          background.color=0x00000000
          background.border_width=0
          background.height=38
          padding_left=0
          padding_right=0
  )

  # --- Separator ---
  args+=(
    --add item weather.popup.sep1 popup.weather
    --set weather.popup.sep1
          label="───────────────────────────"
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

  # --- Current condition ---
  DESC=$(echo "$DATA" | jq -r '.current_condition[0].weatherDesc[0].value')
  FEELS=$(echo "$DATA" | jq -r '.current_condition[0].FeelsLikeC')

  args+=(
    --add item weather.popup.current popup.weather
    --set weather.popup.current
          label="${DESC}"
          label.font="$FONT:Semibold:14.0"
          label.color="$WHITE"
          label.padding_left=8
          label.padding_right=14
          icon="$ICON ${TEMP}°C"
          icon.font="$FONT:Bold:20.0"
          icon.color="$WHITE"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=40
          padding_left=0
          padding_right=0
  )

  args+=(
    --add item weather.popup.feels popup.weather
    --set weather.popup.feels
          label="Feels like ${FEELS}°C"
          label.font="$FONT:Regular:12.0"
          label.color="$GREY"
          label.padding_left=14
          label.padding_right=14
          icon.drawing=off
          background.color=0x00000000
          background.border_width=0
          background.height=24
          padding_left=0
          padding_right=0
  )

  # --- Details ---
  HUMIDITY=$(echo "$DATA" | jq -r '.current_condition[0].humidity')
  WIND=$(echo "$DATA" | jq -r '.current_condition[0].windspeedKmph')
  WIND_DIR=$(echo "$DATA" | jq -r '.current_condition[0].winddir16Point')
  UV=$(echo "$DATA" | jq -r '.current_condition[0].uvIndex')
  VISIBILITY=$(echo "$DATA" | jq -r '.current_condition[0].visibility')

  args+=(
    --add item weather.popup.detail1 popup.weather
    --set weather.popup.detail1
          label="${HUMIDITY}%"
          label.font="$FONT:Regular:12.0"
          label.color="$WHITE"
          label.padding_left=6
          label.padding_right=14
          icon="􀌥 Humidity"
          icon.font="$FONT:Regular:12.0"
          icon.color="$CYAN"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=28
          padding_left=0
          padding_right=0
  )

  args+=(
    --add item weather.popup.detail2 popup.weather
    --set weather.popup.detail2
          label="${WIND} km/h ${WIND_DIR}"
          label.font="$FONT:Regular:12.0"
          label.color="$WHITE"
          label.padding_left=6
          label.padding_right=14
          icon="􀇬 Wind"
          icon.font="$FONT:Regular:12.0"
          icon.color="$CYAN"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=28
          padding_left=0
          padding_right=0
  )

  args+=(
    --add item weather.popup.detail3 popup.weather
    --set weather.popup.detail3
          label="Index $UV"
          label.font="$FONT:Regular:12.0"
          label.color="$WHITE"
          label.padding_left=6
          label.padding_right=14
          icon="􀆭 UV"
          icon.font="$FONT:Regular:12.0"
          icon.color="$CYAN"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=28
          padding_left=0
          padding_right=0
  )

  args+=(
    --add item weather.popup.detail4 popup.weather
    --set weather.popup.detail4
          label="${VISIBILITY} km"
          label.font="$FONT:Regular:12.0"
          label.color="$WHITE"
          label.padding_left=6
          label.padding_right=14
          icon="􀋭 Visibility"
          icon.font="$FONT:Regular:12.0"
          icon.color="$CYAN"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=28
          padding_left=0
          padding_right=0
  )

  # --- Separator ---
  args+=(
    --add item weather.popup.sep2 popup.weather
    --set weather.popup.sep2
          label="───────────────────────────"
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

  # --- 3-day forecast ---
  for i in 0 1 2; do
    DAY_DATE=$(echo "$DATA" | jq -r ".weather[$i].date")
    DAY_MAX=$(echo "$DATA" | jq -r ".weather[$i].maxtempC")
    DAY_MIN=$(echo "$DATA" | jq -r ".weather[$i].mintempC")
    # Use midday (index 4 = 12:00) for representative weather
    DAY_CODE=$(echo "$DATA" | jq -r ".weather[$i].hourly[4].weatherCode")
    DAY_ICON=$(get_icon "$DAY_CODE")

    if [ $i -eq 0 ]; then
      DAY_NAME="Today"
    elif [ $i -eq 1 ]; then
      DAY_NAME="Tomorrow"
    else
      DAY_NAME=$(date -j -f "%Y-%m-%d" "$DAY_DATE" "+%A" 2>/dev/null || echo "$DAY_DATE")
    fi

    args+=(
      --add item weather.popup.forecast$i popup.weather
      --set weather.popup.forecast$i
            label="${DAY_ICON}  ${DAY_MIN}° / ${DAY_MAX}°"
            label.font="$FONT:Regular:13.0"
            label.color="$WHITE"
            label.padding_left=6
            label.padding_right=14
            icon="$DAY_NAME"
            icon.font="$FONT:Semibold:13.0"
            icon.color="$GREY"
            icon.padding_left=14
            icon.padding_right=0
            background.color=0x00000000
            background.border_width=0
            background.height=32
            padding_left=0
            padding_right=0
    )
  done

  sketchybar -m "${args[@]}"
}

case "$SENDER" in
  "routine"|"forced") update ;;
  "mouse.clicked") sketchybar --set "$NAME" popup.drawing=toggle ;;
  "mouse.exited.global") sketchybar --set "$NAME" popup.drawing=off ;;
esac
