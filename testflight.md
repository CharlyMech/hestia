# Deploying Hestia to TestFlight — From Zero

This is a complete, first-time guide to getting Hestia onto your household's
iPhones through **TestFlight**, Apple's beta-distribution system. It assumes you
have **never deployed an iOS app before**. Follow it top to bottom once; after
that, releases are automatic on every push to `main`.

> **Why TestFlight and not the App Store?** TestFlight lets you distribute a real
> signed build to a small set of trusted people (your family) without a public
> App Store listing, App Store review for every build, or a privacy/marketing
> page. It is the right tool for an app only your household uses.

## What you'll end up with

- An Apple Developer account and an App Store Connect app record.
- Signing handled by **Fastlane match** (certificates and provisioning profiles
  stored encrypted in a private git repo — no manual `.p12` juggling).
- A GitHub Actions workflow that, on every push to `main`, bumps the version,
  builds a signed IPA, uploads it to TestFlight, tags and releases on GitHub,
  and records the new version in Supabase.
- Family members who get the new build in the TestFlight app and an in-app
  "update available" prompt.

## Vocabulary (read once)

| Term | What it means |
| --- | --- |
| **Bundle ID** | Unique app identifier. Hestia's is `com.charlymech.hestia`. |
| **Signing certificate** | Proves *you* built the app. The "distribution" one is used for TestFlight/App Store. |
| **Provisioning profile** | Links your certificate + bundle ID + capabilities so Apple lets the build run/distribute. |
| **App Store Connect (ASC)** | Apple's web console where the app record, TestFlight, and testers live. |
| **ASC API key** | A `.p8` file that lets CI talk to App Store Connect without your password / 2FA. |
| **Fastlane** | Automation tool that uploads builds and (via `match`) manages signing. |
| **match** | A Fastlane feature that stores signing assets in a private git repo and syncs them everywhere. |
| **IPA** | The packaged, signed iOS app binary that gets uploaded. |
| **Internal vs external testers** | Internal: up to 100 people with ASC access, no Apple review. External: more people, first build needs a quick Apple beta review. |

For your household, **internal testers** are almost certainly what you want.

---

## Part 1 — Apple Developer Program (one time, ~1 day)

1. Go to <https://developer.apple.com/programs/> and **enroll**. It costs
   **99 USD/year**. Enroll as an **Individual** (simplest for a personal app).
2. Enrollment may take a few hours to a day to be approved. You need an iPhone
   with the Apple Developer app or a Mac to confirm your identity.
3. When approved, sign in to **App Store Connect**: <https://appstoreconnect.apple.com/>.

