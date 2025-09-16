#!/usr/bin/env bash
set -euo pipefail

EXTRA=(--extra-experimental-features "nix-command flakes")
ACCEPT=(--accept-flake-config)

FLAKE_DIR="${1:-./nixenv}"
ATTR="${2:-workstation}"        # flake attr you want to install
ENTRY_NAME="$ATTR"              # profile entry name == attr name

# Resolve absolute path for stable path: URI
if command -v realpath >/dev/null 2>&1; then
  FLAKE_ABS="$(realpath -m "$FLAKE_DIR")"
else
  FLAKE_ABS="$(cd "$(dirname "$FLAKE_DIR")" && pwd)/$(basename "$FLAKE_DIR")"
fi

PKG="path:$FLAKE_ABS#$ATTR"

# NOTE:
# - 'install' will create an entry named like the attr (workstation).
# - 'upgrade ENTRY' upgrades just that entry by name.
if nix profile list "${EXTRA[@]}" | grep -qE "^Name:\s*$ENTRY_NAME$"; then
  echo "Upgrading existing entry: $ENTRY_NAME"
  nix profile upgrade "$ENTRY_NAME" "${EXTRA[@]}" "${ACCEPT[@]}"
else
  echo "Installing new entry: $ENTRY_NAME from $PKG"
  nix profile install "$PKG" "${EXTRA[@]}" "${ACCEPT[@]}"
fi

echo
nix profile list "${EXTRA[@]}"

