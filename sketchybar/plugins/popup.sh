#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

parent="$1"
action="${2:-toggle}"
items="wifi bluetooth volume battery clock"

[ -n "$parent" ] || exit 0

for item in $items; do
  [ "$item" = "$parent" ] || sketchybar --set "$item" popup.drawing=off >/dev/null 2>&1 || true
done

case "$action" in
  on|off)
    sketchybar --set "$parent" popup.drawing="$action" >/dev/null 2>&1 || true
    ;;
  *)
    sketchybar --set "$parent" popup.drawing=toggle >/dev/null 2>&1 || true
    ;;
esac

case "$parent" in
  wifi|bluetooth|volume|battery|clock)
    "$PLUGIN_DIR/$parent.sh" >/dev/null 2>&1 || true
    ;;
esac
