#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

toggle_bluetooth() {
  command -v blueutil >/dev/null 2>&1 || {
    open_settings "x-apple.systempreferences:com.apple.BluetoothSettings"
    return 0
  }

  power="$(blueutil --power 2>/dev/null || blueutil -p 2>/dev/null)"
  if [ "$power" = "1" ]; then
    blueutil --power 0 >/dev/null 2>&1 || blueutil -p 0 >/dev/null 2>&1 || true
  else
    blueutil --power 1 >/dev/null 2>&1 || blueutil -p 1 >/dev/null 2>&1 || true
  fi
}

if [ "${1:-}" = "settings" ]; then
  open_settings "x-apple.systempreferences:com.apple.BluetoothSettings"
  exit 0
fi

if [ "${1:-}" = "toggle" ]; then
  toggle_bluetooth
  sleep 1
fi

if ! command -v blueutil >/dev/null 2>&1; then
  sketchybar --set "${NAME:-bluetooth}" \
    icon=󰂯 \
    icon.color="$MUTED" \
    label.drawing=off \
    label.color="$MUTED" \
    --set bluetooth.popup.status \
      icon=󰂯 \
      icon.color="$MUTED" \
      label="Install blueutil for toggle state" >/dev/null 2>&1 || true
  exit 0
fi

power="$(blueutil --power 2>/dev/null || blueutil -p 2>/dev/null)"

if [ "$power" != "1" ]; then
  sketchybar --set "${NAME:-bluetooth}" \
    icon=󰂲 \
    icon.color="$MUTED" \
    label="Off" \
    label.drawing=on \
    label.color="$MUTED" \
    --set bluetooth.popup.status \
      icon=󰂲 \
      icon.color="$MUTED" \
      label="Bluetooth off" >/dev/null 2>&1 || true
  exit 0
fi

connected="$(blueutil --connected 2>/dev/null)"
count="$(printf '%s\n' "$connected" | awk '/connected/ { c++ } END { print c + 0 }')"
first="$(printf '%s\n' "$connected" | sed -n 's/.*name: "\([^"]*\)".*/\1/p' | head -n 1)"

if [ "$count" -gt 0 ]; then
  label="$(shorten "${first:-$count device}" 14)"
  [ "$count" -gt 1 ] && label="$label +$((count - 1))"
  color="$BLUE"
  label_drawing=on
else
  label="On"
  color="$SUBTEXT"
  label_drawing=off
fi

sketchybar --set "${NAME:-bluetooth}" \
  icon=󰂯 \
  icon.color="$color" \
  label="$label" \
  label.drawing="$label_drawing" \
  label.color="$SUBTEXT" \
  --set bluetooth.popup.status \
    icon=󰂯 \
    icon.color="$color" \
    label="Bluetooth ${label}" >/dev/null 2>&1 || true
