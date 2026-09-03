---
name: pr-reviewbot
description: Read-only GitHub pull request review assistant that prepares or reuses a local PR-head worktree under ~/Documents/Mach/review from ~/Documents/Mach/monorepo, refreshes it automatically, and reviews the diff and existing discussion without posting to GitHub. Use when a user asks for a full review of a specific PR number or URL.
metadata:
  version: 1.1.0
  category: code-review
  triggers:
    - review pr
    - code review
    - review pull request
    - check pr
    - pr review
    - github.com/*/pull/*
  tags:
    - github
    - code-review
    - pull-request
    - worktree
    - read-only
---

# PR Review Workflow

Use this skill to perform a thorough, diff-focused review of a GitHub pull request and report findings directly in the local chat window.

The review is read-only with respect to GitHub, the PR, and source contents. The one deliberate setup exception is local worktree lifecycle: the bot may inspect worktrees, create a clean review worktree, fetch/pull the PR branch, and later remove a worktree only when the user asks.

## Guardrails

- Never edit source files, commit, push, merge, rebase, install dependencies, or change the user's current checkout.
- Never post to GitHub.
- Never run `gh pr review`, `gh pr comment`, or `gh api` with write methods such as `POST`, `PATCH`, `PUT`, or `DELETE`.
- Worktree setup may use `git worktree add`, `git fetch`, and `git pull --ff-only` only for the PR review worktree described below.
- Do not stash, reset, force-pull, force-checkout, or overwrite dirty user worktrees. Stop and report the conflict.
- Do not remove a worktree automatically after the review. Do not delete its branch unless the user separately asks.
- Only remove a worktree after the user explicitly asks; never remove an existing worktree that the bot did not create.
- If the requested monorepo is missing, the branch is ambiguous, or the worktree cannot be refreshed safely, stop and ask the user for direction.

## Inputs

- Required: PR number or PR URL, for example `PR #1580`.
- Optional: branch context, for example `into <base> from <head>`; compare it with the resolved PR metadata.
- The canonical local repository is `~/Documents/Mach/monorepo`.
- New review worktrees belong under `~/Documents/Mach/review/`.

## Workflow

### 1. Verify GitHub access and resolve the PR

- Run `gh auth status`.
- If authentication fails, ask the user to run `gh auth login`.
- If sandboxing blocks networked `gh` commands, rerun with elevated permissions.
- Run:
  ```bash
  gh pr view <pr> --json number,title,url,body,baseRefName,headRefName,headRefOid,headRepository,headRepositoryOwner,author,state,isDraft,files,commits
  ```
- Record the PR title, description, base branch, head branch, head repository, head commit, changed files, and commits.
- If user-provided branch hints do not match the metadata, flag the mismatch before continuing.

### 2. Prepare or reuse the PR worktree

Always perform this setup when a PR review is requested; do not ask the user to pre-checkout or pre-pull the branch.

1. Confirm `~/Documents/Mach/monorepo` exists and is the expected repository. Run `git -C ~/Documents/Mach/monorepo status --short` and `git -C ~/Documents/Mach/monorepo remote -v` as needed.
2. Inspect `git -C ~/Documents/Mach/monorepo worktree list --porcelain`.
3. Use the PR `headRefName` as the relevant branch. Find an existing worktree whose local branch is `refs/heads/<headRefName>`. Verify its repository/remote and current commit against the PR head; do not reuse an ambiguous branch from another fork.
4. If a matching worktree exists:
   - Use that worktree.
   - If it is dirty, do not stash or alter it; stop and ask the user whether to proceed.
   - If it is clean, run `git -C <worktree> pull --ff-only` against its configured upstream.
   - If the pull cannot fast-forward, stop and report the divergence.
5. If no matching worktree exists:
   - Set `REVIEW_ROOT=~/Documents/Mach/review` and choose a path derived from the branch, such as `<branch-name>` with `/` replaced by `__`. Keep the path inside `REVIEW_ROOT`.
   - If that path already exists but is not the matching registered worktree, do not overwrite it; stop and ask for a different path or cleanup.
   - Fetch the PR head from the appropriate configured remote or PR head repository. If the branch already exists locally but is not checked out, create the worktree with `git worktree add <review-path> <head-branch>`; otherwise create the branch and worktree with `git worktree add -b <head-branch> <review-path> <start-point>`. Establish the correct upstream before running `git -C <worktree> pull --ff-only`.
   - If the PR comes from a fork or the head remote cannot be resolved safely, stop rather than silently reviewing a branch with the same name from the wrong repository.
6. Verify the final worktree branch and commit after pulling. If it does not represent the resolved PR head, refresh the PR metadata once and stop if the mismatch remains.
7. Keep the selected worktree for later turns. Report its path and whether it was reused or created. Do not remove it when the review finishes.

Use the selected worktree for all local file inspection and diff context. The `gh pr diff` output remains the authoritative PR patch.

### 3. Collect existing feedback

Gather existing discussion to avoid duplicate findings:

- `gh pr view <pr> --comments`
- `gh repo view --json nameWithOwner -q .nameWithOwner`
- `gh api repos/<owner>/<repo>/pulls/<pr>/comments --paginate`
- `gh api repos/<owner>/<repo>/issues/<pr>/comments --paginate`
- `gh api repos/<owner>/<repo>/pulls/<pr>/reviews --paginate`

Build a duplicate-exclusion set keyed by file, hunk, line range, and issue topic. Do not repeat issues already raised unless there is materially new evidence or a broader impact not covered by the existing comment.

### 4. Review the diff

- Inspect `gh pr diff <pr>`, the changed-file list, and relevant files in the selected worktree.
- Stay focused on changed hunks and the surrounding code needed to validate them; avoid broad unrelated repository exploration.
- Evaluate correctness, completeness, accuracy, precision, efficiency, consistency, security, and concrete regression risk.
- Review tests and documentation changes as artifacts in the diff, but do not execute tests or validate by running the project.

Do not run builds, tests, linters, formatters, dependency installation, CI/CD jobs, `gh pr checks`, or CI log inspection. The review may note missing coverage or residual testing risk based on the patch and discussion alone.

### 5. Report findings in chat only

- Never submit findings through `gh`.
- Present findings ordered by severity:
  - High: likely bug, regression, security issue, or data-loss risk.
  - Medium: meaningful correctness, maintainability, or completeness issue.
  - Low: clarity, minor optimization, or style issue with practical impact.
- For each finding include the file path and approximate line or hunk, why it matters, and a concrete fix recommendation.
- Include an `Already covered (excluded)` section summarizing skipped duplicate issues when applicable.
- If no new issues are found, explicitly say `No new findings` and list residual risks or testing gaps.
- Include the persistent review-worktree path in the summary.

## Removing a review worktree

Only do this when the user asks. Confirm the exact path and that it is a bot-created worktree under `~/Documents/Mach/review/`. Check `git -C <worktree> status --short` first.

- If clean, remove it with `git -C ~/Documents/Mach/monorepo worktree remove <worktree>`.
- If dirty or containing untracked files, explain what would be lost and obtain explicit confirmation before using a force removal.
- Do not delete the local branch or any backup unless separately requested.
- If the worktree was reused from elsewhere, report that it is not eligible for automatic removal.

## Review Criteria

Use `references/review_criteria.md` as the detailed checklist. Prioritize concrete behavioral impact over speculative style feedback.

- Read `references/gh_cli_guide.md` when setting up, refreshing, or removing a worktree.
- Read `references/scenarios.md` when the request is large, security-focused, or includes related tickets.
- Consult `references/troubleshooting.md` when authentication, branch, or worktree setup fails.

## Allowed setup/read commands

These commands are allowed for review setup or read-only inspection:

```bash
gh auth status
gh pr view <pr> --json number,title,url,body,baseRefName,headRefName,headRefOid,headRepository,headRepositoryOwner,author,state,isDraft,files,commits
gh pr view <pr> --comments
gh pr diff <pr>
gh repo view --json nameWithOwner -q .nameWithOwner
gh api repos/<owner>/<repo>/pulls/<pr>/comments --paginate
gh api repos/<owner>/<repo>/issues/<pr>/comments --paginate
gh api repos/<owner>/<repo>/pulls/<pr>/reviews --paginate
git -C ~/Documents/Mach/monorepo status --short
git -C ~/Documents/Mach/monorepo remote -v
git -C ~/Documents/Mach/monorepo worktree list --porcelain
git -C <worktree> status --short
git -C <worktree> pull --ff-only
git -C ~/Documents/Mach/monorepo fetch <remote> <head-branch>
git -C ~/Documents/Mach/monorepo worktree add ...
git -C ~/Documents/Mach/monorepo worktree remove ...
git -C <worktree> diff <base>...HEAD -- <path>
```

The fetch, pull, add, and user-requested remove commands are setup/lifecycle exceptions. Do not use force variants without the explicit removal confirmation described above.

## Examples

- `Can you help me review PR #1580?`
- `Review PR #1530 and use the existing worktree if it already exists.`
- `Review PR #2012, then leave the review worktree in place.`
- `Remove the review worktree for PR #2012.`
