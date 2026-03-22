#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Detect the primary network interface and its type
get_network_info() {
  ACTIVE_IFACE=$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')

  if [ -z "$ACTIVE_IFACE" ]; then
    NET_TYPE="disconnected"
    NET_ICON="􀙈"
    NET_COLOR="$RED"
    return
  fi

  # Determine interface type from hardware ports
  HARDWARE_PORT=$(networksetup -listallhardwareports | grep -B1 "Device: $ACTIVE_IFACE" | head -1 | sed 's/Hardware Port: //')

  case "$HARDWARE_PORT" in
    *Wi-Fi*)
      NET_TYPE="wifi"
      NET_ICON="􀙇"
      NET_COLOR="$WHITE"
      WIFI_SSID=$(networksetup -getairportnetwork "$ACTIVE_IFACE" 2>/dev/null | sed 's/Current Wi-Fi Network: //')
      # Falls back to "Connected" if macOS redacts the SSID
      if [ -z "$WIFI_SSID" ] || echo "$WIFI_SSID" | grep -q "not associated\|redacted"; then
        WIFI_SSID="Connected"
      fi
      ;;
    *Ethernet*|*Thunderbolt*|*USB*)
      NET_TYPE="ethernet"
      NET_ICON="􀤆"
      NET_COLOR="$WHITE"
      ;;
    *)
      NET_TYPE="other"
      NET_ICON="􀤆"
      NET_COLOR="$WHITE"
      ;;
  esac

  NET_IP=$(ipconfig getifaddr "$ACTIVE_IFACE" 2>/dev/null)
}

update() {
  get_network_info
  sketchybar --set "$NAME" icon="$NET_ICON" icon.color="$NET_COLOR"
}

