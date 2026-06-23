#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

networksetup="/usr/sbin/networksetup"

wifi_device() {
  if [ -n "${SKETCHYBAR_WIFI_DEVICE:-}" ]; then
    printf '%s' "$SKETCHYBAR_WIFI_DEVICE"
    return 0
  fi

  "$networksetup" -listallhardwareports 2>/dev/null | awk '
    /Hardware Port: Wi-Fi|Hardware Port: AirPort/ { found = 1; next }
    found && /Device:/ { print $2; exit }
  '

  command -v /usr/bin/jq >/dev/null 2>&1 || return 0
  system_profiler SPAirPortDataType -json 2>/dev/null \
    | /usr/bin/jq -r '.SPAirPortDataType[]?.spairport_airport_interfaces[]?._name // empty' 2>/dev/null \
    | head -n 1
}

wifi_ssid_from_profiler() {
  command -v /usr/bin/jq >/dev/null 2>&1 || return 0

  system_profiler SPAirPortDataType -json 2>/dev/null \
    | /usr/bin/jq --arg device "$1" -r '
        .SPAirPortDataType[]?.spairport_airport_interfaces[]?
        | select(._name == $device)
        | .spairport_current_network_information?._name // empty
      ' 2>/dev/null \
    | head -n 1
}

wifi_power() {
  "$networksetup" -getairportpower "$1" 2>/dev/null | awk '{ print $NF }'
}

wifi_ssid() {
  ssid="$(wifi_ssid_from_profiler "$1")"

  if [ -z "$ssid" ]; then
    ssid="$("$networksetup" -getairportnetwork "$1" 2>/dev/null \
      | sed 's/^Current Wi-Fi Network: //')"
  fi

  case "$ssid" in
    AuthorizationCreate*|*failed:*)
      ssid=""
      ;;
  esac

  printf '%s' "$ssid"
}

wifi_is_online() {
  ifconfig "$1" 2>/dev/null | awk '
    /status: active/ { active = 1 }
    /^[[:space:]]*inet / { ipv4 = 1 }
    END { exit !(active && ipv4) }
  '
}

toggle_wifi() {
  device="$1"
  [ -n "$device" ] || return 0

  power="$(wifi_power "$device")"
  if [ "$power" = "On" ]; then
    "$networksetup" -setairportpower "$device" off >/dev/null 2>&1 || true
  else
    "$networksetup" -setairportpower "$device" on >/dev/null 2>&1 || true
  fi
}

device="$(wifi_device)"

if [ "${1:-}" = "settings" ]; then
  open_settings "x-apple.systempreferences:com.apple.Wi-Fi-Settings.extension"
  exit 0
fi

if [ "${1:-}" = "toggle" ]; then
  toggle_wifi "$device"
  sleep 1
fi

if [ -z "$device" ]; then
  sketchybar --set "${NAME:-wifi}" \
    icon=󰖪 \
    icon.color="$MUTED" \
    label="No Wi-Fi" \
    label.color="$MUTED" \
    --set wifi.popup.status \
      icon=󰖪 \
      icon.color="$MUTED" \
      label="No Wi-Fi interface" >/dev/null 2>&1 || true
  exit 0
fi

power="$(wifi_power "$device")"

if [ "$power" = "Off" ]; then
  sketchybar --set "${NAME:-wifi}" \
    icon=󰖪 \
    icon.color="$MUTED" \
    label="Off" \
    label.color="$MUTED" \
    --set wifi.popup.status \
      icon=󰖪 \
      icon.color="$MUTED" \
      label="Wi-Fi off" >/dev/null 2>&1 || true
  exit 0
fi

ssid="$(wifi_ssid "$device")"

case "$ssid" in
  "" | "You are not associated with an AirPort network.")
    if wifi_is_online "$device"; then
      icon=󰖩
      label="Online"
      color="$GREEN"
    else
      icon=󰖪
      label="No network"
      color="$AMBER"
    fi
    ;;
  *)
    icon=󰖩
    label="$(shorten "$ssid" 18)"
    color="$GREEN"
    ;;
esac

sketchybar --set "${NAME:-wifi}" \
  icon="$icon" \
  icon.color="$color" \
  label="$label" \
  label.color="$SUBTEXT" \
  --set wifi.popup.status \
    icon="$icon" \
    icon.color="$color" \
    label="$label" >/dev/null 2>&1 || true
