# GitHub CLI and Local Worktree Guide

Use GitHub commands to collect PR context without changing GitHub state. Local worktree setup is the limited exception described below.

## Prerequisites

```bash
gh auth status
```

If authentication fails, ask the user to run `gh auth login`.

## PR Metadata

```bash
gh pr view <number> --json number,title,url,body,state,author,headRefName,headRefOid,headRepository,headRepositoryOwner,baseRefName,isDraft,files,commits
```

With an explicit repository:

```bash
gh pr view <number> --repo <owner>/<repo> --json number,title,url,body,state,author,headRefName,headRefOid,headRepository,headRepositoryOwner,baseRefName,isDraft,files,commits
```

## Worktree preparation

The review repository is `~/Documents/Mach/monorepo`; new bot-owned worktrees belong under `~/Documents/Mach/review/`.

Inspect registered worktrees:

```bash
git -C ~/Documents/Mach/monorepo worktree list --porcelain
```

For an existing clean worktree on the PR head branch, refresh it:

```bash
git -C <worktree> pull --ff-only
```

For a new worktree, first fetch the PR head from the correct repository/remote, then create the branch/worktree and configure its upstream. If the branch already exists locally, omit `-b` and pass the existing branch name:

```bash
git -C ~/Documents/Mach/monorepo fetch <remote> <head-branch>
git -C ~/Documents/Mach/monorepo worktree add -b <head-branch> <review-path> <remote>/<head-branch>
git -C <review-path> pull --ff-only
```

Use the PR head repository, not merely a same-named branch from an unrelated fork. Never overwrite an existing path or dirty worktree.

Remove only a bot-created review worktree after the user asks:

```bash
git -C ~/Documents/Mach/monorepo worktree remove <review-path>
```

Check status first; do not use a force removal without explicit confirmation that dirty/untracked files may be lost.

## Repository and changed files

```bash
gh repo view --json nameWithOwner -q .nameWithOwner
gh pr diff <number>
gh pr view <number> --json files --jq '.files[].path'
git -C <worktree> status --short
git -C <worktree> diff <base>...HEAD -- <path>
```

## Existing PR discussion

```bash
gh pr view <number> --comments
gh api repos/<owner>/<repo>/pulls/<number>/comments --paginate
gh api repos/<owner>/<repo>/issues/<number>/comments --paginate
gh api repos/<owner>/<repo>/pulls/<number>/reviews --paginate
```

## Related issues

```bash
gh pr view <number> --json body --jq '.body'
gh issue view <issue-number> --repo <owner>/<repo> --json number,title,body,state,labels,assignees
gh api repos/<owner>/<repo>/issues/<issue-number>/comments --paginate
```

## Review scope

Do not run builds, tests, linters, formatters, dependency installation, CI/CD jobs, `gh pr checks`, or CI log inspection. Assess coverage and testing gaps from the patch and discussion only.

## Forbidden commands

Never mutate GitHub or the PR:

```bash
gh pr review
gh pr comment
gh api -X POST ...
gh api -X PATCH ...
gh api -X PUT ...
gh api -X DELETE ...
```

Never mutate source or the user's current checkout:

```bash
git checkout
git reset
git merge
git rebase
git push
```

`git fetch`, `git pull --ff-only`, `git worktree add`, and user-requested clean `git worktree remove` are setup/lifecycle exceptions only.
