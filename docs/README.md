# Hestia Documentation

This directory is the source of truth for project documentation. Root-level
`README.md`, `LICENSE`, and `CHANGELOG.md` remain in the project root for
convention and release automation.

## Index

| Document | Purpose |
| --- | --- |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Branching, commit rules, local checks, and review expectations. |
| [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) | Community standards and reporting process. |
| [SECURITY.md](SECURITY.md) | Supported versions and private vulnerability reporting. |
| [ISSUES.md](ISSUES.md) | Bug report, feature request, and beta feedback workflow. |
| [PULL_REQUESTS.md](PULL_REQUESTS.md) | Pull request checklist and merge expectations. |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Code structure, layers, dependencies, and runtime boot flow. |
| [DATA_FLOW.md](DATA_FLOW.md) | How auth, reads, writes, cache, notifications, and integrations move through the app. |
| [ENVIRONMENT.md](ENVIRONMENT.md) | Local Dart configuration, platform prerequisites, and CI secrets. |
| [SUPABASE_SETUP.md](SUPABASE_SETUP.md) | Supabase project setup notes and backend ownership. |
| [CI_CD.md](CI_CD.md) | Pull request CI and automated TestFlight release workflow. |
| [RELEASES.md](RELEASES.md) | Versioning, changelog, tags, and release rules. |
| [testflight.md](testflight.md) | Step-by-step TestFlight rollout guide for trusted testers. |

## Current Stack

- Flutter iOS app.
- Supabase backend with PostgREST, Auth, Edge Functions, Realtime, and Storage.
- Drift local SQLite database.
- Firebase Crashlytics, Analytics, and FCM.
- BLoC/Cubit state management, `go_router` routing, Cupertino/ForUI UI.
- Fastlane upload to TestFlight from GitHub Actions.
