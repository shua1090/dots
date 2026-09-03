# Troubleshooting Guide

Common issues and solutions for the PR Reviewer skill.

## gh CLI Not Found

Install GitHub CLI: https://cli.github.com/

```bash
# macOS
brew install gh

# Linux
sudo apt install gh  # or yum, dnf, etc.

# Authenticate
gh auth login
```

## Permission Denied Errors

Check authentication:

```bash
gh auth status
gh auth refresh -s repo
```

## Invalid PR URL

Ensure URL format: `https://github.com/owner/repo/pull/NUMBER`

## Line Number Mismatch in Findings

When reporting a finding in chat, prefer the local file line number if you read the file directly. If you only have diff context, call it an approximate hunk location.

Use `gh pr diff <number>` to inspect the changed hunks, then read the relevant local file before reporting.

## Rate Limit Errors

```bash
# Check rate limit
gh api /rate_limit

# Authenticated users get higher limits
gh auth login
```

## Common Error Patterns

| Error | Cause | Solution |
|-------|-------|----------|
| 401 Unauthorized | Token expired | Run `gh auth refresh` |
| 403 Forbidden | Missing scope | Run `gh auth refresh -s repo` |
| 404 Not Found | Private repo access | Verify repo permissions |
| 422 Unprocessable | Invalid request | Check command arguments |

## Worktree Problems

The review repository is `~/Documents/Mach/monorepo`, and bot-created review worktrees must be under `~/Documents/Mach/review/`.

- If `git worktree list --porcelain` shows the PR branch already checked out, reuse that worktree rather than creating a second one.
- If the candidate review path already exists but is not the matching registered worktree, do not overwrite it.
- If a matching worktree is dirty, do not stash, reset, or force-pull; report the path and ask the user how to proceed.
- If `git pull --ff-only` cannot fast-forward, report the divergence instead of rewriting history.
- Remove a bot-created worktree only after the user asks. Check status first and obtain explicit confirmation before force-removing dirty or untracked content.
