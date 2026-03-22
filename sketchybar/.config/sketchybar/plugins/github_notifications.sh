#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

PER_PAGE=10
PAGE_FILE="/tmp/sketchybar_gh_page"
CACHE_FILE="/tmp/sketchybar_gh_cache.json"

get_type_info() {
  case "$1" in
    Issue)       TYPE_ICON=$GIT_ISSUE;        TYPE_COLOR=$GREEN;   TYPE_LABEL="Issue" ;;
    PullRequest) TYPE_ICON=$GIT_PULL_REQUEST; TYPE_COLOR=$MAGENTA; TYPE_LABEL="PR" ;;
    Discussion)  TYPE_ICON=$GIT_DISCUSSION;   TYPE_COLOR=$WHITE;   TYPE_LABEL="Discussion" ;;
    Commit)      TYPE_ICON=$GIT_COMMIT;       TYPE_COLOR=$WHITE;   TYPE_LABEL="Commit" ;;
    CheckSuite)  TYPE_ICON=$GIT_CHECKSUITE;   TYPE_COLOR=$YELLOW;  TYPE_LABEL="CI" ;;
    Release)     TYPE_ICON="􀐚";              TYPE_COLOR=$CYAN;    TYPE_LABEL="Release" ;;
    *)           TYPE_ICON=$BELL;             TYPE_COLOR=$BLUE;    TYPE_LABEL="$1" ;;
  esac
}

get_reason_label() {
  case "$1" in
    mention) echo "mentioned" ;;
    review_requested) echo "review" ;;
    assign) echo "assigned" ;;
    ci_activity) echo "CI" ;;
    state_change) echo "changed" ;;
    comment) echo "comment" ;;
    *) echo "" ;;
  esac
}

build_url() {
  local owner="$1" repo="$2" type="$3" api_url="$4"
  local number
  number=$(echo "$api_url" | grep -oE '[0-9]+$')
  case "$type" in
    Issue)       echo "https://github.com/$owner/$repo/issues/$number" ;;
    PullRequest) echo "https://github.com/$owner/$repo/pull/$number" ;;
    Discussion)  echo "https://github.com/$owner/$repo/discussions/$number" ;;
    Commit)      echo "https://github.com/$owner/$repo/commit/$number" ;;
    *)           echo "https://github.com/$owner/$repo" ;;
  esac
}

