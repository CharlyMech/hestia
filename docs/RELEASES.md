# Releases

Releases are automated from `main`. Do not manually edit release tags or
changelog entries unless you are repairing a failed release.

## Version Source

`pubspec.yaml` owns the current app version:

```yaml
version: 1.0.0+1
```

- `1.0.0` is the user-facing app version.
- `1` is the build number.

For iOS builds, the workflow passes these values to Flutter as `--build-name`
and `--build-number`.

## Bump Rules

The release workflow applies this priority:

1. `chore:` or breaking change: major, for example `1.4.2 -> 2.0.0`.
2. `feat:`: minor, for example `1.4.2 -> 1.5.0`.
3. `fix:` or `docs:`: patch, for example `1.4.2 -> 1.4.3`.
4. Other releaseable commits: patch.

`chore(release): ... [skip ci]` commits created by the workflow are ignored.

## Changelog

`CHANGELOG.md` is generated from commit subjects in the `main` push that
triggered the release. For manual releases, the script uses commits since the
previous release tag. It is updated by `scripts/prepare_release.py` during the
TestFlight workflow.

Keep commit titles readable because they become release notes.

## Tags

Tags use:

```text
v<version>+<build>
```

Example:

```text
v1.5.0+42
```

## Manual Release

Use the `workflow_dispatch` trigger on `.github/workflows/release.yml` only for
rerunning a release candidate from the current `main`. The same versioning and
TestFlight upload steps apply.

## Rollback

TestFlight does not roll the app back automatically. To stop a bad beta build:

1. Expire the affected build in App Store Connect.
2. Revert or fix the bad commit on `dev`.
3. Promote the fix to `main`.
4. Let the release workflow create a newer version/build.
