#!/usr/bin/env python3
"""Install Factory discovery hooks and links for the shared skill package."""

from __future__ import annotations

import argparse
import json
import os
import shlex
import sys
from datetime import datetime
from pathlib import Path


EVENTS = ("SessionStart", "UserPromptSubmit")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(description=__doc__)
    result.add_argument("--path", type=Path, default=Path("~/.factory/hooks.json").expanduser())
    result.add_argument(
        "--factory-skills-root",
        type=Path,
        default=Path("~/.factory/skills").expanduser(),
        help="Factory's personal skill directory",
    )
    result.add_argument(
        "--codex-skills-root",
        type=Path,
        default=Path("~/.codex/skills").expanduser(),
        help="Codex's personal skill directory",
    )
    result.add_argument(
        "--canonical-skills-root",
        type=Path,
        default=Path("~/.agents/skills").expanduser(),
        help="Canonical cross-agent skill directory",
    )
    # Keep these aliases for callers that used the original project-memory-only
    # installer. They are resolved into the roots above when supplied.
    result.add_argument(
        "--factory-skill-path",
        type=Path,
        default=None,
    )
    result.add_argument(
        "--canonical-skill-path",
        type=Path,
        default=None,
    )
    result.add_argument(
        "--adopt-existing",
        action="store_true",
        help="Replace identical existing skill copies with canonical links",
    )
    result.add_argument("--dry-run", action="store_true")
    return result


def _ignored(path: Path) -> bool:
    return "__pycache__" in path.parts or path.suffix == ".pyc"


def _files(root: Path) -> dict[str, bytes]:
    result = {}
    for path in root.rglob("*"):
        if path.is_file() and not _ignored(path.relative_to(root)):
            result[str(path.relative_to(root))] = path.read_bytes()
    return result


def identical_skill(source: Path, target: Path) -> bool:
    return target.is_dir() and _files(source) == _files(target)


def install_skill_link(
    source: Path, target: Path, dry_run: bool, adopt_existing: bool = False
) -> str:
    source = source.expanduser().absolute()
    target = target.expanduser().absolute()
    if not (source / "SKILL.md").is_file():
        raise ValueError(f"canonical skill is missing: {source / 'SKILL.md'}")

    if target.is_symlink():
        if target.resolve() == source.resolve():
            return f"Skill link already installed at {target}"
        raise ValueError(f"refusing to replace conflicting symlink: {target}")
    if target.exists():
        if not adopt_existing:
            return f"Skipped existing Factory skill {target} (use --adopt-existing to link it)"
        if not identical_skill(source, target):
            return f"Skipped non-identical Factory skill {target}"
        backup = target.parent / ".skill-backups" / (
            f"{target.name}-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        )
        if dry_run:
            return f"Would adopt {target} -> {source} (backup: {backup})"
        backup.parent.mkdir(parents=True, exist_ok=True)
        target.rename(backup)
        target.symlink_to(source, target_is_directory=True)
        return f"Adopted skill link {target} -> {source} (backup: {backup})"
    if dry_run:
        return f"Would link {target} -> {source}"

    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source, target_is_directory=True)
    return f"Linked skill {target} -> {source}"


def canonical_skills(root: Path) -> list[Path]:
    if not root.is_dir():
        raise ValueError(f"canonical skills directory is missing: {root}")
    return sorted(
        (path for path in root.iterdir() if path.is_dir() and (path / "SKILL.md").is_file()),
        key=lambda path: path.name,
    )


def main() -> int:
    args = parser().parse_args()
    path = args.path.expanduser()
    canonical_root = args.canonical_skills_root.expanduser()
    factory_root = args.factory_skills_root.expanduser()
    codex_root = args.codex_skills_root.expanduser()
    if args.canonical_skill_path is not None:
        canonical_root = args.canonical_skill_path.expanduser().parent
    if args.factory_skill_path is not None:
        factory_root = args.factory_skill_path.expanduser().parent
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

    links = []
    for source in canonical_skills(canonical_root):
        links.append(
            install_skill_link(
                source,
                codex_root / source.name,
                args.dry_run,
                args.adopt_existing,
            )
        )
        links.append(
            install_skill_link(
                source,
                factory_root / source.name,
                args.dry_run,
                args.adopt_existing,
            )
        )
    rendered = json.dumps(data, indent=2) + "\n"
    if args.dry_run:
        for link in links:
            print(link, file=sys.stderr)
        print(rendered, end="")
        return 0
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f".{path.name}.{os.getpid()}.tmp")
    temporary.write_text(rendered, encoding="utf-8")
    temporary.chmod(0o600)
    temporary.replace(path)
    for link in links:
        print(link)
    print(f"Installed Factory hooks and skill links in {path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, json.JSONDecodeError) as exc:
        print(f"install_factory_hooks: {exc}", file=sys.stderr)
        raise SystemExit(1)
