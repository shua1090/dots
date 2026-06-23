#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

if [ "${1:-}" = "calendar" ]; then
  /usr/bin/open -a Calendar >/dev/null 2>&1
  exit 0
fi

time_label="$(date '+%a %b %d  %H:%M')"
date_label="$(date '+%A, %B %d')"

sketchybar --set "${NAME:-clock}" label="$time_label" \
  --set clock.popup.date label="$date_label" >/dev/null 2>&1 || true
