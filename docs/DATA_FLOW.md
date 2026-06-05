# Data Flow

This document describes how data moves through Hestia as the codebase exists
today.

## Read Flow

```text
Screen -> Bloc/Cubit -> domain repository -> data repository implementation
  -> Supabase service -> Supabase table/function
  -> mapper/DTO -> domain entity -> Bloc state -> UI
```

Example: transactions are requested by a presentation BLoC, loaded through
`TransactionRepository`, fetched by `TransactionService`, mapped by
`TransactionMapper`, and emitted back as domain `Transaction` objects.

## Write Flow

```text
Form widget -> form Bloc -> domain entity -> repository
  -> DTO/mapper -> Supabase insert/update/delete
  -> returned row or Failure -> Bloc state -> UI feedback
```

Repositories catch service exceptions and convert them to `Failure` objects via
`mapExceptionToFailure`. The presentation layer should not catch raw Supabase
exceptions.

## Authentication Flow

1. `AuthBloc` starts with `AuthCheckSession`.
2. `AuthRepositoryImpl` delegates to `AuthService`.
3. `AuthService` checks Supabase Auth and refreshes expired sessions.
4. Valid sessions require biometric verification when available.
5. Successful auth loads or creates the Supabase `profiles` row.
6. `HestiaApp` updates router auth state, Crashlytics user identity, and push
   notification registration.

Sign-in supports email/password and Apple Sign-In through Supabase Auth.

## Local Cache Flow

Drift opens a local SQLite database at startup. Local tables currently cover
transactions, categories, bank accounts, goals, notifications, financial
institutions, cards, and account members.

Local schema changes must:

- update the Drift table definition,
- increase `AppDatabase.schemaVersion`,
- add a migration path in `AppDatabase.migration`,
- regenerate `app_database.g.dart`.

## Realtime And Notifications

- `ShoppingRealtimeService` owns shopping-session realtime behavior.
- `PushNotificationService` initializes after authentication with the signed-in
  user id.
- Notification data is accessed through `NotificationRepository`.
- Crashlytics records fatal and selected non-fatal errors when Firebase is
  configured and the app is not in debug mode.

## Calendar Flow

Appointment data is handled by `AppointmentRepositoryImpl`, which combines the
Supabase appointment service with `GoogleCalendarService` where calendar sync is
enabled. Per-event sharing and sync behavior should stay behind repository and
service boundaries.

## Map And Location Flow

Location-aware features store optional latitude and longitude on domain objects
where supported. UI map selection flows should return coordinates to the calling
screen, and persistence should remain in the relevant feature repository.

## Version Flow

The user-facing version comes from `pubspec.yaml` and Flutter build arguments:

- build name: semantic version, for example `1.2.0`;
- build number: CI run number, for example `48`.

The release workflow updates `pubspec.yaml`, `CHANGELOG.md`, and the GitHub
release tag after a successful TestFlight upload.
