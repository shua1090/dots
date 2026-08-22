#!/usr/bin/env python3
"""Fail-open Factory hook adapter for project-memory."""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path


MEMORY = Path(__file__).with_name("memory.py")
MEMORY_WRITE_PATTERN = re.compile(
    r"memory\.py.*\b(?:remember|archive)\b|"
    r"memory\.py.*\bdigest\b.*(?:^|\s)--refresh(?:\s|$)|"
    r"memory\.py.*\bcontext\b"
)


def pretool_decision(data: dict) -> int:
    """Ask before commands that can mutate the project-memory vault."""
    tool_input = data.get("tool_input") or {}
    command = str(tool_input.get("command") or "")
    if not MEMORY_WRITE_PATTERN.search(command):
        return 0

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "ask",
            "permissionDecisionReason": (
                "This command can write or refresh project memory. "
                "Approve only if the content is permitted to enter the shared vault."
            ),
        },
        "suppressOutput": True,
    }))
    return 0


def output_context(event: str, context: str) -> None:
    if event == "SessionStart":
        payload = {
            "hookSpecificOutput": {
                "hookEventName": event,
                "additionalContext": context,
            },
            "suppressOutput": True,
        }
    else:
        payload = {"additionalContext": context, "suppressOutput": True}
    print(json.dumps(payload))


def main() -> int:
    try:
        data = json.load(sys.stdin)
        event = data.get("hook_event_name", "")
        if event == "PreToolUse":
            return pretool_decision(data)
        cwd = data.get("cwd") or "."
        command = [sys.executable, str(MEMORY), "context", "--cwd", cwd]
        if event == "UserPromptSubmit":
            prompt = str(data.get("prompt") or "").strip()
            if not prompt:
                return 0
            command.extend(["--prompt", prompt, "--limit", "8"])
        elif event != "SessionStart":
            return 0
        proc = subprocess.run(command, capture_output=True, text=True, timeout=8, check=False)
        context = proc.stdout.strip()
        if proc.returncode == 0 and context:
            output_context(event, context)
    except Exception:
        # Memory must never prevent Droid from processing a prompt or session.
        pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
