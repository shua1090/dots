#!/usr/bin/env python3
"""Local, repository-scoped project memory backed by SQLite FTS5."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import sqlite3
import subprocess
import sys
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable
from urllib.parse import urlsplit


KINDS = (
    "decision", "architecture", "gotcha", "preference", "bug",
    "investigation", "command", "context", "todo",
)
STATUSES = ("active", "superseded", "archived")
DEFAULT_HOME = Path("~/.factory/project-memory").expanduser()
SCHEMA_VERSION = 3


def now() -> str:
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def run_git(cwd: Path, *args: str) -> str | None:
    try:
        proc = subprocess.run(
            ["git", "-C", str(cwd), *args], capture_output=True, text=True,
            timeout=3, check=False,
        )
    except (FileNotFoundError, subprocess.TimeoutExpired):
        return None
    value = proc.stdout.strip()
    return value if proc.returncode == 0 and value else None


def normalize_remote(remote: str) -> str:
    value = remote.strip()
    scp = re.match(r"^(?:[^@/]+@)?([^:/]+):(.+)$", value)
    if scp and "://" not in value:
        host, path = scp.groups()
        return f"{host.lower()}/{path.removesuffix('.git').strip('/')}"
    parsed = urlsplit(value if "://" in value else f"file://{value}")
    if parsed.scheme == "file":
        return str(Path(parsed.path).expanduser().resolve()).removesuffix(".git")
    host = (parsed.hostname or parsed.netloc).lower()
    path = parsed.path.removesuffix(".git").strip("/")
    return f"{host}/{path}"


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return slug[:48] or "project"


@dataclass(frozen=True)
class Repo:
    repo_id: str
    identity_key: str
    display_name: str
    remote_url: str | None
    root_path: str
    branch: str | None
    commit: str | None


def resolve_repo(cwd: str | Path | None = None) -> Repo:
    current = Path(cwd or os.getcwd()).expanduser().resolve()
    root_text = run_git(current, "rev-parse", "--show-toplevel")
    root = Path(root_text).resolve() if root_text else current
    remote = run_git(root, "remote", "get-url", "origin")
    common_dir_text = run_git(root, "rev-parse", "--path-format=absolute", "--git-common-dir")
    common_dir = Path(common_dir_text).resolve() if common_dir_text else None
    primary_root = common_dir.parent if common_dir and common_dir.name == ".git" else root
    identity = f"origin:{normalize_remote(remote)}" if remote else f"root:{primary_root}"
    digest = hashlib.sha256(identity.encode()).hexdigest()[:16]
    remote_name = normalize_remote(remote).rsplit("/", 1)[-1] if remote else primary_root.name
    return Repo(
        repo_id=f"{slugify(remote_name)}-{digest}",
        identity_key=identity,
        display_name=remote_name or root.name,
        remote_url=remote,
        root_path=str(root),
        branch=run_git(root, "branch", "--show-current"),
        commit=run_git(root, "rev-parse", "HEAD"),
    )


def memory_home() -> Path:
    return Path(os.environ.get("PROJECT_MEMORY_HOME", str(DEFAULT_HOME))).expanduser()


def secure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True, mode=0o700)
    try:
        path.chmod(0o700)
    except OSError:
        pass


def connect() -> sqlite3.Connection:
    home = memory_home()
    secure_dir(home)
    secure_dir(home / "repos")
    db_path = home / "memory.sqlite3"
    db = sqlite3.connect(db_path, timeout=5)
    db.row_factory = sqlite3.Row
    db.execute("PRAGMA foreign_keys = ON")
    db.execute("PRAGMA journal_mode = WAL")
    db.execute("PRAGMA busy_timeout = 5000")
    migrate(db)
    try:
        db_path.chmod(0o600)
    except OSError:
        pass
    return db


def migrate(db: sqlite3.Connection) -> None:
    version = db.execute("PRAGMA user_version").fetchone()[0]
    if version > SCHEMA_VERSION:
        raise RuntimeError(f"database schema {version} is newer than supported {SCHEMA_VERSION}")
    if version == 0:
        try:
            db.executescript("""
                CREATE TABLE repositories (
                    repo_id TEXT PRIMARY KEY,
                    identity_key TEXT NOT NULL UNIQUE,
                    display_name TEXT NOT NULL,
                    remote_url TEXT,
                    root_path TEXT NOT NULL,
                    last_branch TEXT,
                    last_commit TEXT,
                    first_seen TEXT NOT NULL,
                    last_seen TEXT NOT NULL
                );
                CREATE TABLE memories (
                    id INTEGER PRIMARY KEY,
                    repo_id TEXT NOT NULL REFERENCES repositories(repo_id),
                    kind TEXT NOT NULL,
                    content TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL,
                    importance INTEGER NOT NULL DEFAULT 5 CHECK(importance BETWEEN 1 AND 10),
                    source TEXT,
                    status TEXT NOT NULL DEFAULT 'active',
                    supersedes_id INTEGER REFERENCES memories(id),
                    supersession_reason TEXT,
                    branch TEXT,
                    commit_hash TEXT,
                    path TEXT,
                    tags TEXT,
                    pinned INTEGER NOT NULL DEFAULT 0 CHECK(pinned IN (0, 1))
                );
                CREATE UNIQUE INDEX memories_active_exact
                    ON memories(repo_id, content) WHERE status = 'active';
                CREATE INDEX memories_repo_status ON memories(repo_id, status);
                CREATE VIRTUAL TABLE memory_fts USING fts5(
                    content, kind, path, branch, tags,
                    content='memories', content_rowid='id',
                    tokenize='unicode61 tokenchars ''_-'''
                );
                CREATE TRIGGER memories_ai AFTER INSERT ON memories BEGIN
                    INSERT INTO memory_fts(rowid, content, kind, path, branch, tags)
                    VALUES (new.id, new.content, new.kind, new.path, new.branch, new.tags);
                END;
                CREATE TRIGGER memories_ad AFTER DELETE ON memories BEGIN
                    INSERT INTO memory_fts(memory_fts, rowid, content, kind, path, branch, tags)
                    VALUES ('delete', old.id, old.content, old.kind, old.path, old.branch, old.tags);
                END;
                CREATE TRIGGER memories_au AFTER UPDATE OF content, kind, path, branch, tags ON memories BEGIN
                    INSERT INTO memory_fts(memory_fts, rowid, content, kind, path, branch, tags)
                    VALUES ('delete', old.id, old.content, old.kind, old.path, old.branch, old.tags);
                    INSERT INTO memory_fts(rowid, content, kind, path, branch, tags)
                    VALUES (new.id, new.content, new.kind, new.path, new.branch, new.tags);
                END;
                PRAGMA user_version = 3;
            """)
        except sqlite3.OperationalError as exc:
            if "fts5" in str(exc).lower():
                raise RuntimeError("this Python SQLite build does not include FTS5") from exc
            raise
    elif version == 1:
        # Status-only updates do not change searchable text. Re-indexing those rows can
        # corrupt an FTS external-content index on some SQLite builds.
        db.executescript("""
            DROP TRIGGER memories_au;
            CREATE TRIGGER memories_au
            AFTER UPDATE OF content, kind, path, branch, tags ON memories BEGIN
                INSERT INTO memory_fts(memory_fts, rowid, content, kind, path, branch, tags)
                VALUES ('delete', old.id, old.content, old.kind, old.path, old.branch, old.tags);
                INSERT INTO memory_fts(rowid, content, kind, path, branch, tags)
                VALUES (new.id, new.content, new.kind, new.path, new.branch, new.tags);
            END;
            INSERT INTO memory_fts(memory_fts) VALUES('rebuild');
            PRAGMA user_version = 2;
        """)
        version = 2
    if version == 2:
        # Do not make sentence punctuation part of tokens. Paths and qualified
        # identifiers remain searchable as their lexical components.
        db.executescript("""
            DROP TRIGGER memories_ai;
            DROP TRIGGER memories_ad;
            DROP TRIGGER memories_au;
            DROP TABLE memory_fts;
            CREATE VIRTUAL TABLE memory_fts USING fts5(
                content, kind, path, branch, tags,
                content='memories', content_rowid='id',
                tokenize='unicode61 tokenchars ''_-'''
            );
            CREATE TRIGGER memories_ai AFTER INSERT ON memories BEGIN
                INSERT INTO memory_fts(rowid, content, kind, path, branch, tags)
                VALUES (new.id, new.content, new.kind, new.path, new.branch, new.tags);
            END;
            CREATE TRIGGER memories_ad AFTER DELETE ON memories BEGIN
                INSERT INTO memory_fts(memory_fts, rowid, content, kind, path, branch, tags)
                VALUES ('delete', old.id, old.content, old.kind, old.path, old.branch, old.tags);
            END;
            CREATE TRIGGER memories_au
            AFTER UPDATE OF content, kind, path, branch, tags ON memories BEGIN
                INSERT INTO memory_fts(memory_fts, rowid, content, kind, path, branch, tags)
                VALUES ('delete', old.id, old.content, old.kind, old.path, old.branch, old.tags);
                INSERT INTO memory_fts(rowid, content, kind, path, branch, tags)
                VALUES (new.id, new.content, new.kind, new.path, new.branch, new.tags);
            END;
            INSERT INTO memory_fts(memory_fts) VALUES('rebuild');
            PRAGMA user_version = 3;
        """)


def register_repo(db: sqlite3.Connection, repo: Repo) -> None:
    timestamp = now()
    db.execute("""
        INSERT INTO repositories(
            repo_id, identity_key, display_name, remote_url, root_path,
            last_branch, last_commit, first_seen, last_seen
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(repo_id) DO UPDATE SET
            display_name=excluded.display_name, remote_url=excluded.remote_url,
            root_path=excluded.root_path, last_branch=excluded.last_branch,
            last_commit=excluded.last_commit, last_seen=excluded.last_seen
    """, (
        repo.repo_id, repo.identity_key, repo.display_name, repo.remote_url,
        repo.root_path, repo.branch, repo.commit, timestamp, timestamp,
    ))
    db.commit()


def current(db: sqlite3.Connection, cwd: str | None) -> Repo:
    repo = resolve_repo(cwd)
    register_repo(db, repo)
    return repo


def row_dict(row: sqlite3.Row) -> dict[str, Any]:
    return {key: row[key] for key in row.keys()}


def fts_query(text: str) -> str:
    terms = re.findall(r"[\w./:+-]+", text, flags=re.UNICODE)
    seen: set[str] = set()
    unique = []
    for term in terms:
        lowered = term.casefold()
        if len(term) < 2 or lowered in seen:
            continue
        seen.add(lowered)
        unique.append('"' + term.replace('"', '""') + '"*')
    return " OR ".join(unique[:32])


def search(
    db: sqlite3.Connection, repo: Repo, query: str, limit: int,
    all_statuses: bool = False,
) -> list[dict[str, Any]]:
    status_clause = "" if all_statuses else "AND m.status = 'active'"
    match = fts_query(query)
    if match:
        rows = db.execute(f"""
            SELECT m.*, bm25(memory_fts, 6.0, 2.0, 2.0, 1.5, 1.0) AS lexical_rank
            FROM memory_fts JOIN memories m ON m.id = memory_fts.rowid
            WHERE memory_fts MATCH ? AND m.repo_id = ? {status_clause}
            ORDER BY lexical_rank - (m.importance * 0.08) - (m.pinned * 0.5)
                     - (CASE WHEN m.branch = ? THEN 0.15 ELSE 0 END)
            LIMIT ?
        """, (match, repo.repo_id, repo.branch, limit)).fetchall()
    else:
        rows = db.execute(f"""
            SELECT m.*, NULL AS lexical_rank FROM memories m
            WHERE m.repo_id = ? {status_clause}
            ORDER BY m.pinned DESC, m.importance DESC, m.updated_at DESC LIMIT ?
        """, (repo.repo_id, limit)).fetchall()
    return [row_dict(row) for row in rows]


def format_memory(item: dict[str, Any], compact: bool = False) -> str:
    head = f"#{item['id']} [{item['kind']}]"
    if item["status"] != "active":
        head += f" ({item['status']})"
    body = re.sub(r"\s+", " ", item["content"]).strip()
    if compact:
        return f"- {head} {body}"
    meta = [f"importance={item['importance']}", f"updated={item['updated_at'][:10]}"]
    for key, label in (("branch", "branch"), ("commit_hash", "commit"), ("path", "path"), ("source", "source")):
        if item.get(key):
            value = item[key][:12] if key == "commit_hash" else item[key]
            meta.append(f"{label}={value}")
    return f"{head} {body}\n  " + " | ".join(meta)


def digest_path(repo: Repo) -> Path:
    directory = memory_home() / "repos" / repo.repo_id
    secure_dir(directory)
    return directory / "digest.md"


def refresh_digest(db: sqlite3.Connection, repo: Repo, limit: int = 30) -> Path:
    rows = db.execute("""
        SELECT * FROM memories
        WHERE repo_id = ? AND status = 'active' AND (pinned = 1 OR importance >= 7)
        ORDER BY pinned DESC, importance DESC, updated_at DESC LIMIT ?
    """, (repo.repo_id, limit)).fetchall()
    lines = [
        "# Project memory digest", "",
        f"Project: {repo.display_name}",
        f"Repository ID: {repo.repo_id}",
        f"Generated: {now()}", "",
    ]
    if rows:
        lines.extend(format_memory(row_dict(row), compact=True) for row in rows)
    else:
        lines.append("No pinned or high-importance memories yet.")
    path = digest_path(repo)
    temporary = path.with_suffix(".tmp")
    temporary.write_text("\n".join(lines) + "\n", encoding="utf-8")
    temporary.chmod(0o600)
    temporary.replace(path)
    return path


def context_text(db: sqlite3.Connection, repo: Repo, prompt: str | None, limit: int) -> str:
    if prompt:
        found = search(db, repo, prompt, limit)
        if not found:
            return ""
        lines = [
            "PROJECT MEMORY — relevant historical notes; verify against current source:",
            *(format_memory(item, compact=True) for item in found),
        ]
        return "\n".join(lines)
    path = refresh_digest(db, repo)
    digest = path.read_text(encoding="utf-8").strip()
    recent = db.execute("""
        SELECT * FROM memories WHERE repo_id = ? AND status = 'active'
            AND pinned = 0 AND importance < 7
        ORDER BY updated_at DESC LIMIT 5
    """, (repo.repo_id,)).fetchall()
    lines = ["PROJECT MEMORY — verify historical notes against current source:", digest]
    if recent:
        lines.extend(["", "Recent memory:"])
        lines.extend(format_memory(row_dict(row), compact=True) for row in recent)
    return "\n".join(lines)


def add_common(parser: argparse.ArgumentParser) -> None:
    parser.add_argument("--cwd", help="resolve the repository from this directory")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)

    repo = sub.add_parser("repo-id", help="show stable current repository identity")
    add_common(repo)
    repo.add_argument("--json", action="store_true")

    remember = sub.add_parser("remember", help="store one durable memory")
    add_common(remember)
    remember.add_argument("content")
    remember.add_argument("--kind", choices=KINDS, default="context")
    remember.add_argument("--importance", type=int, choices=range(1, 11), default=5)
    remember.add_argument("--source")
    remember.add_argument("--path")
    remember.add_argument("--tags")
    remember.add_argument("--branch")
    remember.add_argument("--commit")
    remember.add_argument("--pin", action="store_true")
    remember.add_argument("--supersedes", type=int)
    remember.add_argument("--reason")
    remember.add_argument("--json", action="store_true")

    recall = sub.add_parser("recall", help="search current repository memory")
    add_common(recall)
    recall.add_argument("query", nargs="?", default="")
    recall.add_argument("--limit", type=int, default=8)
    recall.add_argument("--all-statuses", action="store_true")
    recall.add_argument("--json", action="store_true")

    listing = sub.add_parser("list", help="list memories without a query")
    add_common(listing)
    listing.add_argument("--limit", type=int, default=20)
    listing.add_argument("--all-statuses", action="store_true")
    listing.add_argument("--json", action="store_true")

    show = sub.add_parser("show", help="show one memory by ID")
    show.add_argument("id", type=int)
    show.add_argument("--json", action="store_true")

    archive = sub.add_parser("archive", help="archive without deleting history")
    add_common(archive)
    archive.add_argument("id", type=int)

    digest = sub.add_parser("digest", help="show or refresh hot memory")
    add_common(digest)
    digest.add_argument("--refresh", action="store_true")
    digest.add_argument("--limit", type=int, default=30)

    context = sub.add_parser("context", help="render hook-ready project context")
    add_common(context)
    context.add_argument("--prompt")
    context.add_argument("--limit", type=int, default=8)

    doctor = sub.add_parser("doctor", help="validate storage and FTS")
    add_common(doctor)
    return parser


def positive_limit(value: int) -> int:
    if not 1 <= value <= 100:
        raise ValueError("limit must be between 1 and 100")
    return value


def command_main(args: argparse.Namespace) -> int:
    db = connect()
    try:
        if args.command == "show":
            row = db.execute("SELECT * FROM memories WHERE id = ?", (args.id,)).fetchone()
            if not row:
                raise ValueError(f"memory #{args.id} does not exist")
            item = row_dict(row)
            print(json.dumps(item, indent=2) if args.json else format_memory(item))
            return 0

        repo = current(db, getattr(args, "cwd", None))
        if args.command == "repo-id":
            print(json.dumps(asdict(repo), indent=2) if args.json else repo.repo_id)
        elif args.command == "remember":
            content = args.content.strip()
            if not content:
                raise ValueError("memory content cannot be empty")
            if args.supersedes:
                old = db.execute(
                    "SELECT * FROM memories WHERE id = ? AND repo_id = ?",
                    (args.supersedes, repo.repo_id),
                ).fetchone()
                if not old:
                    raise ValueError("superseded memory must exist in the current repository")
                if old["status"] != "active":
                    raise ValueError(f"memory #{args.supersedes} is already {old['status']}")
            existing = db.execute(
                "SELECT * FROM memories WHERE repo_id = ? AND content = ? AND status = 'active'",
                (repo.repo_id, content),
            ).fetchone()
            if existing:
                item = row_dict(existing)
                print(json.dumps(item, indent=2) if args.json else f"Already remembered as #{item['id']}")
                return 0
            timestamp = now()
            with db:
                cursor = db.execute("""
                    INSERT INTO memories(
                        repo_id, kind, content, created_at, updated_at, importance,
                        source, supersedes_id, supersession_reason, branch,
                        commit_hash, path, tags, pinned
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """, (
                    repo.repo_id, args.kind, content, timestamp, timestamp,
                    args.importance, args.source, args.supersedes, args.reason,
                    args.branch if args.branch is not None else repo.branch,
                    args.commit if args.commit is not None else repo.commit,
                    args.path, args.tags, int(args.pin),
                ))
                memory_id = cursor.lastrowid
                if args.supersedes:
                    db.execute(
                        "UPDATE memories SET status='superseded', updated_at=? WHERE id=?",
                        (timestamp, args.supersedes),
                    )
            refresh_digest(db, repo)
            row = db.execute("SELECT * FROM memories WHERE id = ?", (memory_id,)).fetchone()
            item = row_dict(row)
            print(json.dumps(item, indent=2) if args.json else f"Remembered #{memory_id} [{args.kind}]")
        elif args.command in ("recall", "list"):
            limit = positive_limit(args.limit)
            query = args.query if args.command == "recall" else ""
            items = search(db, repo, query, limit, args.all_statuses)
            if args.json:
                print(json.dumps(items, indent=2))
            elif items:
                print("\n\n".join(format_memory(item) for item in items))
            else:
                print("No matching project memories.")
        elif args.command == "archive":
            with db:
                changed = db.execute("""
                    UPDATE memories SET status='archived', updated_at=?
                    WHERE id=? AND repo_id=? AND status='active'
                """, (now(), args.id, repo.repo_id)).rowcount
            if not changed:
                raise ValueError(f"active memory #{args.id} was not found in this repository")
            refresh_digest(db, repo)
            print(f"Archived #{args.id}")
        elif args.command == "digest":
            path = refresh_digest(db, repo, positive_limit(args.limit)) if args.refresh else digest_path(repo)
            if not path.exists():
                path = refresh_digest(db, repo, positive_limit(args.limit))
            print(path.read_text(encoding="utf-8").rstrip())
        elif args.command == "context":
            print(context_text(db, repo, args.prompt, positive_limit(args.limit)))
        elif args.command == "doctor":
            db.execute("INSERT INTO memory_fts(memory_fts) VALUES('integrity-check')")
            count = db.execute(
                "SELECT count(*) FROM memories WHERE repo_id=?", (repo.repo_id,)
            ).fetchone()[0]
            print(f"OK: {memory_home()} | repo={repo.repo_id} | memories={count} | FTS5=ready")
        return 0
    finally:
        db.close()


def main(argv: Iterable[str] | None = None) -> int:
    try:
        return command_main(build_parser().parse_args(argv))
    except (RuntimeError, ValueError, sqlite3.Error, OSError) as exc:
        print(f"project-memory: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
