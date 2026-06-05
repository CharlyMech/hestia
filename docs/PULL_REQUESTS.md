# Pull Requests

Pull requests are the control point for code quality, release safety, and
versioning.

## Required Checks

The CI workflow runs on PRs targeting `dev` and `main`:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter test
```

The test step skips only when no `test/` directory exists.

## Review Checklist

- The PR branch starts from `dev`, unless it is an emergency fix.
- The title follows Conventional Commit style.
- The selected PR type matches the version bump behavior.
- User-facing changes include screenshots or recordings.
- Backend contract changes include docs and migration notes.
- Release, signing, and CI changes update `docs/CI_CD.md` or
  `docs/RELEASES.md`.
- No secrets, certificates, `.env` files, or private Apple keys are committed.

## Merge Expectations

Merge feature branches into `dev` first. Promote `dev` to `main` only when the
candidate is releasable. A merge to `main` creates a new TestFlight build,
updates `CHANGELOG.md`, tags the release, and creates a GitHub release.
