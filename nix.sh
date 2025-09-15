#!/usr/bin/env bash
set -euo pipefail

EXTRA=(--extra-experimental-features "nix-command flakes")

# Config (change if you rename things later)
FLAKE_DIR="${1:-./nixenv}"
ATTR="${2:-workstation}"
ENTRY_NAME="nixenv"   # the profile entry name to manage

# Resolve absolute path (stable for path: URIs)
if command -v realpath >/dev/null 2>&1; then
  FLAKE_ABS="$(realpath -m "$FLAKE_DIR")"
else
  FLAKE_ABS="$(cd "$(dirname "$FLAKE_DIR")" && pwd)/$(basename "$FLAKE_DIR")"
fi

PKG="path:$FLAKE_ABS#$ATTR"

# See if the entry already exists
if nix profile list "${EXTRA[@]}" | grep -qE "^Name:\s*$ENTRY_NAME$"; then
  echo "Upgrading existing entry: $ENTRY_NAME"
  nix profile upgrade "$ENTRY_NAME" "${EXTRA[@]}"
else
  echo "Installing new entry: $ENTRY_NAME from $PKG"
  nix profile add "$PKG" "${EXTRA[@]}"
fi

echo
nix profile list "${EXTRA[@]}"
