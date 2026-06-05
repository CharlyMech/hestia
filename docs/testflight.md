# TestFlight Deployment Guide

This guide describes how to distribute Hestia to a limited trusted group and
keep testers updated when new builds are released.

Official references:

- Apple TestFlight overview: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/
- Apple TestFlight product page: https://developer.apple.com/testflight/
- Fastlane `pilot` / `upload_to_testflight`: https://docs.fastlane.tools/actions/pilot/
- Flutter iOS release builds: https://docs.flutter.dev/deployment/ios
- GitHub Actions iOS signing: https://docs.github.com/en/actions/how-tos/deploy/deploy-to-third-party-platforms/sign-xcode-applications

## Tester Model

Use internal testers first for a small trusted group that already has App Store
Connect access. Apple supports up to 100 internal testers, and builds are
available for testing for up to 90 days.

Use external testers for trusted people who should not have App Store Connect
access. Apple supports larger external groups, but the first build for external
testing requires TestFlight beta review before distribution.

## One-Time Apple Setup

1. Join the Apple Developer Program.
2. Create or verify the App Store Connect app record for bundle id
   `com.charlymech.hestia`.
3. Configure app metadata required by TestFlight beta review:
   - beta app description,
   - feedback email,
   - privacy policy URL,
   - export compliance answers,
   - demo account information if Apple needs to log in.
4. Create an App Store distribution certificate.
5. Create an App Store provisioning profile for `com.charlymech.hestia`.
6. Create an App Store Connect API key with access to upload builds and manage
   TestFlight metadata.

## One-Time GitHub Setup

Add these repository or environment secrets:

```text
SUPABASE_URL
SUPABASE_PUBLISHABLE_KEY
APPLE_CLIENT_ID
APPLE_REDIRECT_URI
MAGICLANE_API_KEY
FIREBASE_API_KEY
FIREBASE_APP_ID
FIREBASE_PROJECT_ID
FIREBASE_MESSAGING_SENDER_ID
FIREBASE_STORAGE_BUCKET
IOS_DIST_CERT_BASE64
IOS_DIST_CERT_PASSWORD
IOS_PROVISION_PROFILE_BASE64
KEYCHAIN_PASSWORD
APP_STORE_CONNECT_API_KEY_ID
APP_STORE_CONNECT_API_KEY_ISSUER_ID
APP_STORE_CONNECT_API_KEY_BASE64
```

Optional external tester distribution secrets:

```text
TESTFLIGHT_GROUPS
TESTFLIGHT_DISTRIBUTE_EXTERNAL
TESTFLIGHT_NOTIFY_EXTERNAL_TESTERS
```

`TESTFLIGHT_GROUPS` is a comma-separated list of App Store Connect external
tester group names, for example `Trusted Testers,Family`.

## Internal Tester Rollout

1. In App Store Connect, open the Hestia app.
2. Go to TestFlight -> Internal Testing.
3. Create a group such as `Core Testers`.
4. Add trusted App Store Connect users to the group.
5. Enable automatic distribution for new builds if available for the group.
6. Merge the release candidate into `main`.
7. Wait for the GitHub `Release (TestFlight)` workflow to complete.
8. Confirm the build appears in TestFlight and testers can install it.

Internal testers can receive new builds without exposing App Store Connect API
keys or signing assets to them.

## External Tester Rollout

1. In App Store Connect, open TestFlight -> External Testing.
2. Create a group such as `Trusted Testers`.
3. Add tester emails manually or with a public link if you choose to use one.
4. Complete beta review metadata and demo credentials.
5. Add these GitHub Secrets:

```text
TESTFLIGHT_GROUPS=Trusted Testers
TESTFLIGHT_DISTRIBUTE_EXTERNAL=true
TESTFLIGHT_NOTIFY_EXTERNAL_TESTERS=true
```

6. Merge the release candidate into `main`.
7. The workflow uploads the IPA and Fastlane waits for processing so it can
   distribute to the configured external groups.
8. The first externally distributed build waits for Apple beta review.
9. After approval, testers receive their invite or update through TestFlight.

For later builds on the same external testing setup, Apple usually does not
require the same first-build review delay unless metadata or compliance changes
trigger another review.

## Updating Testers

Every merge to `main` creates a new version/build:

```text
chore -> major
feat  -> minor
fix   -> patch
docs  -> patch
```

The workflow also updates `CHANGELOG.md` and sends generated release notes to
Fastlane as the TestFlight changelog. Testers see the update in the TestFlight
app and can install the latest build. External notification behavior is
controlled by App Store Connect and the optional
`TESTFLIGHT_NOTIFY_EXTERNAL_TESTERS` secret.

## Before Merging To Main

Confirm:

- PR CI is green.
- Version bump implied by commits is intentional.
- `.env` secrets exist in GitHub.
- Signing certificate and provisioning profile are not expired.
- App Store Connect API key is active.
- TestFlight tester groups exist if external distribution is enabled.
- Release notes are suitable for testers.

## Emergency Stop

If a bad build reaches testers:

1. Expire the build in App Store Connect.
2. Revert or fix the issue on `dev`.
3. Merge the fix to `main`.
4. Let the workflow publish a newer build.

Do not reuse the same build number.
