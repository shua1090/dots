#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

if [ "${1:-}" = "settings" ]; then
  open_settings "x-apple.systempreferences:com.apple.Sound-Settings.extension"
  exit 0
fi

volume="${INFO:-}"

if [ -z "$volume" ]; then
  volume="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || true)"
fi

case "$volume" in
  ""|*[!0-9]*)
    icon=󰖁
    label="--"
    color="$MUTED"
    ;;
  0)
    icon=󰖁
    label="0%"
    color="$MUTED"
    ;;
  [1-9]|[1-2][0-9])
    icon=󰕿
    label="${volume}%"
    color="$SUBTEXT"
    ;;
  [3-5][0-9])
    icon=󰖀
    label="${volume}%"
    color="$TEXT"
    ;;
  *)
    icon=󰕾
    label="${volume}%"
    color="$TEXT"
    ;;
esac

sketchybar --set "${NAME:-volume}" \
  icon="$icon" \
  icon.color="$color" \
  label="$label" \
  label.color="$SUBTEXT" \
  --set volume.popup.status \
    icon="$icon" \
    icon.color="$color" \
    label="Volume $label" >/dev/null 2>&1 || true
