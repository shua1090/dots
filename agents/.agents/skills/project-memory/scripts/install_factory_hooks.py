#!/usr/bin/env python3
"""Install Factory discovery and context hooks for project-memory."""

from __future__ import annotations

import argparse
import json
import os
import shlex
import sys
from pathlib import Path


EVENTS = ("SessionStart", "UserPromptSubmit")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--path", type=Path, default=Path("~/.factory/hooks.json").expanduser())
    result.add_argument(
        "--factory-skill-path",
        type=Path,
        default=Path("~/.factory/skills/project-memory").expanduser(),
    )
    result.add_argument(
        "--canonical-skill-path",
        type=Path,
        default=Path("~/.agents/skills/project-memory").expanduser(),
    )
    result.add_argument("--dry-run", action="store_true")
    return result


def install_skill_link(source: Path, target: Path, dry_run: bool) -> str:
    source = source.expanduser().absolute()
    target = target.expanduser().absolute()
    if not (source / "SKILL.md").is_file():
        raise ValueError(f"canonical skill is missing: {source / 'SKILL.md'}")

    if target.is_symlink():
        if target.resolve() == source.resolve():
            return f"Factory skill link already installed at {target}"
        raise ValueError(f"refusing to replace conflicting symlink: {target}")
    if target.exists():
        raise ValueError(f"refusing to replace existing Factory skill: {target}")
    if dry_run:
        return f"Would link {target} -> {source}"

    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source, target_is_directory=True)
    return f"Linked Factory skill {target} -> {source}"


def main() -> int:
    args = parser().parse_args()
    path = args.path.expanduser()
    if path.exists():
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            raise ValueError(f"{path} must contain a JSON object")
    else:
        data = {}

    hook = Path(__file__).with_name("factory_hook.py").resolve()
    command = f"{shlex.quote(sys.executable)} {shlex.quote(str(hook))}"
    marker = "factory_hook.py"
    for event in EVENTS:
        groups = data.setdefault(event, [])
        if not isinstance(groups, list):
            raise ValueError(f"{event} in {path} must be an array")
        retained_groups = []
        for group in groups:
            if not isinstance(group, dict) or not isinstance(group.get("hooks"), list):
                retained_groups.append(group)
                continue
            retained_hooks = [
                item for item in group["hooks"]
                if not (isinstance(item, dict) and marker in str(item.get("command", "")))
            ]
            if retained_hooks:
                group["hooks"] = retained_hooks
                retained_groups.append(group)
        retained_groups.append({
            "matcher": "*",
            "hooks": [{"type": "command", "command": command, "timeout": 10}],
        })
        data[event] = retained_groups

    pretool_groups = data.setdefault("PreToolUse", [])
    if not isinstance(pretool_groups, list):
        raise ValueError(f"PreToolUse in {path} must be an array")
    retained_pretool_groups = []
    for group in pretool_groups:
        if not isinstance(group, dict) or not isinstance(group.get("hooks"), list):
            retained_pretool_groups.append(group)
            continue
        retained_hooks = [
            item for item in group["hooks"]
            if not (isinstance(item, dict) and marker in str(item.get("command", "")))
        ]
        if retained_hooks:
            group["hooks"] = retained_hooks
            retained_pretool_groups.append(group)
    retained_pretool_groups.append({
        "matcher": "Execute",
        "hooks": [{"type": "command", "command": command, "timeout": 10}],
    })
    data["PreToolUse"] = retained_pretool_groups

    link_result = install_skill_link(
        args.canonical_skill_path, args.factory_skill_path, args.dry_run
    )
    rendered = json.dumps(data, indent=2) + "\n"
    if args.dry_run:
        print(link_result, file=sys.stderr)
        print(rendered, end="")
        return 0
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    temporary.write_text(rendered, encoding="utf-8")
    temporary.chmod(0o600)
    temporary.replace(path)
    print(link_result)
    print(f"Installed Factory project-memory hooks in {path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"install_factory_hooks: {exc}", file=sys.stderr)
        raise SystemExit(1)
