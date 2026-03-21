#!/bin/bash

source "$CONFIG_DIR/colors.sh"

update_info() {
  # macOS version
  OS_VERSION=$(sw_vers -productName 2>/dev/null)
  OS_NUMBER=$(sw_vers -productVersion 2>/dev/null)

  # Uptime
  BOOT=$(sysctl -n kern.boottime | awk '{print $4}' | tr -d ',')
  NOW=$(date +%s)
  UPTIME_SECS=$((NOW - BOOT))
  DAYS=$((UPTIME_SECS / 86400))
  HOURS=$(( (UPTIME_SECS % 86400) / 3600 ))
  MINS=$(( (UPTIME_SECS % 3600) / 60 ))

  if [ $DAYS -gt 0 ]; then
    UPTIME="${DAYS}d ${HOURS}h ${MINS}m"
  elif [ $HOURS -gt 0 ]; then
    UPTIME="${HOURS}h ${MINS}m"
  else
    UPTIME="${MINS}m"
  fi

  sketchybar --set apple.info label="$OS_VERSION $OS_NUMBER" \
             --set apple.uptime label="up $UPTIME"
}

case "$SENDER" in
  "mouse.clicked") update_info ;;
  "mouse.exited.global") sketchybar --set apple.logo popup.drawing=off ;;
esac
