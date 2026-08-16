# Environment

## Local Prerequisites

- Flutter stable.
- Xcode with iOS signing support.
- CocoaPods for iOS dependencies.
- Supabase project.
- Firebase project for Crashlytics, Analytics, and FCM.
- MagicLane API key reserved for the planned provider integration; current map
  widgets use CARTO raster tiles.
- Apple Developer Program membership for TestFlight distribution.

## Local Setup

```bash
flutter pub get
cp lib/core/config/env.example.dart lib/core/config/env.dart
```

Fill `lib/core/config/env.dart` with the public client configuration. The file
is ignored by Git and is the app's only runtime configuration source:

```dart
abstract final class Env {
  static const supabaseUrl = '...';
  static const supabaseAnonKey = '...';
  // Apple, MagicLane, and Firebase public client values follow.
}
```

Run:

```bash
flutter run --dart-define=FLAVOR=supabase
```

The app defaults to `supabase`; passing the define keeps local and CI commands
explicit.

## Required GitHub Secrets

Release signing and backend secrets are used only by GitHub Actions:

| Secret | Purpose |
| --- | --- |
| `SUPABASE_URL` | Supabase project URL. |
| `SUPABASE_PUBLISHABLE_KEY` | Supabase publishable or anon key. |
| `APPLE_CLIENT_ID` | Apple Sign-In client id. |
| `APPLE_REDIRECT_URI` | Supabase Apple auth callback URL. |
| `MAGICLANE_API_KEY` | MagicLane maps key. |
| `FIREBASE_API_KEY` | Firebase iOS API key. |
| `FIREBASE_APP_ID` | Firebase iOS app id. |
| `FIREBASE_PROJECT_ID` | Firebase project id. |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase messaging sender id. |
| `FIREBASE_STORAGE_BUCKET` | Firebase storage bucket. |
| `IOS_DIST_CERT_BASE64` | Base64 encoded iOS distribution `.p12`. |
| `IOS_DIST_CERT_PASSWORD` | Password for the `.p12`. |
| `IOS_PROVISION_PROFILE_BASE64` | Base64 encoded App Store provisioning profile. |
| `KEYCHAIN_PASSWORD` | Temporary CI keychain password. |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key id. |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | App Store Connect issuer id. |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64 encoded `.p8` key content. |
| `TESTFLIGHT_GROUPS` | Optional comma-separated external tester groups. |
| `TESTFLIGHT_DISTRIBUTE_EXTERNAL` | Optional `true` to distribute to external groups. |
| `TESTFLIGHT_NOTIFY_EXTERNAL_TESTERS` | Optional `true` or `false` override for external notifications. |

## Secret Handling

- Never commit `lib/core/config/env.dart`.
- Dart constants are bundled with the app and are not secret storage. Never add
  database passwords, Supabase service-role keys, private signing keys, or
  other server credentials to `Env`.
- Never commit `.p8`, `.p12`, `.mobileprovision`, or Firebase private keys.
- Rotate App Store Connect and signing credentials after suspected exposure.
- Use GitHub repository or environment secrets, not workflow literals.
