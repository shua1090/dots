#!/usr/bin/env sh

. "$(dirname "$0")/helpers.sh"

PID_FILE="${TMPDIR:-/tmp}/sketchybar-omniwm-watch-${USER}.pid"
CHANNELS="active-workspace,workspace-bar,windows-changed,display-changed,layout-changed"

start_watch() {
  command -v omniwmctl >/dev/null 2>&1 || exit 0

  if [ -f "$PID_FILE" ]; then
    old_pid="$(cat "$PID_FILE" 2>/dev/null)"
    if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
      kill "$old_pid" 2>/dev/null || true
    fi
  fi

  (
    child_pid=""
    trap '[ -n "$child_pid" ] && kill "$child_pid" 2>/dev/null; exit 0' TERM INT

    while :; do
      omniwmctl watch "$CHANNELS" --exec "$0" trigger &
      child_pid="$!"
      wait "$child_pid"
      child_pid=""
      sleep 2
    done
  ) &

  printf '%s\n' "$!" > "$PID_FILE"
}

case "${1:-start}" in
  start)
    start_watch
    ;;
  trigger)
    "$PLUGIN_DIR/omni_workspaces.sh" refresh >/dev/null 2>&1
    "$PLUGIN_DIR/front_app.sh" >/dev/null 2>&1
    ;;
esac
