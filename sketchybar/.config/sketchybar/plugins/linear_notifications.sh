#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

PER_PAGE=10
PAGE_FILE="/tmp/sketchybar_linear_page"
CACHE_FILE="/tmp/sketchybar_linear_cache.json"

get_type_info() {
  case "$1" in
    issueAssignment)        TYPE_ICON="􀁜"; TYPE_COLOR=$GREEN;   TYPE_LABEL="Assigned to you" ;;
    issueMention)           TYPE_ICON="􀅷"; TYPE_COLOR=$BLUE;    TYPE_LABEL="Mentioned you" ;;
    issueComment|issueNewComment) TYPE_ICON="􀌲"; TYPE_COLOR=$WHITE; TYPE_LABEL="Commented" ;;
    issueStatusChanged)     TYPE_ICON="􀁣"; TYPE_COLOR=$CYAN;    TYPE_LABEL="Status changed" ;;
    issuePriorityChanged)   TYPE_ICON="􀄬"; TYPE_COLOR=$ORANGE;  TYPE_LABEL="Priority changed" ;;
    issueBlocking)          TYPE_ICON="􀇿"; TYPE_COLOR=$RED;     TYPE_LABEL="Blocking" ;;
    issueUnblocked)         TYPE_ICON="􀁣"; TYPE_COLOR=$GREEN;   TYPE_LABEL="Unblocked" ;;
    issueDue|issueReminder) TYPE_ICON="􀧞"; TYPE_COLOR=$ORANGE;  TYPE_LABEL="Due soon" ;;
    issueCreated)           TYPE_ICON="􀁜"; TYPE_COLOR=$GREEN;   TYPE_LABEL="Created" ;;
    projectUpdateMentionPrompt) TYPE_ICON="􀅷"; TYPE_COLOR=$BLUE; TYPE_LABEL="Mentioned you" ;;
    projectUpdateCreated)   TYPE_ICON="􀐛"; TYPE_COLOR=$MAGENTA; TYPE_LABEL="New update" ;;
    projectUpdateNewComment) TYPE_ICON="􀌲"; TYPE_COLOR=$WHITE;  TYPE_LABEL="Replied" ;;
    *)                      TYPE_ICON="􀍕"; TYPE_COLOR=$MAGENTA; TYPE_LABEL="Update" ;;
  esac
}

# Relative time (e.g. "2h", "3d")
relative_time() {
  local created="$1"
  local now=$(date +%s)
  # Parse ISO 8601 date
  local ts=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%%.*}" +%s 2>/dev/null || echo "$now")
  local diff=$((now - ts))

  if [ $diff -lt 3600 ]; then
    echo "$((diff / 60))m"
  elif [ $diff -lt 86400 ]; then
    echo "$((diff / 3600))h"
  else
    echo "$((diff / 86400))d"
  fi
}

fetch_notifications() {
  [ -z "$LINEAR_API_KEY" ] && return 1

  local QUERY
  QUERY=$(cat <<'GRAPHQL'
{ notifications(first: 30) { nodes { type readAt createdAt actor { name } ... on IssueNotification { issue { identifier title url team { name key } } comment { body } } ... on ProjectNotification { projectUpdate { body user { name } } project { name url } } } } }
GRAPHQL
)

  curl -s --max-time 10 \
    -H "Authorization: $LINEAR_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"query\":\"$QUERY\"}" \
    https://api.linear.app/graphql 2>/dev/null
}

