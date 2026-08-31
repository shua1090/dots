#!/usr/bin/env bash

source "$(dirname "$0")/helpers.sh"

networksetup=/usr/sbin/networksetup

wifi_device() {
  "$networksetup" -listallhardwareports 2>/dev/null | awk '
    /Hardware Port: Wi-Fi|Hardware Port: AirPort/ { found = 1; next }
    found && /Device:/ { print $2; exit }
  '
}

if [[ "${1:-}" == settings ]]; then
  open_settings "x-apple.systempreferences:com.apple.Wi-Fi-Settings.extension"
  exit 0
fi

device="$(wifi_device)"
if [[ -z "$device" ]]; then
  sketchybar --set "${NAME:-wifi}" icon=󰖪 icon.color="$MUTED" label="No Wi-Fi"
  exit 0
fi

power="$("$networksetup" -getairportpower "$device" 2>/dev/null | awk '{ print $NF }')"
if [[ "$power" == Off ]]; then
  sketchybar --set "${NAME:-wifi}" icon=󰖪 icon.color="$MUTED" label="Off"
  exit 0
fi

ssid="$("$networksetup" -getairportnetwork "$device" 2>/dev/null \
  | sed 's/^Current Wi-Fi Network: //')"
case "$ssid" in
  "" | "You are not associated with an AirPort network." | AuthorizationCreate* | *failed:*)
    if ifconfig "$device" 2>/dev/null | grep -q 'status: active'; then
      ssid="Online"
      color="$CYAN"
    else
      ssid="Offline"
      color="$YELLOW"
    fi
    ;;
  *) color="$CYAN" ;;
esac

sketchybar --set "${NAME:-wifi}" \
  icon=󰖩 \
  icon.color="$color" \
  label="$(shorten "$ssid" 16)" \
  label.color="$FG"
