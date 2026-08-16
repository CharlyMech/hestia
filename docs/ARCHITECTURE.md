# Architecture

Hestia is a Flutter iOS app for household finance, shared logistics, pets,
cars, shopping, homes, maps, and calendar workflows.

## Application Layers

```text
lib/
  core/           app bootstrap, router, dependency wiring, constants, errors
  domain/         entities and repository contracts
  data/           Supabase services, DTOs, mappers, repository implementations
  presentation/   screens, sheets, widgets, BLoCs, Cubits
  l10n/           ARB files and generated localizations
```

The dependency direction is:

```text
presentation -> domain contracts -> data implementations -> platform/backend IO
```

Domain entities stay pure Dart. Supabase payload shape belongs in DTOs and
mappers under `lib/data`.

## Boot Flow

1. `lib/main.dart` calls `bootstrap()`.
2. `bootstrap()` reads the Dart client configuration, loads app version info,
   and initializes Firebase, Crashlytics, and Supabase.
3. Drift opens `hestia.db`.
4. `AppDependencies.initialize()` constructs services and repositories.
5. `HestiaApp` installs top-level BLoCs and starts `CupertinoApp.router`.
6. `AuthBloc` checks the session and updates `authStatusListenable`.
7. `go_router` redirects between splash, onboarding, login, and the main shell.

## Current Flavor

`FLAVOR` currently resolves to `supabase` only. Older mock repositories have
been removed from the codebase, so documentation and release automation should
treat Supabase as the active runtime backend.

Run locally with:

```bash
flutter run --dart-define=FLAVOR=supabase
```

## State Management

- Top-level app state lives in BLoCs under `lib/presentation/blocs`.
- Feature screens own feature-specific BLoCs or Cubits.
- BLoCs depend on domain repository contracts.
- Repositories return `(value, Failure?)` tuples instead of throwing into the
  presentation layer.

## Routing

Routes are centralized in `lib/core/config/router.dart`.

- `AppRoutes.main` hosts the persistent tab shell.
- Detail and edit screens are pushed routes.
- Auth redirects are driven by `authStatusListenable`.
- `rootNavigatorKey` is available for notification routing and global UI.

## Backend And Local Storage

- Supabase is accessed through services extending `SupabaseService`.
- Table names are centralized in `lib/core/constants/supabase_tables.dart`.
- Drift tables live in `lib/data/local/drift/tables`.
- `AppDatabase.schemaVersion` owns local database migrations.
- Firebase handles Crashlytics, Analytics, and push messaging.
- `flutter_map` with CARTO raster tiles powers the current map and
  location-aware screens. The MagicLane client setting is reserved for a
  provider integration and is not consumed by the current map widgets.

## UI

The app uses Cupertino structure with ForUI theming. Shared visual primitives
live in `lib/presentation/widgets/common`; repeated domain cards live in
`lib/presentation/widgets/cards`.

## Generated Files

Generated files should be updated with their source:

- `lib/l10n/generated/*` from `lib/l10n/*.arb`.
- `lib/data/local/drift/app_database.g.dart` from Drift table definitions.
- iOS icon and launch assets from the configured Flutter asset generators.
