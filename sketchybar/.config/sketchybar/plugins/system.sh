#!/bin/bash

source "$CONFIG_DIR/colors.sh"

color_for_pct() {
  if [ "$1" -gt 80 ]; then
    echo "$RED"
  elif [ "$1" -gt 50 ]; then
    echo "$ORANGE"
  else
    echo "$WHITE"
  fi
}

update() {
  # CPU usage via ps (instant)
  CPU=$(ps -A -o %cpu | awk 'NR>1 {s+=$1} END {printf "%.0f", s}')
  CORES=$(sysctl -n hw.logicalcpu)
  CPU=$((CPU / CORES))

  # RAM usage via vm_stat (instant)
  PAGE_SIZE=$(sysctl -n hw.pagesize)
  VM=$(vm_stat)
  ACTIVE=$(echo "$VM" | awk '/Pages active/ {gsub(/\./,"",$3); print $3}')
  WIRED=$(echo "$VM" | awk '/Pages wired/ {gsub(/\./,"",$4); print $4}')
  COMPRESSED=$(echo "$VM" | awk '/occupied by compressor/ {gsub(/\./,"",$5); print $5}')
  TOTAL=$(sysctl -n hw.memsize)
  USED=$(( (ACTIVE + WIRED + COMPRESSED) * PAGE_SIZE ))
  RAM=$(( USED * 100 / TOTAL ))

  CPU_COLOR=$(color_for_pct "$CPU")
  RAM_COLOR=$(color_for_pct "$RAM")

  sketchybar --set cpu label="${CPU}%" icon.color="$CPU_COLOR" label.color="$CPU_COLOR" \
             --set ram label="${RAM}%" icon.color="$RAM_COLOR" label.color="$RAM_COLOR"
}

