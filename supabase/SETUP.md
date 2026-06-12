# Hestia — Backend recreate + Firebase from scratch

End-to-end runbook to rebuild the Supabase backend and wire a brand-new
Firebase project for push notifications.

---

## A. Supabase backend recreate

### Prerequisites
- `supabase` CLI installed (`brew install supabase/tap/supabase`)
- Project ref, DB password, and the **service-role** key (dashboard → Settings → API)

### Steps

1. **Link the project**
   ```bash
   supabase link --project-ref <PROJECT_REF>
   ```

2. **Nuke existing objects** (⚠️ preserves only `auth.users` + `profiles`)
   Run `supabase/nuke.sql` in the dashboard SQL editor, or:
   ```bash
   supabase db execute --file supabase/nuke.sql
   ```

3. **Apply migrations in order**
   ```bash
   for f in 0001_extensions 0002_tables 0003_functions_triggers 0004_rls 0005_seed; do
     supabase db execute --file "supabase/migrations/$f.sql"
   done
   ```

4. **Enable extensions** (dashboard → Database → Extensions)
   - `pgcrypto` (usually on)
   - `pg_net`
   - `pg_cron` — if unavailable on your plan, skip and use the client-scheduled
     local-notification fallback (the app still shows reminders; only the
     server push fan-out is deferred).

5. **Deploy edge functions**
   ```bash
   supabase functions deploy notify create-transaction delete-transaction \
     create-transfer process-reminders
   ```

6. **Set function secrets**
   ```bash
   supabase secrets set \
     SUPABASE_URL="https://<ref>.supabase.co" \
     SUPABASE_SERVICE_ROLE_KEY="<service-role-key>" \
     FIREBASE_PROJECT_ID="<firebase-project-id>" \
     FIREBASE_SERVICE_ACCOUNT_JSON='<single-line service account json>'
   ```
   (`SUPABASE_URL` / `SUPABASE_SERVICE_ROLE_KEY` are auto-injected at runtime,
   but setting them explicitly keeps local `serve` working.)

7. **Schedule reminder delivery** (requires `pg_cron` + `pg_net`)
   In the SQL editor:
   ```sql
   select cron.schedule(
     'process-reminders',
     '* * * * *',                       -- every minute
     $$
     select net.http_post(
       url     := 'https://<ref>.supabase.co/functions/v1/process-reminders',
       headers := jsonb_build_object(
         'Authorization', 'Bearer <service-role-key>',
         'Content-Type',  'application/json'),
       body    := '{}'::jsonb
     );
     $$
   );
   ```
   No `pg_cron`? Trigger `process-reminders` from any external scheduler
   (GitHub Actions cron, Upstash, etc.) hitting the same URL.

---

## B. Firebase project from scratch

1. **Create the project** at <https://console.firebase.google.com>.

2. **Register apps**
   - iOS app, bundle id `com.charlymech.hestia` → download
     `GoogleService-Info.plist` → place in `ios/Runner/`.
   - Android app, package `com.charlymech.hestia` → download
     `google-services.json` → place in `android/app/`.
   - Both files are gitignored secrets — do not commit.

3. **Enable Cloud Messaging (FCM v1)**
   Google Cloud console → APIs & Services → enable *Firebase Cloud Messaging API*
   for this project.

4. **iOS APNs key**
   Apple Developer → Keys → create an APNs Auth Key (`.p8`).
   Firebase → Project settings → Cloud Messaging → upload the `.p8` with its
   Key ID and your Team ID.

5. **Service account for the edge function**
   Firebase → Project settings → Service accounts → *Generate new private key*.
   - The downloaded JSON (minified to one line) is `FIREBASE_SERVICE_ACCOUNT_JSON`.
   - `FIREBASE_PROJECT_ID` is the `project_id` field inside it.
   Set both as Supabase secrets (step A.6).

6. **Flutter wiring**
   ```bash
   flutterfire configure        # regenerates lib/firebase_options.dart if used
   flutter pub get
   ```
   Confirm `firebase_core` initializes before
   `PushNotificationService.initialize(userId)` runs.

---

## C. Smoke checklist

1. Register a device: launch the app signed-in → a row appears in `device_tokens`.
2. Manual push:
   ```bash
   curl -X POST 'https://<ref>.supabase.co/functions/v1/notify' \
     -H "Authorization: Bearer <service-role-key>" \
     -H 'Content-Type: application/json' \
     -d '{"type":"test","household_id":"<hh>","user_ids":["<uid>"],
          "title":"Hello","body":"It works"}'
   ```
   → inbox row in `notifications` + push on device.
3. Create a transaction in the app → `create-transaction` updates
   `bank_accounts.current_balance` (verify in dashboard).
4. Create a shopping list → succeeds (no `created_by` error).
5. Create an appointment with a reminder → row in `scheduled_notifications`;
   after `deliver_at`, `process-reminders` delivers it.
