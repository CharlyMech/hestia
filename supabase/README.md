# Hestia — Supabase backend

Source of truth for the database schema and edge functions. The Flutter app's
DTOs (`lib/data/dtos/*`) are the column contract; migrations match them.

## Layout

```text
migrations/
  0001_extensions.sql          pgcrypto, pg_net (+ pg_cron via dashboard)
  0002_tables.sql              all tables + indexes
  0003_functions_triggers.sql  last_update touch; balance safety-net; reminder enqueue
  0004_rls.sql                 row-level security (household scope + per-user tables)
  0005_seed.sql                default categories, household bootstrap, sample institutions

functions/
  _shared/
    client.ts                  CORS, admin client, recomputeBalance(), insertTransaction()
    google.ts                  Google token refresh + Calendar API helpers

  create-transaction/          insert/update tx + recompute balance  ← authoritative
  delete-transaction/          delete tx + recompute balance
  create-transfer/             insert transfer + recompute both balances
  create-fuel-entry/           fuel entry + optional expense tx + recompute balance
  create-health-record/        pet_health_record + optional expense tx
  create-maintenance-record/   car_maintenance_record + optional expense tx + odometer
  start-shopping-session/      start session + push to household members if shared
  complete-shopping-session/   close session + optional expense tx + recompute balance
  upsert-appointment/          CUD appointment + GCal mirror + reminder enqueue
  delete-appointment/          delete appointment + GCal event removal
  google-oauth-exchange/       serverAuthCode → refresh_token → upsert google_credentials
  google-calendar-sync/        pull GCal → appointments (pg_cron 15 min + on-demand)
  notify/                      inbox insert + FCM v1 push
  process-reminders/           drain scheduled_notifications → notify (pg_cron 1 min)

sql/
  nuke.sql                     drop everything EXCEPT auth.users + profiles
  cron_schedule.sql            pg_cron jobs (process-reminders @ 1 min, gcal-sync @ 15 min)
  superadmin_seed.sql          idempotent superuser upsert by email
```

## Architecture: edge-function-first

Any write with side effects goes through an edge function — never directly from
the client, never in a fat SQL trigger. Balance recompute, transfers, linked
record+transaction pairs, GCal mirroring, and reminder fan-out all live in
`functions/`. DB triggers are thin: `last_update` touch, balance **safety net**
(guards raw SQL writes), and cheap reminder **enqueue** into
`scheduled_notifications`.

## Edge function contracts

| Function | POST body | Returns |
| --- | --- | --- |
| `create-transaction` | `{ transaction, id? }` | `{ transaction }` |
| `delete-transaction` | `{ id }` | `{ ok: true }` |
| `create-transfer` | `{ transfer, id? }` | `{ transfer }` |
| `create-fuel-entry` | `{ entry, transaction?, id? }` | `{ entry, transaction }` |
| `create-health-record` | `{ record, transaction?, id? }` | `{ record, transaction }` |
| `create-maintenance-record` | `{ record, transaction?, id? }` | `{ record, transaction }` |
| `start-shopping-session` | `{ session_id, household_id }` | `{ ok: true }` |
| `complete-shopping-session` | `{ session_id, transaction? }` | `{ session, transaction }` |
| `upsert-appointment` | `{ appointment, id? }` | `{ appointment }` |
| `delete-appointment` | `{ id }` | `{ ok: true }` |
| `google-oauth-exchange` | `{ action: 'link'\|'unlink'\|'status', server_auth_code? }` | `{ linked, email?, last_synced_at? }` |
| `google-calendar-sync` | `{}` (pg_cron) or `{ user_id }` (on-demand) | `{ synced }` |

## Timestamps

Stored as **unix seconds** (`bigint`) everywhere **except** `appointments`,
which uses `timestamptz` (ISO-8601 strings in edge function bodies).

## Key tables

| Table | Notes |
| --- | --- |
| `payment_cards` | 0..N per `bank_account`; partial unique index `where is_primary` |
| `transactions` | `payment_card_id` nullable FK; `pet_id`/`car_id`/`home_id` optional links |
| `car_maintenance_records` | type: mechanic/itv/tires/oil/insurance/other; `transaction_id` optional |
| `pet_health_records` | type: vet/vaccine/medication/grooming/deworming/other; `transaction_id` optional |
| `google_credentials` | RLS deny-all for `authenticated`; service-role only |
| `appointments` | `source` column: `'hestia'` or `'google'` |

## RLS summary

- Most tables: `is_household_member(household_id)` helper function.
- Per-user tables (`notifications`, `device_tokens`, `notification_settings`): `auth.uid() = user_id`.
- `google_credentials`: **deny-all** for `authenticated` role — only service-role (edge functions) can read/write.

## Apply order

```sh
# Reset (dev only)
supabase db execute --file supabase/sql/nuke.sql

# Migrations in order
supabase db execute --file supabase/migrations/0001_extensions.sql
supabase db execute --file supabase/migrations/0002_tables.sql
supabase db execute --file supabase/migrations/0003_functions_triggers.sql
supabase db execute --file supabase/migrations/0004_rls.sql
supabase db execute --file supabase/migrations/0005_seed.sql

# Edge functions
supabase functions deploy --no-verify-jwt \
  create-transaction delete-transaction create-transfer \
  create-fuel-entry create-health-record create-maintenance-record \
  start-shopping-session complete-shopping-session \
  upsert-appointment delete-appointment \
  google-oauth-exchange google-calendar-sync \
  notify process-reminders

# pg_cron jobs
supabase db execute --file supabase/sql/cron_schedule.sql
```

See [SETUP.md](./SETUP.md) for secrets, Firebase setup, Google OAuth, and full
end-to-end runbook.
