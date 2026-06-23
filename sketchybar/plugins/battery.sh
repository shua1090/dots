#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

if [ "${1:-}" = "settings" ]; then
  open_settings "x-apple.systempreferences:com.apple.Battery-Settings.extension"
  exit 0
fi

battery="$(pmset -g batt 2>/dev/null)"
percentage="$(printf '%s\n' "$battery" | grep -Eo '[0-9]+%' | head -n 1 | tr -d '%')"
state="$(printf '%s\n' "$battery" | awk -F'; *' '/InternalBattery/ { print $2; exit }')"
source="$(printf '%s\n' "$battery" | head -n 1)"

[ -n "$percentage" ] || exit 0

case "$percentage" in
  9[0-9]|100) icon="" ;;
  [6-8][0-9]) icon="" ;;
  [3-5][0-9]) icon="" ;;
  [1-2][0-9]) icon="" ;;
  *) icon="" ;;
esac

color="$TEXT"
if printf '%s %s' "$source" "$state" | grep -qi 'AC Power\|charging\|charged'; then
  icon=""
  color="$GREEN"
elif [ "$percentage" -lt 20 ]; then
  color="$RED"
elif [ "$percentage" -lt 35 ]; then
  color="$AMBER"
fi

sketchybar --set "${NAME:-battery}" \
  icon="$icon" \
  icon.color="$color" \
  label="${percentage}%" \
  --set battery.popup.status \
    icon="$icon" \
    icon.color="$color" \
    label="${percentage}% ${state:-battery}" >/dev/null 2>&1 || true