popup() {
  "$CONFIG_DIR/helpers/popup_dismiss.sh" "$NAME"

  get_network_info

  args=(--remove '/network.popup\..*/')

  # Header
  local HEADER_LABEL="Not Connected"
  local HEADER_COLOR=$RED
  if [ "$NET_TYPE" = "wifi" ]; then
    HEADER_LABEL="Wi-Fi"
    HEADER_COLOR=$GREEN
  elif [ "$NET_TYPE" = "ethernet" ]; then
    HEADER_LABEL="Ethernet"
    HEADER_COLOR=$GREEN
  fi

  args+=(
    --add item network.popup.header popup.network
    --set network.popup.header
          icon="$NET_ICON Network"
          icon.font="$FONT:Bold:14.0"
          icon.color="$BLUE"
          icon.padding_left=14
          icon.padding_right=0
          label="$HEADER_LABEL"
          label.font="$FONT:Semibold:12.0"
          label.color="$HEADER_COLOR"
          label.padding_left=6
          label.padding_right=14
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
  )

  if [ "$NET_TYPE" = "disconnected" ]; then
    args+=(
      --add item network.popup.none popup.network
      --set network.popup.none
            icon.drawing=off
            label="No active connection"
            label.font="$FONT:Regular:12.0"
            label.color="$GREY"
            label.padding_left=14
            label.padding_right=14
            background.color=0x00000000
            background.border_width=0
            padding_left=0
            padding_right=0
    )
    sketchybar -m "${args[@]}"
    sketchybar --set "$NAME" popup.drawing=toggle
    return
  fi

  # Interface + IP
  args+=(
    --add item network.popup.iface popup.network
    --set network.popup.iface
          icon="Interface"
          icon.font="$FONT:Regular:12.0"
          icon.color="$GREY"
          icon.padding_left=14
          icon.padding_right=0
          label="$ACTIVE_IFACE"
          label.font="$FONT:Semibold:12.0"
          label.color="$WHITE"
          label.padding_left=6
          label.padding_right=14
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
  )

  args+=(
    --add item network.popup.ip popup.network
    --set network.popup.ip
          icon="IP"
          icon.font="$FONT:Regular:12.0"
          icon.color="$GREY"
          icon.padding_left=14
          icon.padding_right=0
          label="${NET_IP:-N/A}"
          label.font="$FONT:Semibold:12.0"
          label.color="$WHITE"
          label.padding_left=6
          label.padding_right=14
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
  )

  # Check for other connected interfaces
  local OTHER_CONNECTIONS=""
  for iface in en0 en1 en2 en3 en4 en5 en6 en7 en8; do
    [ "$iface" = "$ACTIVE_IFACE" ] && continue
    local IP=$(ipconfig getifaddr "$iface" 2>/dev/null)
    if [ -n "$IP" ]; then
      local PORT=$(networksetup -listallhardwareports | grep -B1 "Device: $iface" | head -1 | sed 's/Hardware Port: //')
      OTHER_CONNECTIONS="${OTHER_CONNECTIONS}${PORT} ($iface) · $IP\n"
    fi
  done

  if [ -n "$OTHER_CONNECTIONS" ]; then
    # Separator
    args+=(
      --add item network.popup.sep1 popup.network
      --set network.popup.sep1
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

    args+=(
      --add item network.popup.other_hdr popup.network
      --set network.popup.other_hdr
            icon.drawing=off
            label="Other Connections"
            label.font="$FONT:Bold:12.0"
            label.color="$GREY"
            label.padding_left=14
            label.padding_right=14
            background.color=0x00000000
            background.border_width=0
            padding_left=0
            padding_right=0
    )

    local OCNT=0
    while IFS= read -r conn; do
      [ -z "$conn" ] && continue
      OCNT=$((OCNT + 1))
      args+=(
        --add item network.popup.other$OCNT popup.network
        --set network.popup.other$OCNT
              icon.drawing=off
              label="$conn"
              label.font="$FONT:Regular:11.0"
              label.color="$WHITE"
              label.padding_left=14
              label.padding_right=14
              background.color=0x00000000
              background.border_width=0
              padding_left=0
              padding_right=0
      )
    done <<< "$(printf "$OTHER_CONNECTIONS")"
  fi

  # Separator
  args+=(
    --add item network.popup.sep2 popup.network
    --set network.popup.sep2
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

  # Bluetooth
  local BT_STATE=$(system_profiler SPBluetoothDataType 2>/dev/null | awk '/State:/{print $2; exit}')
  local BT_COLOR=$GREY
  local BT_LABEL="Off"

  if [ "$BT_STATE" = "On" ]; then
    BT_LABEL="On"
    BT_COLOR=$GREEN
  fi

  args+=(
    --add item network.popup.bt popup.network
    --set network.popup.bt
          icon="􀉣 Bluetooth"
          icon.font="$FONT:Bold:14.0"
          icon.color="$BLUE"
          icon.padding_left=14
          icon.padding_right=0
          label="$BT_LABEL"
          label.font="$FONT:Semibold:12.0"
          label.color="$BT_COLOR"
          label.padding_left=6
          label.padding_right=14
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
  )

  # Connected bluetooth devices
  if [ "$BT_STATE" = "On" ]; then
    local BT_DATA
    BT_DATA=$(system_profiler SPBluetoothDataType 2>/dev/null)

    # Get connected devices with their type
    local BT_CONNECTED
    BT_CONNECTED=$(echo "$BT_DATA" | awk '/Not Connected:/{found=0; next} /Connected:/{found=1; next} found && /^          [^ ]/{gsub(/^ +/,""); gsub(/:$/,""); print}')

    if [ -n "$BT_CONNECTED" ]; then
      local BCNT=0
      while IFS= read -r device; do
        [ -z "$device" ] && continue
        BCNT=$((BCNT + 1))

        # Detect device type for icon
        local DEV_TYPE
        DEV_TYPE=$(echo "$BT_DATA" | awk -v dev="$device:" '/Not Connected:/{skip=1; next} /Connected:/{skip=0; next} skip{next} $0 ~ dev {found=1; next} found && /Minor Type:/{print $NF; exit} found && /^          [^ ]/{exit}')

        local DEV_ICON="􀉣"
        case "$DEV_TYPE" in
          *Headphones*|*Headset*|*Audio*) DEV_ICON="􀑈" ;;
          *Keyboard*)                     DEV_ICON="􀇳" ;;
          *Mouse*|*Trackpad*|*Pointing*)  DEV_ICON="􀺰" ;;
          *Watch*)                        DEV_ICON="􀟤" ;;
          *Phone*)                        DEV_ICON="􀟜" ;;
          *Gamepad*|*Joystick*)           DEV_ICON="􀛸" ;;
        esac

        args+=(
          --add item network.popup.btd$BCNT popup.network
          --set network.popup.btd$BCNT
                icon="$DEV_ICON"
                icon.font="$FONT:Regular:13.0"
                icon.color="$CYAN"
                icon.padding_left=14
                icon.padding_right=6
                label="$device"
                label.font="$FONT:Regular:12.0"
                label.color="$WHITE"
                label.padding_left=0
                label.padding_right=14
                background.color=0x00000000
                background.border_width=0
                padding_left=0
                padding_right=0
        )
      done <<< "$BT_CONNECTED"
    else
      args+=(
        --add item network.popup.btd_none popup.network
        --set network.popup.btd_none
              icon.drawing=off
              label="No devices connected"
              label.font="$FONT:Regular:11.0"
              label.color="$GREY"
              label.padding_left=14
              label.padding_right=14
              background.color=0x00000000
              background.border_width=0
              padding_left=0
              padding_right=0
      )
    fi
  fi

  # Open Network Settings
  args+=(
    --add item network.popup.settings popup.network
    --set network.popup.settings
          icon="􀆅 Network Settings"
          icon.font="$FONT:Regular:11.0"
          icon.color="$GREY"
          icon.padding_left=14
          icon.padding_right=14
          label.drawing=off
          background.color=0x00000000
          background.border_width=0
          padding_left=0
          padding_right=0
          click_script="open 'x-apple.systempreferences:com.apple.Network-Settings.extension'; sketchybar --set network popup.drawing=off"
  )

  sketchybar -m "${args[@]}"
  sketchybar --set "$NAME" popup.drawing=toggle
}

case "$SENDER" in
  "routine"|"forced"|"wifi_change"|"system_woke") update ;;
  "mouse.clicked") popup ;;
  "mouse.exited.global") sketchybar --set "$NAME" popup.drawing=off ;;
esac
