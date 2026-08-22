#!/usr/bin/env bash

source "$(dirname "$0")/helpers.sh"

if [[ "${1:-}" == click ]]; then
  if [[ "${BUTTON:-left}" == right ]]; then
    open_settings "x-apple.systempreferences:com.apple.Sound-Settings.extension"
    exit 0
  fi
  /usr/bin/osascript -e 'set volume output muted not (output muted of (get volume settings))' \
    >/dev/null 2>&1 || true
fi

volume="${INFO:-}"
[[ "$volume" =~ ^[0-9]+$ ]] \
  || volume="$(/usr/bin/osascript -e 'output volume of (get volume settings)' 2>/dev/null || true)"
muted="$(/usr/bin/osascript -e 'output muted of (get volume settings)' 2>/dev/null || true)"

if [[ "$muted" == true ]] || [[ "$volume" == 0 ]]; then
  icon=󰖁
  color="$MUTED"
elif (( volume < 30 )); then
  icon=󰕿
  color="$MAGENTA"
elif (( volume < 60 )); then
  icon=󰖀
  color="$MAGENTA"
else
  icon=󰕾
  color="$MAGENTA"
fi

[[ "$volume" =~ ^[0-9]+$ ]] || volume="--"
sketchybar --set "${NAME:-volume}" \
  icon="$icon" \
  icon.color="$color" \
  label="${volume}%" \
  label.color="$FG"
