#!/usr/bin/env python3
"""Prepare Hestia release metadata.

This script is intentionally dependency-free because it runs inside GitHub
Actions before the signed iOS build. It updates:

- pubspec.yaml version
- build/release-notes.md

Version bump policy:

- chore/* branch, chore commit, or breaking change -> major
- feat/* branch or feat commit -> minor
- fix/* or docs/* branch, fix commit, or docs commit -> patch
- any other releaseable commit -> patch

On GitHub push events, the script uses the pushed commit range. The intended
solo-developer workflow is PR branch -> main, with source branches named
feat/*, fix/*, chore/*, or docs/*.
"""

from __future__ import annotations

import argparse
import datetime as dt
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path


VERSION_RE = re.compile(
    r"^version:\s*(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)"
    r"(?:\+(?P<build>\d+))?\s*$",
    re.MULTILINE,
)
NULL_SHA = "0" * 40
CONVENTIONAL_RE = re.compile(
    r"^(?P<type>[a-zA-Z]+)(?:\([^)]+\))?(?P<breaking>!)?:\s*(?P<desc>.+)$"
)
BRANCH_TYPE_RE = re.compile(r"(?:^|[/\s:])(?P<type>feat|fix|chore|docs)/[\w.-]+")
SUPPORTED_TYPES = {"feat", "fix", "chore", "docs"}


@dataclass(frozen=True)
class Commit:
    sha: str
    subject: str
    body: str
    type: str
    description: str
    breaking: bool


