#!/usr/bin/env python3
"""Compatibility entry point for stable project identity."""

import sys

from memory import main


if __name__ == "__main__":
    raise SystemExit(main(["repo-id", *sys.argv[1:]]))
