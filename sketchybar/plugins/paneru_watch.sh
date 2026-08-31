#!/usr/bin/env bash

source "$(dirname "$0")/helpers.sh"

PID_FILE="${TMPDIR:-/tmp}/sketchybar-paneru-watch-${UID}.pid"
subscriber_pid=""

cleanup() {
  if [[ -n "$subscriber_pid" ]]; then
    kill "$subscriber_pid" >/dev/null 2>&1 || true
  fi
  if [[ -f "$PID_FILE" ]] && [[ "$(<"$PID_FILE")" == "$$" ]]; then
    rm -f "$PID_FILE"
  fi
}
trap cleanup EXIT INT TERM HUP

if [[ -f "$PID_FILE" ]]; then
  old_pid="$(<"$PID_FILE")"
  if [[ -n "$old_pid" ]] && [[ "$old_pid" != "$$" ]] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" >/dev/null 2>&1 || true
  fi
fi
printf '%s\n' "$$" > "$PID_FILE"

while :; do
  if ! command -v paneru >/dev/null 2>&1 \
    || ! paneru query active --json >/dev/null 2>&1; then
    sketchybar --trigger paneru_update >/dev/null 2>&1 || true
    sleep 5
    continue
  fi

  sketchybar --trigger paneru_update >/dev/null 2>&1 || true

  paneru subscribe --json 2>/dev/null | while IFS= read -r event; do
    [[ -n "$event" ]] || continue
    case "$(jq -r '.event // empty' <<< "$event" 2>/dev/null)" in
      virtual_workspace_changed | windows_changed | window_focused | window_title_changed | display_changed)
        sketchybar --trigger paneru_update >/dev/null 2>&1 || true
        ;;
    esac
  done &
  subscriber_pid="$!"
  wait "$subscriber_pid" 2>/dev/null || true
  subscriber_pid=""
  sleep 1
done

