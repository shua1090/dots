#!/usr/bin/env bash

source "$(dirname "$0")/helpers.sh"

if [[ "${1:-}" == settings ]]; then
  open_settings "x-apple.systempreferences:com.apple.Battery-Settings.extension"
  exit 0
fi

battery="$(pmset -g batt 2>/dev/null)"
percentage="$(grep -Eo '[0-9]+%' <<< "$battery" | head -n 1 | tr -d '%')"
state="$(awk -F'; *' '/InternalBattery/ { print $2; exit }' <<< "$battery")"

[[ "$percentage" =~ ^[0-9]+$ ]] || {
  sketchybar --set "${NAME:-battery}" drawing=off
  exit 0
}

case "$percentage" in
  9[0-9] | 100) icon= ;;
  [6-8][0-9]) icon= ;;
  [3-5][0-9]) icon= ;;
  [1-2][0-9]) icon= ;;
  *) icon= ;;
esac

color="$GREEN"
if grep -qi 'AC Power\|charging\|charged' <<< "$battery"; then
  icon=
elif (( percentage < 20 )); then
  color="$RED"
elif (( percentage < 35 )); then
  color="$YELLOW"
fi

sketchybar --set "${NAME:-battery}" \
  drawing=on \
  icon="$icon" \
  icon.color="$color" \
  label="${percentage}%" \
  label.color="$FG"