render_page() {
  [ ! -f "$CACHE_FILE" ] && return

  local PAGE=$(cat "$PAGE_FILE" 2>/dev/null || echo 1)
  local DATA=$(cat "$CACHE_FILE")

  # Flatten notifications into a unified list with subtitle
  local ITEMS
  ITEMS=$(echo "$DATA" | jq -r '
    [.data.notifications.nodes[]
      | select(.readAt == null)
      | if .issue then
          {
            type,
            title: .issue.title,
            name: .issue.identifier,
            url: .issue.url,
            actor: (.actor.name // ""),
            subtitle: (if .comment then (.comment.body | split("\n")[0] | if length > 50 then .[0:47] + "..." else . end) else "" end),
            created: .createdAt
          }
        elif .project then
          {
            type,
            title: .project.name,
            name: (.issue.identifier // ""),
            url: .project.url,
            actor: (.actor.name // ""),
            subtitle: (if .projectUpdate then (.projectUpdate.body | split("\n")[0] | if length > 50 then .[0:47] + "..." else . end) else "" end),
            created: .createdAt
          }
        else empty end
    ]')

  local COUNT=$(echo "$ITEMS" | jq 'length')
  local TOTAL_PAGES=$(( (COUNT + PER_PAGE - 1) / PER_PAGE ))

  [ "$TOTAL_PAGES" -lt 1 ] && TOTAL_PAGES=1
  [ "$PAGE" -lt 1 ] && PAGE=1
  [ "$PAGE" -gt "$TOTAL_PAGES" ] && PAGE=$TOTAL_PAGES
  echo "$PAGE" > "$PAGE_FILE"

  local SKIP=$(( (PAGE - 1) * PER_PAGE ))

  args=(--remove '/linear.n\..*/')

  local SHOWN=0

  while IFS=$'\t' read -r type title name url actor subtitle created; do
    [ -z "$title" ] && continue
    SHOWN=$((SHOWN + 1))

    get_type_info "$type"

    [ ${#title} -gt 45 ] && title="${title:0:42}..."

    local TIME_AGO
    TIME_AGO=$(relative_time "$created")

    # Build subtitle: "Actor · Type label · Time"
    local SUBTITLE="$TYPE_LABEL"
    [ -n "$actor" ] && SUBTITLE="$actor · $TYPE_LABEL"
    SUBTITLE="$SUBTITLE · $TIME_AGO"

    # Header: icon + title
    args+=(
      --add item linear.n.h$SHOWN popup.linear.bell
      --set linear.n.h$SHOWN
            icon="$TYPE_ICON"
            icon.font="$FONT:Bold:15.0"
            icon.color="$TYPE_COLOR"
            icon.padding_left=10
            icon.padding_right=6
            label="$title"
            label.font="$FONT:Semibold:15.0"
            label.color="$WHITE"
            label.padding_left=0
            label.padding_right=10
            background.color=0x00000000
            background.border_width=0
            click_script="open '$url'; sketchybar --set linear.bell popup.drawing=off"
    )

    # Subtitle: actor + type + time
    args+=(
      --add item linear.n.t$SHOWN popup.linear.bell
      --set linear.n.t$SHOWN
            icon.drawing=off
            label="$SUBTITLE"
            label.font="$FONT:Regular:12.0"
            label.color="$GREY"
            label.padding_left=26
            label.padding_right=10
            y_offset=15
            background.color=0x00000000
            background.border_width=0
            click_script="open '$url'; sketchybar --set linear.bell popup.drawing=off"
    )
  done <<< "$(echo "$ITEMS" | jq -r ".[$SKIP:$((SKIP + PER_PAGE))][] | [.type, .title, .name, .url, .actor, .subtitle, .created] | @tsv")"

  # Pagination
  if [ "$TOTAL_PAGES" -gt 1 ]; then
    local NEXT_PAGE=$((PAGE % TOTAL_PAGES + 1))
    args+=(
      --add item linear.n.page popup.linear.bell
      --set linear.n.page
            icon="Page $PAGE / $TOTAL_PAGES"
            icon.font="$FONT:Regular:11.0"
            icon.color="$GREY"
            icon.padding_left=10
            icon.padding_right=0
            label="Next 􀆊"
            label.font="$FONT:Semibold:11.0"
            label.color="$MAGENTA"
            label.padding_left=8
            label.padding_right=10
            y_offset=8
            background.color=0x00000000
            background.border_width=0
            click_script="echo $NEXT_PAGE > $PAGE_FILE; NAME=linear.bell SENDER=page CONFIG_DIR=$CONFIG_DIR $CONFIG_DIR/plugins/linear_notifications.sh"
    )
  fi

  # Footer
  args+=(
    --add item linear.n.open popup.linear.bell
    --set linear.n.open
          icon="􀆅 Open Linear"
          icon.font="$FONT:Regular:11.0"
          icon.color="$MAGENTA"
          icon.padding_left=10
          icon.padding_right=10
          label.drawing=off
          y_offset=8
          background.color=0x00000000
          background.border_width=0
          click_script="open 'https://linear.app'; sketchybar --set linear.bell popup.drawing=off"
  )

  sketchybar -m "${args[@]}" > /dev/null
}

update() {
  if [ -z "$LINEAR_API_KEY" ]; then
    sketchybar --set $NAME icon="$LINEAR_ICON" icon.color="$GREY" label="—"
    return
  fi

  RESPONSE=$(fetch_notifications)

  if [ -z "$RESPONSE" ] || ! echo "$RESPONSE" | jq -e '.data.notifications' >/dev/null 2>&1; then
    sketchybar --set $NAME icon="$LINEAR_ICON" icon.color="$RED" label="!"
    return
  fi

  COUNT=$(echo "$RESPONSE" | jq '[.data.notifications.nodes[] | select(.readAt == null) | select(.issue != null or .project != null)] | length')

  if [ "$COUNT" -eq 0 ]; then
    sketchybar --set $NAME icon.color="$GREY" label.drawing=off \
               --remove '/linear.n\..*/'
    rm -f "$CACHE_FILE" "$PAGE_FILE"
    return
  fi

  echo "$RESPONSE" > "$CACHE_FILE"
  echo 1 > "$PAGE_FILE"

  sketchybar --set $NAME icon.color="$MAGENTA" label="$COUNT" label.drawing=on

  render_page
}

case "$SENDER" in
  "routine"|"forced") update ;;
  "page") render_page ;;
  "mouse.clicked") "$CONFIG_DIR/helpers/popup_dismiss.sh" "$NAME"; sketchybar --set $NAME popup.drawing=toggle ;;
  "mouse.exited.global") sketchybar --set $NAME popup.drawing=off ;;
esac
