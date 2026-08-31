#!/usr/bin/env bash

source "$(dirname "$0")/helpers.sh"
source "$PLUGIN_DIR/app_icon.sh"

MAX_WORKSPACES="${SKETCHYBAR_MAX_WORKSPACES:-10}"
LOCK_DIR="${TMPDIR:-/tmp}/sketchybar-paneru-refresh-${UID}.lock"
PENDING_FILE="${TMPDIR:-/tmp}/sketchybar-paneru-refresh-${UID}.pending"

render_offline() {
  local args=(--animate tanh 10)
  local sid
  for ((sid = 1; sid <= MAX_WORKSPACES; sid++)); do
    args+=(--set "space.$sid" drawing=off)
  done

  local fallback="${INFO:-Desktop}"
  args+=(
    --set paneru.status drawing=on
    --set front_app icon=󰣆 label="$(shorten "$fallback" 46)"
  )
  sketchybar "${args[@]}" >/dev/null 2>&1 || true
}

render_state() {
  local state native_id active_number app title title_label icon
  state="$(paneru query state --json 2>/dev/null)" || {
    render_offline
    return
  }
  jq -e '.version == 1 and (.active | type == "object") and (.virtual_workspaces | type == "array")' \
    >/dev/null 2>&1 <<< "$state" || {
      render_offline
      return
    }

  native_id="$(jq -r '.active.native_workspace_id // empty' <<< "$state")"
  active_number="$(jq -r '.active.virtual_workspace_number // empty' <<< "$state")"
  app="$(jq -r '.active.focused_app_name // empty' <<< "$state")"
  title="$(jq -r '.active.focused_window_title // empty' <<< "$state")"

  [[ -n "$app" ]] || app="${INFO:-Desktop}"
  [[ -n "$title" ]] || title="$app"
  title_label="$(shorten "$title" 46)"
  icon="$(app_icon "$app")"

  local -a present selected window_count app_names
  local number is_active count names
  if [[ -n "$native_id" ]]; then
    while IFS=$'\t' read -r number is_active count names; do
      [[ "$number" =~ ^[0-9]+$ ]] || continue
      (( number >= 1 && number <= MAX_WORKSPACES )) || continue
      present[$number]=1
      selected[$number]="$is_active"
      window_count[$number]="$count"
      app_names[$number]="$names"
    done < <(
      jq -r --argjson native "$native_id" '
        .virtual_workspaces[]
        | select(.native_workspace_id == $native)
        | [
            (.number | tostring),
            (.active | tostring),
            (.windows | length | tostring),
            ([.windows[].app_name | select(length > 0)] | unique | .[0:4] | join("|"))
          ]
        | @tsv
      ' <<< "$state"
    )
  fi

  local args=(--animate tanh 10 --set paneru.status drawing=off)
  args+=(--set front_app icon="$icon" icon.color="$BLUE" label="$title_label")

  local sid show focused count_value names_value icons app_name
  local -a apps
  for ((sid = 1; sid <= MAX_WORKSPACES; sid++)); do
    show=off
    focused="${selected[$sid]:-false}"
    count_value="${window_count[$sid]:-0}"
    [[ "$sid" == "$active_number" ]] && focused=true
    if [[ -n "${present[$sid]:-}" ]] && { [[ "$focused" == true ]] || (( count_value > 0 )); }; then
      show=on
    fi

    icons=""
    names_value="${app_names[$sid]:-}"
    if [[ -n "$names_value" ]]; then
      IFS='|' read -r -a apps <<< "$names_value"
      for app_name in "${apps[@]}"; do
        [[ -n "$app_name" ]] || continue
        icons+="$(app_icon "$app_name") "
      done
      icons="${icons% }"
    fi

    if [[ "$focused" == true ]]; then
      args+=(
        --set "space.$sid"
        drawing="$show"
        icon="$sid"
        icon.color="$BG"
        label="$icons"
        label.drawing="$([[ -n "$icons" ]] && printf on || printf off)"
        label.color="$BG"
        background.drawing=on
        background.color="$BLUE"
        background.border_color="$BLUE"
      )
    else
      args+=(
        --set "space.$sid"
        drawing="$show"
        icon="$sid"
        icon.color="$FG"
        label="$icons"
        label.drawing="$([[ -n "$icons" ]] && printf on || printf off)"
        label.color="$MUTED"
        background.drawing=on
        background.color="$SURFACE"
        background.border_color="$BORDER"
      )
    fi
  done

  sketchybar "${args[@]}" >/dev/null 2>&1 || true
}

refresh() {
  touch "$PENDING_FILE"
  mkdir "$LOCK_DIR" 2>/dev/null || return 0
  trap 'rmdir "$LOCK_DIR" 2>/dev/null || true' EXIT INT TERM HUP

  while [[ -f "$PENDING_FILE" ]]; do
    rm -f "$PENDING_FILE"
    render_state
  done
}

case "${1:-refresh}" in
  click)
    workspace="${2:-1}"
    if [[ "${MODIFIER:-}" == *shift* ]]; then
      paneru send-cmd window virtualmovenum "$workspace" >/dev/null 2>&1 || true
    else
      paneru send-cmd window virtualnum "$workspace" >/dev/null 2>&1 || true
    fi
    sketchybar --trigger paneru_update >/dev/null 2>&1 || true
    ;;
  refresh | *)
    refresh
    ;;
esac

