# Common Review Scenarios

Detailed workflows for the read-only PR review and persistent local worktree lifecycle.

## Scenario 1: Standard Review Request

**Trigger**: User provides a PR number or URL and requests a review.

**Workflow**:
1. Verify `gh auth status`.
2. Resolve PR metadata, including `headRefName`, `headRefOid`, and the head repository.
3. Inspect `~/Documents/Mach/monorepo` worktrees.
4. Reuse a matching clean worktree or create one under `~/Documents/Mach/review/`; fetch and `git pull --ff-only` the correct PR branch.
5. Read the PR description, changed files, and existing discussion.
6. Inspect the diff and relevant local files in the selected worktree.
7. Report new findings only in the local chat window and leave the worktree in place.

## Scenario 2: Thorough Review

**Trigger**: User requests a comprehensive review.

**Workflow**:
1. Prepare or reuse the PR-head worktree and confirm its final commit.
2. Collect PR metadata, files, commits, description, review comments, issue comments, and reviews.
3. Build a duplicate-exclusion list from existing feedback.
4. If the PR spans multiple domains or the user asks for it, attempt scoped read-only review passes.
5. Review all changed files against `review_criteria.md`.
6. Read surrounding local source context for suspicious hunks.
7. Validate and de-duplicate candidate findings.
8. Report findings ordered by severity in chat only, including the persistent worktree path.
9. Do not run tests, builds, CI/CD, linters, formatters, or dependency installation.

## Scenario 3: Security-Focused Review

**Trigger**: User requests security-specific review.

**Workflow**:
1. Prepare or reuse the PR-head worktree.
2. Read the PR body, changed files, and existing discussion.
3. Focus on `review_criteria.md` Section 5 (Security).
4. Check for SQL injection, XSS, CSRF, auth bypasses, unsafe deserialization, secrets exposure, and dependency risk.
5. Report concrete security findings in chat only.

## Scenario 4: Review with Related Tickets

**Trigger**: User requests review against a linked ticket.

**Workflow**:
1. Prepare or reuse the PR-head worktree.
2. Read the PR body for ticket references.
3. Fetch linked GitHub issue context with read-only `gh issue view` or `gh api` GET commands.
4. Compare PR changes against ticket requirements.
5. Note missing functionality or tests in chat only; do not run the test suite.

## Scenario 5: Large PR Review

**Trigger**: PR contains more than 400 lines of changes.

**Workflow**:
1. Prepare or reuse the PR-head worktree.
2. Note that the PR is large and review confidence may be lower.
3. Attempt scoped read-only passes by file group, subsystem, risk category, or test area.
4. Validate candidate findings against local source context and existing feedback.
5. Focus on architecture, correctness, and security first.
6. Prioritize actionable findings with concrete evidence.
7. Leave the worktree in place for follow-up.
