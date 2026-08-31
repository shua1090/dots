---
name: project-memory
description: Recall and preserve durable, repository-scoped engineering knowledge in a local SQLite FTS vault. Use when prior decisions, architecture, gotchas, confirmed bug causes, investigations, commands, preferences, or worktree/branch history may help; when the user says remember, recall, or asks what happened previously; and after reaching a confirmed non-obvious conclusion worth retaining. Do not use it to save raw chat, speculation, secrets, large code snippets, or facts that are trivial to rediscover.
---

# Project Memory

Use the bundled local-only CLI. It identifies the current project by normalized Git origin, so all worktrees of one repository share memory. It falls back to the canonical Git root when no origin exists. Data defaults to `~/.factory/project-memory` and can be relocated with `PROJECT_MEMORY_HOME`.

Set this once when issuing commands:

```sh
MEMORY="$HOME/.agents/skills/project-memory/scripts/memory.py"
```

## Recall before relying on history

Search when the task refers to earlier work or when project history could prevent repeated investigation:

```sh
python3 "$MEMORY" recall "LIN serial corruption" --limit 8
```

Treat retrieved memory as useful historical evidence, not current source truth. Verify it against the checked-out code or hardware state when correctness depends on it. Active facts are returned by default; use `--all-statuses` only for historical analysis.

## Store only durable conclusions

Before any write, ask the user for explicit confirmation in the current turn, even when the user has requested that something be remembered. Do not treat an instruction to remember as permission to execute the write immediately. In Factory, the `PreToolUse` hook also shows a UI approval prompt; wait for that approval. In Codex, use the conversational confirmation as the approval gate.

After approval, save a concise, self-contained fact after the user explicitly asks, or after a confirmed non-obvious conclusion or architectural decision:

```sh
python3 "$MEMORY" remember \
  --kind gotcha \
  --importance 8 \
  --source "confirmed during UART investigation" \
  --path src/transport/lin.c \
  "UART RX must clear ORE before DMA is restarted."
```

Allowed kinds are `decision`, `architecture`, `gotcha`, `preference`, `bug`, `investigation`, `command`, `context`, and `todo`. Prefer one fact per memory. Include paths, branches, and sources when they improve provenance. Never store credentials, tokens, customer data, raw transcripts, temporary guesses, or bulky code.

Use `--pin` only for facts important enough for the always-loaded digest. Importance is 1–10; reserve 8–10 for constraints or conclusions likely to affect future work.

## Supersede instead of rewriting history

When a fact changes, retain the old record and link the replacement:

```sh
python3 "$MEMORY" remember \
  --kind decision \
  --supersedes 17 \
  --reason "Rev C board redesign" \
  "LIN now uses UART4."
```

Use `archive <id>` for a record that should stop appearing but has no replacement. Do not delete historical records through this workflow.

## Inspect and maintain

```sh
python3 "$MEMORY" list --limit 20
python3 "$MEMORY" show 17
python3 "$MEMORY" digest --refresh
python3 "$MEMORY" repo-id --json
python3 "$MEMORY" doctor
```

Refresh the digest after adding, pinning, superseding, or archiving high-value facts. Factory's `SessionStart` hook also refreshes it before loading the hot-memory layer.

## Factory hooks

Install or update user-level hooks with:

```sh
python3 "$HOME/.agents/skills/project-memory/scripts/install_factory_hooks.py"
```

The installer links the canonical skill into `~/.factory/skills/project-memory` for Factory versions that do not scan personal `.agents` skills, then merges hooks idempotently into `~/.factory/hooks.json`. It refuses to replace a conflicting skill or symlink. `SessionStart` injects the digest plus a few critical facts. `UserPromptSubmit` searches the current prompt and injects only relevant active matches. Both fail open: memory errors never block Droid. No hook captures conversations automatically.

Run the installer with `--dry-run` to inspect the merged JSON first.

## Output discipline

Do not paste the full vault into context. Recall the smallest useful top-K set. Mention memory IDs when a retrieved item materially affects a decision so the user can inspect or supersede it.
