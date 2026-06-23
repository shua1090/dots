#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"
. "$(dirname "$0")/app_icon.sh"

MAX_WORKSPACES="${SKETCHYBAR_MAX_WORKSPACES:-12}"

shell_quote() {
  printf "'"
  printf '%s' "$1" | sed "s/'/'\\\\''/g"
  printf "'"
}

apps_to_icons() {
  apps="$1"
  [ -n "$apps" ] || return 0

  printf '%s' "$apps" | tr ',' '\n' | while IFS= read -r app; do
    [ -n "$app" ] || continue
    app_icon "$app"
  done
}

offline_state() {
  i=1
  while [ "$i" -le "$MAX_WORKSPACES" ]; do
    if [ "$i" -le 5 ]; then
      sketchybar --set "omniwm.workspace.$i" \
        drawing=on \
        icon="$i" \
        label.drawing=off \
        background.color=0x00000000 \
        background.border_color=0x00000000 \
      icon.color="$MUTED" \
      background.drawing=off >/dev/null 2>&1
    else
      sketchybar --set "omniwm.workspace.$i" drawing=off >/dev/null 2>&1
    fi
    i=$((i + 1))
  done

  return 0
}

refresh_workspaces() {
  command -v omniwmctl >/dev/null 2>&1 || {
    offline_state
    return 0
  }

  command -v jq >/dev/null 2>&1 || {
    offline_state
    return 0
  }

  json="$(omniwmctl query workspace-bar --format json 2>/dev/null)" || {
    offline_state
    return 0
  }

  ok="$(printf '%s' "$json" | jq -r '.ok // false' 2>/dev/null)"
  [ "$ok" = "true" ] || {
    offline_state
    return 0
  }

  active_workspace="$(omniwmctl query active-workspace --format json 2>/dev/null \
    | jq -r '.result.payload.workspace | [.rawName // "", .displayName // "", (.number // "" | tostring)] | @tsv' 2>/dev/null)"
  active_raw="$(printf '%s' "$active_workspace" | awk -F'\t' '{ print $1 }')"
  active_display="$(printf '%s' "$active_workspace" | awk -F'\t' '{ print $2 }')"
  active_number="$(printf '%s' "$active_workspace" | awk -F'\t' '{ print $3 }')"
  have_active=false
  if [ -n "$active_raw$active_display$active_number" ]; then
    have_active=true
  fi

  printf '%s' "$json" | jq -r '
    .result.payload.monitors[]
    | .workspaces[]
    | [
        (.number // 0),
        (.displayName // .rawName // (.number | tostring)),
        (.rawName // .displayName // (.number | tostring)),
        (.isFocused // false),
        ([.windows[]? | (.windowCount // 1)] | add // 0),
        ([.windows[]?.appName] | unique | .[0:3] | join(","))
      ]
    | @tsv
  ' | while IFS="$(printf '\t')" read -r number display_name raw_name focused window_count apps; do
    [ -n "$number" ] || continue
    [ "$number" -ge 1 ] 2>/dev/null || continue
    [ "$number" -le "$MAX_WORKSPACES" ] || continue

    item="omniwm.workspace.$number"
    label="$(apps_to_icons "$apps")"
    label_drawing=off
    [ -n "$label" ] && label_drawing=on
    click_script="$(shell_quote "$PLUGIN_DIR/omni_workspaces.sh") click $(shell_quote "$raw_name") $(shell_quote "$number")"
    drawing=off

    if [ "$have_active" = "true" ]; then
      focused=false
    fi

    if [ "$have_active" = "true" ] && { [ "$raw_name" = "$active_raw" ] \
      || [ "$display_name" = "$active_display" ] \
      || [ "$number" = "$active_number" ]; }; then
      focused=true
    fi

    if [ "$focused" = "true" ] || [ "${window_count:-0}" -gt 0 ] 2>/dev/null; then
      drawing=on
    fi

    icon_color="$MUTED"
    label_color="$MUTED"
    bg_drawing=off
    bg_color=0x00000000
    border_color=0x00000000

    if [ "$focused" = "true" ]; then
      icon_color="$ACTIVE_FG"
      label_color="$ACTIVE_FG"
      bg_drawing=on
      bg_color="$ACTIVE_BG"
      border_color="$ACTIVE_BG"
    elif [ "${window_count:-0}" -gt 0 ] 2>/dev/null; then
      icon_color="$TEXT"
      label_color="$SUBTEXT"
      bg_drawing=on
      bg_color="$ITEM_BG_SOFT"
      border_color="$BORDER"
    fi

    sketchybar --set "$item" \
      drawing="$drawing" \
      icon="$display_name" \
      label="$label" \
      label.drawing="$label_drawing" \
      background.drawing="$bg_drawing" \
      background.color="$bg_color" \
      background.border_color="$border_color" \
      icon.color="$icon_color" \
      label.color="$label_color" \
      click_script="$click_script" >/dev/null 2>&1 || true
  done

  return 0
}

focus_workspace() {
  workspace_name="$1"
  workspace_number="${2:-$1}"
  command -v omniwmctl >/dev/null 2>&1 || return 0

  if [ "${MODIFIER:-}" = "shift" ]; then
    omniwmctl command move-to-workspace "$workspace_number" >/dev/null 2>&1 \
      || omniwmctl command move-to-workspace "$workspace_name" >/dev/null 2>&1 \
      || true
  else
    omniwmctl workspace focus-name "$workspace_name" >/dev/null 2>&1 \
      || omniwmctl command switch-workspace anywhere "$workspace_number" >/dev/null 2>&1 \
      || omniwmctl command switch-workspace "$workspace_number" >/dev/null 2>&1 \
      || true
  fi

  refresh_workspaces
}

case "${1:-refresh}" in
  click)
    focus_workspace "$2" "$3"
    ;;
  refresh|*)
    refresh_workspaces
    ;;
esac
