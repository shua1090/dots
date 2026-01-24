#!/usr/bin/env bash
# dbox v2: tiny helper for Distrobox
set -euo pipefail

DEFAULT_IMAGE="${DBOX_DEFAULT_IMAGE:-ubuntu:24.04}"

has() { command -v "$1" >/dev/null 2>&1; }
runtime() { if has podman; then echo podman; elif has docker; then echo docker; else echo "No podman or docker found." >&2; exit 1; fi; }
pause() { read -rp "Press Enter to continue..."; }
header() { echo; echo "== $1 =="; }

list_boxes() { distrobox list || true; }

# Parse NAME column reliably from the "ID | NAME | STATUS | IMAGE" table
names_only() {
  # --no-color avoids ANSI; cut grabs 2nd '|' field; sed trims; tail skips header
  distrobox list --no-color 2>/dev/null \
    | tail -n +2 \
    | cut -d '|' -f2 \
    | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//;' \
    | awk 'NF>0'
}

choose_box() {
  local names; names="$(names_only)"
  if [[ -z "$names" ]]; then echo "No distroboxes found." >&2; return 1; fi

  echo "Available boxes:"
  nl -ba <<<"$names"
  echo;
  read -rp "Pick number OR type a name: " sel

  # If it's a number, map to that line; else treat as name
  if [[ "$sel" =~ ^[0-9]+$ ]]; then
    local name; name="$(sed -n "${sel}p" <<<"$names" || true)"
    [[ -z "$name" ]] && { echo "Invalid selection." >&2; return 1; }
    echo "$name"
  else
    # Validate typed name exists
    if grep -Fxq "$sel" <<<"$names"; then echo "$sel"; else
      echo "No such distrobox: $sel" >&2; return 1
    fi
  fi
}

op_create() {
  header "Create"
  read -rp "Name (e.g. ubuntu-dev): " NAME; NAME="${NAME:-ubuntu-dev}"
  read -rp "Image [${DEFAULT_IMAGE}]: " IMAGE; IMAGE="${IMAGE:-$DEFAULT_IMAGE}"
  read -rp "Mount a host path? (blank to skip, eg: $(pwd):/work): " VOL
  read -rp "Extra create flags? (blank to skip, eg: --root --init-hooks 'apt -y update && apt -y install build-essential'): " EXTRA

  local cmd=(distrobox create -n "$NAME" -i "$IMAGE")
  [[ -n "${VOL}" ]] && cmd+=(--volume "$VOL")
  [[ -n "${EXTRA}" ]] && cmd+=($EXTRA)

  echo "> ${cmd[*]}"
  "${cmd[@]}"

  echo; echo "Created '$NAME'. To enter: distrobox enter $NAME"
}

op_enter() {
  header "Enter"
  local NAME; NAME="$(choose_box)" || return 1
  read -rp "Run a command inside (blank for shell): " RUN
  if [[ -n "$RUN" ]]; then
    distrobox enter "$NAME" -- bash -lc "$RUN"
  else
    distrobox enter "$NAME"
  fi
}

op_exec() {
  header "Exec"
  local NAME; NAME="$(choose_box)" || return 1
  read -rp "Command to run: " CMD
  [[ -z "$CMD" ]] && { echo "No command."; return 1; }
  distrobox enter "$NAME" -- bash -lc "$CMD"
}

op_stop() {
  header "Stop"
  echo "1) Stop one  2) Stop all"
  read -rp "Choose: " c
  case "$c" in
    1) local NAME; NAME="$(choose_box)" || return 1; distrobox stop "$NAME" ;;
    2) distrobox stop --all -Y ;;
    *) echo "Invalid";;
  esac
}

op_rm() {
  header "Remove"
  echo "1) Remove one  2) Remove all"
  read -rp "Choose: " c
  case "$c" in
    1)
      local NAME; NAME="$(choose_box)" || return 1
      read -rp "Force? [y/N]: " f
      if [[ "$f" =~ ^[Yy]$ ]]; then distrobox rm "$NAME" --force
      else distrobox rm "$NAME"; fi
      ;;
    2)
      read -rp "This deletes ALL boxes. Continue? [y/N]: " y
      [[ "$y" =~ ^[Yy]$ ]] && distrobox rm --all --force || echo "Cancelled."
      ;;
    *) echo "Invalid";;
  esac
}

op_prune_images() {
  header "Prune container images (reclaim disk)"
  local rt; rt="$(runtime)"
  echo "Using runtime: $rt"
  read -rp "Run '$rt image prune -a'? [y/N]: " y
  [[ "$y" =~ ^[Yy]$ ]] && $rt image prune -a || echo "Skipped."
}

menu() {
  while true; do
    echo
    echo "dbox — Distrobox helper"
    echo "[c] create   [e] enter   [x] exec   [l] list"
    echo "[t] stop     [r] remove  [p] prune-images"
    echo "[q] quit"
    read -rp "> " a
    case "$a" in
      c) op_create; pause;;
      e) op_enter; pause;;
      x) op_exec; pause;;
      l) header "List"; list_boxes; pause;;
      t) op_stop; pause;;
      r) op_rm; pause;;
      p) op_prune_images; pause;;
      q) exit 0;;
      *) echo "Unknown choice";;
    esac
  done
}

menu

