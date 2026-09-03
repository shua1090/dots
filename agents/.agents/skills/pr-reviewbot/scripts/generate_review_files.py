#!/usr/bin/env python3
"""
Generate local-only review files from PR analysis.

This helper never posts to GitHub and never generates commands that post to
GitHub. It is optional; the preferred skill workflow is to report findings
directly in the local chat window.
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any, Dict, List


def create_pr_directory(pr_review_dir: Path) -> Path:
    """Create the pr/ subdirectory for review files."""
    pr_dir = pr_review_dir / "pr"
    pr_dir.mkdir(parents=True, exist_ok=True)
    return pr_dir


def load_findings(findings_file: str) -> Dict[str, Any]:
    """Load review findings from JSON."""
    with open(findings_file, "r") as f:
        return json.load(f)


def clean_text(text: str) -> str:
    """Normalize text for chat output."""
    if not text:
        return text
    return text.replace("—", "-").replace("–", "-")


def normalized_findings(findings: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Accept either explicit findings or the older blocker/important/nit shape."""
    if findings.get("findings"):
        return findings["findings"]

    items: List[Dict[str, Any]] = []
    for key, severity in (("blockers", "High"), ("important", "Medium"), ("nits", "Low")):
        for item in findings.get(key, []):
            normalized = dict(item)
            normalized.setdefault("severity", severity)
            items.append(normalized)
    return items


def generate_detailed_review(findings: Dict[str, Any], metadata: Dict[str, Any]) -> str:
    """Generate detailed local review."""
    output = f"""# Pull Request Review - Detailed Analysis

## PR Information

**Repository**: {metadata.get("repository", "N/A")}
**PR Number**: #{metadata.get("number", "N/A")}
**Title**: {metadata.get("title", "N/A")}
**Author**: {metadata.get("author", "N/A")}
**Branch**: {metadata.get("head_branch", "N/A")} -> {metadata.get("base_branch", "N/A")}

## Summary

{findings.get("summary", "No summary provided")}

"""

    items = normalized_findings(findings)
    if not items:
        output += "## Findings\n\nNo new findings.\n"
        return output

    output += "## Findings\n\n"
    for index, item in enumerate(items, 1):
        output += f"### {index}. {item.get('severity', 'N/A')}: {item.get('issue', 'Issue')}\n\n"
        if item.get("file"):
            output += f"**File**: `{item['file']}"
            if item.get("line"):
                output += f":{item['line']}"
            output += "`\n\n"
        if item.get("details"):
            output += f"**Why it matters**: {item['details']}\n\n"
        if item.get("fix"):
            output += f"**Fix recommendation**: {item['fix']}\n\n"
        if item.get("code_snippet"):
            output += f"**Code**:\n```\n{item['code_snippet']}\n```\n\n"
        output += "---\n\n"

    if findings.get("already_covered"):
        output += "## Already Covered (Excluded)\n\n"
        for item in findings["already_covered"]:
            output += f"- {item}\n"
        output += "\n"

    return output


def generate_chat_review(findings: Dict[str, Any], metadata: Dict[str, Any]) -> str:
    """Generate concise review text intended only for local chat."""
    title = clean_text(metadata.get("title", "N/A"))
    summary = clean_text(findings.get("summary", "No summary provided"))
    items = normalized_findings(findings)

    output = f"""# Code Review

**PR #{metadata.get("number", "N/A")}**: {title}

## Summary

{summary}

"""

    if not items:
        output += "No new findings.\n"
    else:
        output += "## Findings\n\n"
        severity_order = {"High": 0, "Medium": 1, "Low": 2}
        items = sorted(items, key=lambda item: severity_order.get(item.get("severity", ""), 99))
        for index, item in enumerate(items, 1):
            issue = clean_text(item.get("issue", "Issue"))
            details = clean_text(item.get("details", "No details"))
            fix = clean_text(item.get("fix", ""))

            output += f"{index}. **{item.get('severity', 'N/A')}: {issue}**\n"
            if item.get("file"):
                output += f"   - File: `{item['file']}`"
                if item.get("line"):
                    output += f":{item['line']}"
                output += "\n"
            output += f"   - Why it matters: {details}\n"
            if fix:
                output += f"   - Fix: {fix}\n"
            output += "\n"

    if findings.get("already_covered"):
        output += "## Already Covered (Excluded)\n\n"
        for item in findings["already_covered"]:
            output += f"- {clean_text(str(item))}\n"
        output += "\n"

    if findings.get("residual_risks"):
        output += "## Residual Risks / Testing Gaps\n\n"
        for item in findings["residual_risks"]:
            output += f"- {clean_text(str(item))}\n"

    return output


def generate_claude_commands(pr_review_dir: Path) -> None:
    """Generate a read-only helper command."""
    claude_dir = pr_review_dir / ".claude" / "commands"
    claude_dir.mkdir(parents=True, exist_ok=True)

    show_cmd = """Open the PR review directory in VS Code for editing.

Steps:
1. Run `code .` to open the current directory in VS Code.
2. Tell the user they can inspect:
   - pr/review.md (detailed local review)
   - pr/chat.md (local chat review)
3. Remind them that this workflow is read-only and nothing should be posted to GitHub.
"""

    with open(claude_dir / "show.md", "w") as f:
        f.write(show_cmd)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate local-only review files from PR analysis",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("pr_review_dir", help="PR review directory path")
    parser.add_argument("--findings", required=True, help="JSON file with review findings")
    parser.add_argument("--metadata", help="JSON file with PR metadata (optional)")

    args = parser.parse_args()

    try:
        findings = load_findings(args.findings)

        metadata: Dict[str, Any] = {}
        if args.metadata and os.path.exists(args.metadata):
            with open(args.metadata, "r") as f:
                metadata = json.load(f)
        if not metadata:
            metadata = findings.get("metadata", {})

        pr_review_dir = Path(args.pr_review_dir)
        pr_dir = create_pr_directory(pr_review_dir)

        detailed_review = generate_detailed_review(findings, metadata)
        review_file = pr_dir / "review.md"
        with open(review_file, "w") as f:
            f.write(detailed_review)

        chat_review = generate_chat_review(findings, metadata)
        chat_file = pr_dir / "chat.md"
        with open(chat_file, "w") as f:
            f.write(chat_review)

        generate_claude_commands(pr_review_dir)

        summary = f"""Local PR Review Files Generated
===============================

Directory: {pr_review_dir}

Files created:
- pr/review.md      - Detailed local analysis
- pr/chat.md        - Clean review for local chat only

Slash commands available:
- /show             - Open directory in VS Code

Next steps:
1. Review the files if needed.
2. Report findings only in the local chat window.

IMPORTANT: This workflow is read-only. Do not post comments, approvals, or change requests to GitHub.
"""

        summary_file = pr_review_dir / "REVIEW_READY.txt"
        with open(summary_file, "w") as f:
            f.write(summary)

        print(summary)

    except Exception as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