You now have a **Team** with a **Team ID** (you'll need it later — find it at
<https://developer.apple.com/account> under *Membership details*).

---

## Part 2 — Create the App Store Connect app record (one time)

1. In App Store Connect, open **Apps** → **+** → **New App**.
2. Fill in:
   - **Platform:** iOS
   - **Name:** Hestia (must be unique across the App Store; if taken, use a
     variant like "Hestia Household" — only your testers see it)
   - **Primary language:** your choice
   - **Bundle ID:** select or register `com.charlymech.hestia`. If it isn't in
     the list, go to <https://developer.apple.com/account/resources/identifiers/list>
     and register it as an **App ID** first.
   - **SKU:** any internal string, e.g. `hestia-001`
3. Create the app. You do **not** need to fill in App Store marketing metadata —
   that's only for public release, not TestFlight internal testing.

---

## Part 3 — App Store Connect API key (one time)

This key lets GitHub Actions and Fastlane upload builds without your Apple
password or 2FA.

1. In App Store Connect, go to **Users and Access** → **Integrations** tab →
   **App Store Connect API**.
2. Click **+** to generate a key. Give it the **App Manager** role (it must be
   able to upload builds and manage TestFlight).
3. Note these three values — you'll store them as GitHub secrets:
   - **Issuer ID** (shown at the top of the keys page)
   - **Key ID** (the row's identifier)
   - The **`.p8` file** — **download it now; Apple only lets you download once.**

Keep the `.p8` somewhere safe (a password manager). If you lose it, revoke and
make a new one.

---

## Part 4 — Set up Fastlane match for signing (one time)

`match` removes the painful part of iOS signing: you never manually create or
export certificates again. It generates them once, encrypts them, and stores
them in a **private git repo** that CI reads.

### 4.1 Create a private "certificates" repo

On GitHub, create a **new private repository**, e.g. `hestia-certificates`.
Leave it empty. This will hold your encrypted signing assets. **Never make it
public.**

### 4.2 Install Fastlane locally

On your Mac:

```bash
brew install fastlane
# or: gem install fastlane
```

### 4.3 Configure match

The repo already has `ios/fastlane/Appfile` and `ios/fastlane/Fastfile`. Add a
`Matchfile` (the release setup below includes one). From the `ios/` directory,
run match once to generate and store the App Store signing assets:

```bash
cd ios
fastlane match appstore
```

The first run will:

- Ask for the **git URL** of your private certificates repo
  (`git@github.com:<you>/hestia-certificates.git`).
- Ask you to set a **match passphrase** — this encrypts the assets. **Save this
  passphrase**; CI needs it.
- Create a **distribution certificate** and an **App Store provisioning
  profile** for `com.charlymech.hestia`, then push them encrypted to the repo.

If it asks you to log in to Apple, use your Apple ID, or set the ASC API key env
vars (Part 5) so it runs non-interactively.

> If you ever get *"Could not create another certificate, reached limit"*, run
> `fastlane match nuke distribution` to clear old ones, then `fastlane match
> appstore` again. Only do this when no other build depends on them.

### 4.4 Point Xcode at manual signing

Open `ios/Runner.xcworkspace` in Xcode → **Runner** target → **Signing &
Capabilities**:

- **Uncheck** "Automatically manage signing".
- Set **Team** to your team, and the provisioning profile to the
  `match AppStore com.charlymech.hestia` one that now appears.

Commit any resulting changes to `ios/Runner.xcodeproj`.

---

## Part 5 — GitHub secrets (one time)

In the **Hestia** repo: **Settings** → **Secrets and variables** → **Actions** →
**New repository secret**. Add each of these.

### Signing / Apple (new)

| Secret | Value |
| --- | --- |
| `APP_STORE_CONNECT_API_KEY_ID` | The Key ID from Part 3. |
| `APP_STORE_CONNECT_API_KEY_ISSUER_ID` | The Issuer ID from Part 3. |
| `APP_STORE_CONNECT_API_KEY_BASE64` | The `.p8` contents, base64-encoded (see below). |
| `MATCH_GIT_URL` | SSH URL of your private certificates repo. |
| `MATCH_PASSWORD` | The match passphrase from Part 4.3. |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 of `username:personal_access_token` so CI can clone the private certs repo over HTTPS (see below). |
| `APPLE_TEAM_ID` | Your Team ID from Part 1. |

Encode the `.p8`:

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy   # now paste into the secret
```

Create the match git auth token: make a GitHub **Personal Access Token**
(classic, `repo` scope) that can read the certificates repo, then:

```bash
echo -n "your-github-username:ghp_yourtoken" | base64 | pbcopy
```

If you instead use the SSH URL form for `MATCH_GIT_URL`, you'd add a deploy key;
the HTTPS + `MATCH_GIT_BASIC_AUTHORIZATION` route is simpler in Actions, so this
guide uses it. Set `MATCH_GIT_URL` to the **HTTPS** URL
(`https://github.com/<you>/hestia-certificates.git`) when using basic auth.

### Backend / app (you likely already have these)

| Secret | Value |
| --- | --- |
| `SUPABASE_URL` | Supabase project URL. |
| `SUPABASE_PUBLISHABLE_KEY` | Supabase anon/publishable key. |
| `SUPABASE_SERVICE_ROLE_KEY` | Service-role key (used to record the released version). |
| `APPLE_CLIENT_ID` | Apple Sign-In client id. |
| `APPLE_REDIRECT_URI` | Supabase Apple auth callback URL. |
| `MAGICLANE_API_KEY` | MagicLane maps key. |
| `FIREBASE_API_KEY` | Firebase iOS API key. |
| `FIREBASE_APP_ID` | Firebase iOS app id. |
| `FIREBASE_PROJECT_ID` | Firebase project id. |
| `FIREBASE_MESSAGING_SENDER_ID` | Firebase messaging sender id. |
| `FIREBASE_STORAGE_BUCKET` | Firebase storage bucket. |
| `TESTFLIGHT_APP_URL` | Public TestFlight invite link (optional; deep-links the in-app "Update" button). |

The full list and its rationale also live in [ENVIRONMENT.md](ENVIRONMENT.md).

---

## Part 6 — Supabase `app_versions` table (one time)

The release workflow writes the new version into an `app_versions` table, and
the app reads it on launch to show an "update available" prompt. Create the
table if it doesn't exist:

```sql
create table if not exists public.app_versions (
  id uuid primary key default gen_random_uuid(),
  platform text not null default 'ios',
  version text not null,
  build_number int not null,
  release_tag text,
  release_notes text,
  testflight_url text,
  is_required boolean not null default false,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (platform, version, build_number)
);

-- Anyone signed in can read the latest version.
alter table public.app_versions enable row level security;

create policy "app_versions readable by authenticated"
  on public.app_versions for select
  to authenticated
  using (true);
```

The workflow writes with the **service-role key**, which bypasses RLS, so no
write policy is needed. Set `is_required = true` manually on a row only if you
want to force an update (the in-app dialog then hides "Later").

---

## Part 7 — First release

1. Make sure every secret in Part 5 exists.
2. Confirm `pubspec.yaml` shows the version you expect (currently `1.0.0+1`).
3. Push to `main` (or use **Actions → Release (TestFlight) → Run workflow** for
   a manual `workflow_dispatch` run).
4. Watch the **Release (TestFlight)** workflow. The first run takes ~15–25 min
   (no caches yet). It will:
   - bump the version from the branch/commit type,
   - sync signing via `match`,
   - build and upload the IPA,
   - record the version in Supabase,
   - tag the commit and create a GitHub release.
5. In App Store Connect → your app → **TestFlight**, the build appears under
   **iOS builds**. Processing can take a few minutes after upload.

### Add your testers

1. In **TestFlight → Internal Testing**, create a group, e.g. `Family`.
2. **Add testers** by their Apple ID email. They must be added under **Users and
   Access** first (give them a basic role) to be internal testers.
3. Enable **automatic distribution** for the group so new builds reach them
   without manual steps.
4. Each tester installs the **TestFlight** app from the App Store, accepts the
   invite email, and installs Hestia from there.

> Want more than ~100 people or testers without ASC access? Use **External
> Testing** instead — but the first external build needs a short Apple beta
> review, and you must fill in a beta description, feedback email, and export
> compliance answer. For a household, stick with internal.

---

## Day-to-day: how releases work after setup

You never touch signing or versions by hand again. The rule is just **the branch
name**:

| Branch prefix | Version bump | `1.0.0` becomes |
| --- | --- | --- |
| `chore/` | major | `2.0.0` |
| `feat/` | minor | `1.1.0` |
| `fix/` | patch | `1.0.1` |
| `docs/` | patch | `1.0.1` |

(While developing directly on `main` at `v1.0.0`, the commit type drives the
bump instead — `feat:` → minor, etc.)

Merge/push to `main` → the workflow does the rest. Testers see the new build in
TestFlight, and the app shows the update prompt on next launch. See
[CI_CD.md](CI_CD.md) and [RELEASES.md](RELEASES.md) for the mechanics.

---

## Troubleshooting

**`security: SecKeychainItemImport ... not valid`** — the old manual-cert path
(base64 `.p12` in secrets) was empty/invalid. With `match` this step no longer
exists; make sure you're on the updated `release.yml`.

**`Could not install WWDR certificate` / signing errors in CI** — `match`
couldn't read the certs repo. Check `MATCH_GIT_URL`, `MATCH_PASSWORD`, and
`MATCH_GIT_BASIC_AUTHORIZATION`.

**Upload rejected: "build number already used"** — every build number must be
unique per version. The workflow uses the GitHub run number as the build, so
this only happens if you re-run with a stale number. Push a new commit.

**Build doesn't appear in TestFlight** — Apple is still *processing* it. Wait a
few minutes and refresh. Processing failures show up as an email from Apple.

**Tester can't install** — they must (1) be added under Users and Access, (2)
accept the TestFlight invite, (3) have the TestFlight app installed.

**Need to pull a bad build** — in App Store Connect, **expire** the build, then
push a fix to `main` to ship a newer one. Never reuse a build number.

## Official references

- TestFlight overview: <https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/>
- App Store Connect API keys: <https://developer.apple.com/documentation/appstoreconnectapi/creating-api-keys-for-app-store-connect-api>
- Fastlane match: <https://docs.fastlane.tools/actions/match/>
- Fastlane `upload_to_testflight`: <https://docs.fastlane.tools/actions/upload_to_testflight/>
- Flutter iOS deployment: <https://docs.flutter.dev/deployment/ios>
