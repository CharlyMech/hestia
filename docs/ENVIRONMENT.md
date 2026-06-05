# Environment

## Local Prerequisites

- Flutter stable.
- Xcode with iOS signing support.
- CocoaPods for iOS dependencies.
- Supabase project.
- Firebase project for Crashlytics, Analytics, and FCM.
- MagicLane API key for maps.
- Apple Developer Program membership for TestFlight distribution.

## Local Setup

```bash
flutter pub get
cp .env.example .env
```

Fill `.env` with non-placeholder values:

```text
SUPABASE_URL=
SUPABASE_ANON_KEY=
APPLE_CLIENT_ID=
APPLE_REDIRECT_URI=
MAGICLANE_API_KEY=
FIREBASE_API_KEY=
FIREBASE_APP_ID=
FIREBASE_MESSAGING_SENDER_ID=
FIREBASE_PROJECT_ID=
FIREBASE_STORAGE_BUCKET=
FIREBASE_IOS_BUNDLE_ID=
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

- Never commit `.env`.
- Never commit `.p8`, `.p12`, `.mobileprovision`, or Firebase private keys.
- Rotate App Store Connect and signing credentials after suspected exposure.
- Use GitHub repository or environment secrets, not workflow literals.