render_page() {
  [ ! -f "$CACHE_FILE" ] && return

  local PAGE=$(cat "$PAGE_FILE" 2>/dev/null || echo 1)
  local DATA=$(cat "$CACHE_FILE")
  local COUNT=$(echo "$DATA" | jq 'length')
  local TOTAL_PAGES=$(( (COUNT + PER_PAGE - 1) / PER_PAGE ))

  [ "$PAGE" -lt 1 ] && PAGE=1
  [ "$PAGE" -gt "$TOTAL_PAGES" ] && PAGE=$TOTAL_PAGES
  echo "$PAGE" > "$PAGE_FILE"

  local SKIP=$(( (PAGE - 1) * PER_PAGE ))

  args=(--remove '/github.n\..*/')

  local COUNTER=0
  local SHOWN=0

  while IFS=$'\t' read -r owner repo type title reason api_url; do
    [ -z "$repo" ] && continue
    COUNTER=$((COUNTER + 1))
    [ $COUNTER -le $SKIP ] && continue
    [ $SHOWN -ge $PER_PAGE ] && break
    SHOWN=$((SHOWN + 1))

    get_type_info "$type"

    TITLE_COLOR=$WHITE
    if echo "$title" | grep -qiE '(deprecat|break|broke|urgent|critical)'; then
      TITLE_COLOR=$RED
      TYPE_ICON=$GIT_IMPORTANT
    fi

    REASON_LABEL=$(get_reason_label "$reason")
    [ ${#title} -gt 55 ] && title="${title:0:52}..."

    URL=$(build_url "$owner" "$repo" "$type" "$api_url")

    HEADER_LABEL="$TYPE_LABEL"
    [ -n "$REASON_LABEL" ] && HEADER_LABEL="· $REASON_LABEL"

    # Header: type icon + repo + reason
    args+=(
      --add item github.n.h$SHOWN popup.github.bell
      --set github.n.h$SHOWN
            icon="$TYPE_ICON $owner/$repo"
            icon.font="$FONT:Bold:15.0"
            icon.color="$TYPE_COLOR"
            icon.padding_left=10
            icon.padding_right=0
            label="$HEADER_LABEL"
            label.font="$FONT:Regular:12.0"
            label.color="$GREY"
            label.padding_left=6
            label.padding_right=10
            background.color=0x00000000
            background.border_width=0
            click_script="open '$URL'; sketchybar --set github.bell popup.drawing=off"
    )

    # Title (pulled up tight to header)
    args+=(
      --add item github.n.t$SHOWN popup.github.bell
      --set github.n.t$SHOWN
            icon.drawing=off
            label="$title"
            label.font="$FONT:Regular:12.0"
            label.color="$TITLE_COLOR"
            label.padding_left=22
            label.padding_right=10
            y_offset=15
            background.color=0x00000000
            background.border_width=0
            click_script="open '$URL'; sketchybar --set github.bell popup.drawing=off"
    )
  done <<< "$(echo "$DATA" | jq -r '.[] | [.repository.owner.login, .repository.name, .subject.type, .subject.title, .reason, .subject.url] | @tsv')"

  # Pagination
  if [ "$TOTAL_PAGES" -gt 1 ]; then
    local NEXT_PAGE=$((PAGE % TOTAL_PAGES + 1))
    args+=(
      --add item github.n.page popup.github.bell
      --set github.n.page
            icon="Page $PAGE / $TOTAL_PAGES"
            icon.font="$FONT:Regular:11.0"
            icon.color="$GREY"
            icon.padding_left=10
            icon.padding_right=0
            label="Next 􀆊"
            label.font="$FONT:Semibold:11.0"
            label.color="$BLUE"
            label.padding_left=8
            label.padding_right=10
            y_offset=8
            background.color=0x00000000
            background.border_width=0
            click_script="echo $NEXT_PAGE > $PAGE_FILE; NAME=github.bell SENDER=page CONFIG_DIR=$CONFIG_DIR $CONFIG_DIR/plugins/github_notifications.sh"
    )
  fi

  # Footer
  args+=(
    --add item github.n.markread popup.github.bell
    --set github.n.markread
          icon="􀁣 Mark all read"
          icon.font="$FONT:Regular:11.0"
          icon.color="$GREEN"
          icon.padding_left=10
          icon.padding_right=10
          label.drawing=off
          y_offset=8
          background.color=0x00000000
          background.border_width=0
          click_script="gh api -X PUT notifications > /dev/null 2>&1; sketchybar --set github.bell popup.drawing=off icon.color=$GREY label.drawing=off --remove '/github.n\..*/'"
    --add item github.n.open popup.github.bell
    --set github.n.open
          icon="􀆅 Open on GitHub"
          icon.font="$FONT:Regular:11.0"
          icon.color="$BLUE"
          icon.padding_left=10
          icon.padding_right=10
          label.drawing=off
          y_offset=8
          background.color=0x00000000
          background.border_width=0
          click_script="open 'https://github.com/notifications'; sketchybar --set github.bell popup.drawing=off"
  )

  sketchybar -m "${args[@]}" > /dev/null
}

update() {
  NOTIFICATIONS="$(gh api notifications 2>/dev/null)"

  if [ -z "$NOTIFICATIONS" ] || [ "$NOTIFICATIONS" = "[]" ]; then
    sketchybar --set $NAME icon.color=$GREY label.drawing=off \
               --remove '/github.n\..*/'
    rm -f "$CACHE_FILE" "$PAGE_FILE"
    return
  fi

  COUNT="$(echo "$NOTIFICATIONS" | jq 'length')"
  PREV_COUNT=$(sketchybar --query github.bell | jq -r '.label.value')

  echo "$NOTIFICATIONS" > "$CACHE_FILE"
  echo 1 > "$PAGE_FILE"

  if echo "$NOTIFICATIONS" | jq -r '.[].subject.title' | grep -qiE '(deprecat|break|broke|urgent|critical)'; then
    sketchybar --set github.bell icon.color=$RED label="$COUNT" label.drawing=on
  else
    sketchybar --set github.bell icon.color=$BLUE label="$COUNT" label.drawing=on
  fi

  render_page

  if [ $COUNT -gt $PREV_COUNT ] 2>/dev/null || [ "$SENDER" = "forced" ]; then
    afplay /System/Library/Sounds/Morse.aiff &
    sketchybar --animate tanh 15 --set github.bell label.y_offset=5 label.y_offset=0
  fi
}

case "$SENDER" in
  "routine"|"forced") update ;;
  "page") render_page ;;
  "mouse.clicked") "$CONFIG_DIR/helpers/popup_dismiss.sh" "$NAME"; sketchybar --set $NAME popup.drawing=toggle ;;
  "mouse.exited.global") sketchybar --set $NAME popup.drawing=off ;;
esac
