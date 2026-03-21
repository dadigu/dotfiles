#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"
POPUP_STYLE="background.color=$TRANSPARENT padding_right=6 padding_left=6"

apple_logo=(
  icon=$APPLE
  icon.font="$FONT:Black:16.0"
  icon.color=$WHITE
  icon.padding_left=10
  icon.padding_right=10
  label.drawing=off
  click_script="sketchybar --set \$NAME popup.drawing=toggle"
  script="$PLUGIN_DIR/apple.sh"
)

# --- System info (dynamic, updated by plugin) ---
apple_info=(
  icon.drawing=off
  label="macOS"
  label.font="$FONT:Bold:12.0"
  label.color=$GREY
  $POPUP_STYLE
)

apple_uptime=(
  icon=􀐫
  icon.color=$GREY
  label="..."
  label.font="$FONT:Regular:12.0"
  label.color=$GREY
  $POPUP_STYLE
)

# --- Actions ---
apple_prefs=(
  icon=$PREFERENCES
  label="Settings"
  $POPUP_STYLE
  click_script="open -a 'System Settings'; $POPUP_OFF"
)

apple_activity=(
  icon=$ACTIVITY
  label="Activity Monitor"
  $POPUP_STYLE
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_forcequit=(
  icon=􀜪
  label="Force Quit"
  $POPUP_STYLE
  click_script="osascript -e 'tell application \"loginwindow\" to «event aevtrlgo»'; $POPUP_OFF"
)

apple_lock=(
  icon=$LOCK
  label="Lock Screen"
  $POPUP_STYLE
  click_script="pmset displaysleepnow; $POPUP_OFF"
)

apple_sleep=(
  icon=􀜗
  label="Sleep"
  $POPUP_STYLE
  click_script="pmset sleepnow; $POPUP_OFF"
)

apple_restart=(
  icon=􀚁
  icon.color=$ORANGE
  label="Restart"
  label.color=$ORANGE
  $POPUP_STYLE
  click_script="osascript -e 'tell app \"loginwindow\" to «event aevtrrst»'; $POPUP_OFF"
)

apple_shutdown=(
  icon=􀷃
  icon.color=$RED
  label="Shut Down"
  label.color=$RED
  $POPUP_STYLE
  click_script="osascript -e 'tell app \"loginwindow\" to «event aevtrsdn»'; $POPUP_OFF"
)

sketchybar --add item apple.logo left                      \
           --set apple.logo "${apple_logo[@]}"             \
                                                           \
           --add item apple.info popup.apple.logo          \
           --set apple.info "${apple_info[@]}"             \
                                                           \
           --add item apple.uptime popup.apple.logo        \
           --set apple.uptime "${apple_uptime[@]}"         \
                                                           \
           --add item apple.prefs popup.apple.logo         \
           --set apple.prefs "${apple_prefs[@]}"           \
                                                           \
           --add item apple.activity popup.apple.logo      \
           --set apple.activity "${apple_activity[@]}"     \
                                                           \
           --add item apple.forcequit popup.apple.logo     \
           --set apple.forcequit "${apple_forcequit[@]}"   \
                                                           \
           --add item apple.lock popup.apple.logo          \
           --set apple.lock "${apple_lock[@]}"             \
                                                           \
           --add item apple.sleep popup.apple.logo         \
           --set apple.sleep "${apple_sleep[@]}"           \
                                                           \
           --add item apple.restart popup.apple.logo       \
           --set apple.restart "${apple_restart[@]}"       \
                                                           \
           --add item apple.shutdown popup.apple.logo      \
           --set apple.shutdown "${apple_shutdown[@]}"     \
           --subscribe apple.logo mouse.exited.global      \
                                  mouse.clicked
