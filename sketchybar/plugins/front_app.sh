#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"
. "$(dirname "$0")/app_icon.sh"

app="${INFO:-}"

if [ -z "$app" ] && command -v omniwmctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  app="$(omniwmctl query focused-window --format json 2>/dev/null \
    | jq -r '.result.payload.app.name? // .result.payload.appName? // .result.payload.app? // empty' 2>/dev/null)"
fi

[ -n "$app" ] || app="Desktop"

icon="$(app_icon "$app")"
label="$(shorten "$app" 34)"

sketchybar --set "${NAME:-front_app}" \
  icon="$icon" \
  label="$label"
