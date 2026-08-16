# CI/CD

Hestia uses GitHub Actions for pull request validation and TestFlight release
deployment.

## Pull Request CI

Workflow: `.github/workflows/ci.yml`

Runs on pull requests targeting `dev` or `main`, and on direct pushes to those
branches.

Checks:

```bash
flutter pub get
cp lib/core/config/env.example.dart lib/core/config/env.dart
dart format --output=none --set-exit-if-changed lib
flutter analyze
flutter test
```

If no `test/` directory exists, the test step reports that and exits
successfully.

## TestFlight Release

Workflow: `.github/workflows/release.yml`

Runs on:

- push to `main`,
- manual `workflow_dispatch`.

The workflow:

1. Checks out full history and tags.
2. Installs Flutter.
3. Runs `scripts/prepare_release.py`.
4. Updates `pubspec.yaml`, `CHANGELOG.md`, and `build/release-notes.md`.
5. Generates the ignored Dart client configuration from GitHub Secrets.
6. Imports the iOS distribution certificate and provisioning profile into a
   temporary macOS keychain.
7. Builds a signed IPA with `flutter build ipa`.
8. Uploads the IPA to TestFlight with Fastlane.
9. Commits the version and changelog update back to `main` with `[skip ci]`.
10. Tags the release and creates a GitHub release with the generated notes.

## Versioning

On pushes to `main`, the release script reads the commits included in that push.
On manual runs, it falls back to commits since the latest `v*` tag.

| Commit type | Bump |
| --- | --- |
| `chore:` or breaking change | major |
| `feat:` | minor |
| `fix:` or `docs:` | patch |
| other releaseable commits | patch |

Highest bump wins when a merge contains multiple commit types.

## TestFlight Distribution Modes

Default behavior uploads the build and relies on App Store Connect settings for
internal tester availability. For external tester groups, set:

```text
TESTFLIGHT_GROUPS=Trusted Testers
TESTFLIGHT_DISTRIBUTE_EXTERNAL=true
TESTFLIGHT_NOTIFY_EXTERNAL_TESTERS=true
```

External distribution waits for build processing and may require TestFlight beta
review before testers can install the build.

## Required Secrets

See [ENVIRONMENT.md](ENVIRONMENT.md) for the complete secret list.

## Common Failures

- Signing failure: certificate and provisioning profile do not match the bundle
  id or Apple team.
- Upload failure: App Store Connect API key lacks permission or belongs to the
  wrong issuer.
- Processing delay: Apple can take time to process an IPA before it appears in
  TestFlight.
- Version rejection: build number must be unique for the app version in App
  Store Connect.
