# Contributing to Hestia

Hestia is source-available, not open source. Running, deploying, copying, or
redistributing it requires permission from the project owner. Contributions are
welcome when they follow this workflow.

## Branch Model

- `main`: release branch. Every merge to `main` triggers the TestFlight release
  workflow.
- `dev`: integration branch for ongoing work.
- Feature branches: branch from `dev` and use names such as `feat/calendar`,
  `fix/login-redirect`, `docs/release-guide`, or `chore/signing`.

Normal flow: feature branch -> `dev` -> `main`.

## Commit Rules

Use Conventional Commit style. The release workflow reads merged commit subjects
to calculate the next app version.

| Commit type | Version bump |
| --- | --- |
| `chore:` | major |
| `feat:` | minor |
| `fix:` | patch |
| `docs:` | patch |
| `!` or `BREAKING CHANGE:` | major |
| any other releaseable type | patch |

When multiple commit types are merged together, the highest bump wins.

Examples:

```text
feat(calendar): add external calendar import
fix(auth): redirect signed-out users to login
docs(testflight): document tester rollout
chore(signing): rotate distribution certificate
```

## Pull Requests

1. Branch from `dev`.
2. Keep the PR focused.
3. Fill in `.github/pull_request_template.md`.
4. Link related issues.
5. Confirm the local checks pass before requesting review.

Local checks:

```bash
dart format lib test
flutter analyze
flutter test
```

If the `test/` directory does not exist yet, run the checks that are available
and call out the gap in the PR.

## Code Style

- Keep domain entities and repository interfaces under `lib/domain`.
- Keep remote/local IO, DTOs, mappers, and repository implementations under
  `lib/data`.
- Keep screens, widgets, sheets, and BLoCs under `lib/presentation`.
- Wire services through `lib/core/config/dependencies.dart`.
- Use `lib/core/error/error_handler.dart` for normalized error reporting and
  Crashlytics recording.
- Keep generated localization files in sync with `lib/l10n/*.arb`.

## Documentation

When changing architecture, setup, release behavior, backend contracts, or data
flow, update the matching file in `docs/` in the same PR.

## Secrets

Never commit `.env`, signing certificates, provisioning profiles, private API
keys, or App Store Connect keys. CI secrets are documented in
[ENVIRONMENT.md](ENVIRONMENT.md) and [CI_CD.md](CI_CD.md).