def run_git(args: list[str], *, allow_empty: bool = False) -> str:
    result = subprocess.run(
        ["git", *args],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if result.returncode != 0:
        if allow_empty:
            return ""
        raise RuntimeError(result.stderr.strip() or f"git {' '.join(args)} failed")
    return result.stdout.strip()


def parse_current_version(pubspec: Path) -> tuple[int, int, int, int]:
    match = VERSION_RE.search(pubspec.read_text())
    if not match:
        raise ValueError("Could not find a semver `version:` line in pubspec.yaml")
    return (
        int(match.group("major")),
        int(match.group("minor")),
        int(match.group("patch")),
        int(match.group("build") or 0),
    )


def latest_release_tag() -> str:
    return run_git(
        ["describe", "--tags", "--match", "v[0-9]*", "--abbrev=0"],
        allow_empty=True,
    )


def default_revision_range() -> str:
    event_name = os.environ.get("RELEASE_EVENT_NAME")
    before_sha = os.environ.get("RELEASE_BEFORE_SHA", "").strip()
    if event_name == "push" and before_sha and before_sha != NULL_SHA:
        return f"{before_sha}..HEAD"

    tag = latest_release_tag()
    return f"{tag}..HEAD" if tag else "HEAD"


def detect_branch_type(commits: list["Commit"]) -> str | None:
    for commit in commits:
        text = f"{commit.subject}\n{commit.body}"
        match = BRANCH_TYPE_RE.search(text)
        if match:
            return match.group("type")
    return None


def parse_commits(revision_range: str) -> list[Commit]:
    raw = run_git(
        ["log", revision_range, "--pretty=format:%H%x1f%s%x1f%b%x1e"],
        allow_empty=True,
    )
    commits: list[Commit] = []
    for record in raw.split("\x1e"):
        record = record.strip()
        if not record:
            continue
        parts = record.split("\x1f")
        if len(parts) < 3:
            continue
        sha, subject, body = parts[0], parts[1].strip(), parts[2].strip()
        if "[skip ci]" in subject or subject.startswith("chore(release):"):
            continue

        match = CONVENTIONAL_RE.match(subject)
        commit_type = match.group("type").lower() if match else "other"
        description = match.group("desc").strip() if match else subject
        breaking = bool(match and match.group("breaking")) or bool(
            re.search(r"^BREAKING CHANGE:", body, re.IGNORECASE | re.MULTILINE)
        )
        commits.append(
            Commit(
                sha=sha,
                subject=subject,
                body=body,
                type=commit_type,
                description=description,
                breaking=breaking,
            )
        )
    return commits


def bump_kind(commits: list[Commit]) -> str:
    branch_type = detect_branch_type(commits)
    if branch_type == "chore":
        return "major"
    if branch_type == "feat":
        return "minor"
    if branch_type in {"fix", "docs"}:
        return "patch"

    if any(c.breaking or c.type == "chore" for c in commits):
        return "major"
    if any(c.type == "feat" for c in commits):
        return "minor"
    return "patch"


def bump_version(current: tuple[int, int, int, int], kind: str) -> tuple[int, int, int]:
    major, minor, patch, _ = current
    if kind == "major":
        return major + 1, 0, 0
    if kind == "minor":
        return major, minor + 1, 0
    return major, minor, patch + 1


def section_name(commit: Commit) -> str:
    if commit.breaking:
        return "Breaking Changes"
    if commit.type == "chore":
        return "Major Changes"
    if commit.type == "feat":
        return "Features"
    if commit.type == "fix":
        return "Fixes"
    if commit.type == "docs":
        return "Documentation"
    if commit.type in {"refactor", "perf", "test", "build", "ci"}:
        return "Maintenance"
    return "Other Changes"


def grouped_changes(commits: list[Commit]) -> dict[str, list[Commit]]:
    order = [
        "Breaking Changes",
        "Major Changes",
        "Features",
        "Fixes",
        "Documentation",
        "Maintenance",
        "Other Changes",
    ]
    grouped: dict[str, list[Commit]] = {name: [] for name in order}
    for commit in commits:
        grouped[section_name(commit)].append(commit)
    return {name: grouped[name] for name in order if grouped[name]}


def release_markdown(
    *,
    version: str,
    build: int,
    date: str,
    kind: str,
    commits: list[Commit],
) -> str:
    lines = [f"## [{version}+{build}] - {date}", "", f"Bump: {kind}", ""]
    groups = grouped_changes(commits)
    if not groups:
        lines.extend(["### Maintenance", "- Release build metadata update.", ""])
    else:
        for group, group_commits in groups.items():
            lines.extend([f"### {group}"])
            for commit in group_commits:
                lines.append(f"- {commit.subject} ({commit.sha[:7]})")
            lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def update_pubspec(pubspec: Path, version: str, build: int) -> None:
    original = pubspec.read_text()
    updated, count = VERSION_RE.subn(f"version: {version}+{build}", original, count=1)
    if count != 1:
        raise ValueError("Could not update pubspec.yaml version")
    pubspec.write_text(updated)



def write_outputs(outputs: dict[str, str]) -> None:
    output_path = os.environ.get("GITHUB_OUTPUT")
    if not output_path:
        return
    with open(output_path, "a", encoding="utf-8") as handle:
        for key, value in outputs.items():
            handle.write(f"{key}={value}\n")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pubspec", default="pubspec.yaml")
    parser.add_argument("--release-notes", default="build/release-notes.md")
    parser.add_argument("--build-number", default=os.environ.get("GITHUB_RUN_NUMBER"))
    parser.add_argument("--date", default=dt.date.today().isoformat())
    parser.add_argument("--revision-range")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    pubspec = Path(args.pubspec)
    release_notes = Path(args.release_notes)
    current = parse_current_version(pubspec)

    revision_range = args.revision_range or default_revision_range()
    commits = parse_commits(revision_range)
    kind = bump_kind(commits)
    major, minor, patch = bump_version(current, kind)
    version = f"{major}.{minor}.{patch}"
    build = int(args.build_number) if args.build_number else current[3] + 1
    tag_name = f"v{version}+{build}"
    entry = release_markdown(
        version=version,
        build=build,
        date=args.date,
        kind=kind,
        commits=commits,
    )

    if not args.dry_run:
        update_pubspec(pubspec, version, build)
        release_notes.parent.mkdir(parents=True, exist_ok=True)
        release_notes.write_text(entry)

    print(f"range={revision_range}")
    print(f"version={version}")
    print(f"build={build}")
    print(f"tag={tag_name}")
    print(f"bump={kind}")

    write_outputs(
        {
            "version": version,
            "build": str(build),
            "tag": tag_name,
            "bump": kind,
            "release_notes_file": str(release_notes),
        }
    )


if __name__ == "__main__":
    main()