cpu_popup() {
  args=(--remove '/cpu.popup\..*/')

  CORES=$(sysctl -n hw.logicalcpu)
  LOAD=$(sysctl -n vm.loadavg | awk '{print $2, $3, $4}')

  # Header
  args+=(
    --add item cpu.popup.header popup.cpu
    --set cpu.popup.header
          label="$CORES cores"
          label.font="$FONT:Regular:12.0"
          label.color="$GREY"
          label.padding_left=6
          label.padding_right=14
          icon="􀧓 CPU"
          icon.font="$FONT:Bold:14.0"
          icon.color="$BLUE"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=36
          padding_left=0
          padding_right=0
  )

  # Load average
  args+=(
    --add item cpu.popup.load popup.cpu
    --set cpu.popup.load
          label="$LOAD"
          label.font="$FONT:Regular:12.0"
          label.color="$WHITE"
          label.padding_left=6
          label.padding_right=14
          icon="Load avg"
          icon.font="$FONT:Regular:12.0"
          icon.color="$GREY"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=28
          padding_left=0
          padding_right=0
  )

  # Separator
  args+=(
    --add item cpu.popup.sep popup.cpu
    --set cpu.popup.sep
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

  # Top 5 processes by CPU
  COUNTER=0
  while IFS='|' read -r pcpu pname; do
    [ -z "$pcpu" ] && continue
    COUNTER=$((COUNTER + 1))
    PCT_COLOR=$(color_for_pct "${pcpu%%.*}")

    args+=(
      --add item cpu.popup.proc$COUNTER popup.cpu
      --set cpu.popup.proc$COUNTER
            label="${pcpu}%"
            label.font="$FONT:Semibold:12.0"
            label.color="$PCT_COLOR"
            label.padding_left=6
            label.padding_right=14
            icon="$pname"
            icon.font="$FONT:Regular:12.0"
            icon.color="$WHITE"
            icon.padding_left=14
            icon.padding_right=0
            background.color=0x00000000
            background.border_width=0
            background.height=28
            padding_left=0
            padding_right=0
    )
  done <<< "$(ps -Arceo %cpu,comm | head -6 | tail -5 | awk '{pct=$1; $1=""; name=$0; sub(/^ +/,"",name); sub(/.*\//,"",name); sub(/ .*/,"",name); printf "%.1f|%s\n", pct, name}')"

  # Footer
  args+=(
    --add item cpu.popup.footer popup.cpu
    --set cpu.popup.footer
          label="Open Activity Monitor"
          label.font="$FONT:Regular:11.0"
          label.color="$GREY"
          label.padding_left=14
          label.padding_right=14
          icon.drawing=off
          background.color=0x00000000
          background.border_width=0
          background.height=30
          padding_left=0
          padding_right=0
          click_script="open -a 'Activity Monitor'; sketchybar --set cpu popup.drawing=off"
  )

  sketchybar -m "${args[@]}"
  sketchybar --set cpu popup.drawing=toggle
}

ram_popup() {
  args=(--remove '/ram.popup\..*/')

  PAGE_SIZE=$(sysctl -n hw.pagesize)
  VM=$(vm_stat)
  TOTAL=$(sysctl -n hw.memsize)
  TOTAL_GB=$(echo "$TOTAL" | awk '{printf "%.1f", $1/1073741824}')

  ACTIVE=$(echo "$VM" | awk '/Pages active/ {gsub(/\./,"",$3); print $3}')
  WIRED=$(echo "$VM" | awk '/Pages wired/ {gsub(/\./,"",$4); print $4}')
  COMPRESSED=$(echo "$VM" | awk '/occupied by compressor/ {gsub(/\./,"",$5); print $5}')
  FREE=$(echo "$VM" | awk '/Pages free/ {gsub(/\./,"",$3); print $3}')

  ACTIVE_GB=$(echo "$ACTIVE $PAGE_SIZE" | awk '{printf "%.1f", ($1*$2)/1073741824}')
  WIRED_GB=$(echo "$WIRED $PAGE_SIZE" | awk '{printf "%.1f", ($1*$2)/1073741824}')
  COMPRESSED_GB=$(echo "$COMPRESSED $PAGE_SIZE" | awk '{printf "%.1f", ($1*$2)/1073741824}')
  USED_GB=$(echo "$ACTIVE $WIRED $COMPRESSED $PAGE_SIZE" | awk '{printf "%.1f", (($1+$2+$3)*$4)/1073741824}')
  FREE_GB=$(echo "$TOTAL_GB $USED_GB" | awk '{printf "%.1f", $1-$2}')

  # Header
  args+=(
    --add item ram.popup.header popup.ram
    --set ram.popup.header
          label="${USED_GB} / ${TOTAL_GB} GB"
          label.font="$FONT:Regular:12.0"
          label.color="$GREY"
          label.padding_left=6
          label.padding_right=14
          icon="􀫦 Memory"
          icon.font="$FONT:Bold:14.0"
          icon.color="$BLUE"
          icon.padding_left=14
          icon.padding_right=0
          background.color=0x00000000
          background.border_width=0
          background.height=36
          padding_left=0
          padding_right=0
  )

  # Breakdown
  for entry in "Active|${ACTIVE_GB} GB|$GREEN" "Wired|${WIRED_GB} GB|$ORANGE" "Compressed|${COMPRESSED_GB} GB|$YELLOW" "Free|${FREE_GB} GB|$GREY"; do
    IFS='|' read -r lbl val clr <<< "$entry"
    SLUG=$(echo "$lbl" | tr '[:upper:]' '[:lower:]')
    args+=(
      --add item ram.popup.$SLUG popup.ram
      --set ram.popup.$SLUG
            label="$val"
            label.font="$FONT:Semibold:12.0"
            label.color="$clr"
            label.padding_left=6
            label.padding_right=14
            icon="$lbl"
            icon.font="$FONT:Regular:12.0"
            icon.color="$WHITE"
            icon.padding_left=14
            icon.padding_right=0
            background.color=0x00000000
            background.border_width=0
            background.height=28
            padding_left=0
            padding_right=0
    )
  done

  # Separator
  args+=(
    --add item ram.popup.sep popup.ram
    --set ram.popup.sep
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

  # Top 5 processes by memory
  COUNTER=0
  while IFS='|' read -r pmem pname; do
    [ -z "$pmem" ] && continue
    COUNTER=$((COUNTER + 1))
    PCT_COLOR=$(color_for_pct "${pmem%%.*}")

    args+=(
      --add item ram.popup.proc$COUNTER popup.ram
      --set ram.popup.proc$COUNTER
            label="${pmem}%"
            label.font="$FONT:Semibold:12.0"
            label.color="$PCT_COLOR"
            label.padding_left=6
            label.padding_right=14
            icon="$pname"
            icon.font="$FONT:Regular:12.0"
            icon.color="$WHITE"
            icon.padding_left=14
            icon.padding_right=0
            background.color=0x00000000
            background.border_width=0
            background.height=28
            padding_left=0
            padding_right=0
    )
  done <<< "$(ps -Ameo %mem,comm | head -6 | tail -5 | awk '{pct=$1; $1=""; name=$0; sub(/^ +/,"",name); sub(/.*\//,"",name); sub(/ .*/,"",name); printf "%.1f|%s\n", pct, name}')"

  # Footer
  args+=(
    --add item ram.popup.footer popup.ram
    --set ram.popup.footer
          label="Open Activity Monitor"
          label.font="$FONT:Regular:11.0"
          label.color="$GREY"
          label.padding_left=14
          label.padding_right=14
          icon.drawing=off
          background.color=0x00000000
          background.border_width=0
          background.height=30
          padding_left=0
          padding_right=0
          click_script="open -a 'Activity Monitor'; sketchybar --set ram popup.drawing=off"
  )

  sketchybar -m "${args[@]}"
  sketchybar --set ram popup.drawing=toggle
}

case "$NAME" in
  "cpu")
    case "$SENDER" in
      "routine"|"forced") update ;;
      "mouse.clicked") "$CONFIG_DIR/helpers/popup_dismiss.sh" cpu; cpu_popup ;;
      "mouse.exited.global") sketchybar --set cpu popup.drawing=off ;;
    esac
    ;;
  "ram")
    case "$SENDER" in
      "mouse.clicked") "$CONFIG_DIR/helpers/popup_dismiss.sh" ram; ram_popup ;;
      "mouse.exited.global") sketchybar --set ram popup.drawing=off ;;
    esac
    ;;
esac
