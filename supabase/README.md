# Hestia — Supabase backend

Source of truth for the database schema and edge functions. The Flutter app's
data layer (`lib/data/*`) is the column contract; migrations match it. This file
documents the **current state** of the database and how to evolve it. For the
end-to-end recreate + Firebase runbook see [SETUP.md](./SETUP.md).

## Layout

```text
migrations/
  0001_extensions.sql          pgcrypto, pg_net (+ pg_cron via dashboard)
  0002_tables.sql              all tables + indexes
  0003_functions_triggers.sql  last_update touch; balance safety-net; reminder enqueue
  0004_rls.sql                 row-level security (household scope + per-user tables)
  0005_seed.sql                default categories, household bootstrap, sample institutions
  0006_birth_date_text.sql     birth_date columns bigint → text

functions/
  _shared/
    client.ts                  CORS, admin client, recomputeBalance(), insertTransaction(), invokeNotify()
    google.ts                  Google token refresh + Calendar API helpers

  create-transaction/          insert/update tx + recompute balance  ← authoritative
  delete-transaction/          delete tx + recompute balance
  create-transfer/             insert transfer + recompute both balances
  create-fuel-entry/           fuel entry + optional expense tx + recompute balance
  create-health-record/        pet_health_record + optional expense tx
  create-maintenance-record/   car_maintenance_record + optional expense tx + odometer
  start-shopping-session/      mark session started + push to household members if shared
  complete-shopping-session/   close session (paid/cancelled) + optional expense tx + recompute balance
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

Any write with **side effects** — balance recompute, fan-out, derived/aggregate
state, multi-row atomic operations — goes through an edge function, never
directly from the client and never as a fat SQL trigger. DB triggers stay thin:
`last_update` touch, balance **safety net** (guards raw SQL writes), and the
reminder **enqueue** into `scheduled_notifications`. The client calls
`functions.invoke(...)` and uses the response.

## Entities

Grouped by domain. **Timestamps are unix seconds (`bigint`)** everywhere except
`appointments` (`timestamptz`, ISO-8601 strings in edge bodies). All `id`s are
`uuid` (`gen_random_uuid()`). Most tables FK to `households(id)` and are scoped by
RLS to household membership.

### Identity & household

- `profiles` — one per `auth.users` row; superadmin flag, display fields.
- `households`, `household_members` — a household and its member profiles (with `role`).

### Finances

- `financial_institutions` — banks/issuers (some seeded).
- `bank_accounts` — `initial_balance` + derived `current_balance`; `account_members` shares an account with users.
- `payment_cards` — 0..N per `bank_account`; partial unique index `where is_primary` (≤1 primary/account); `CardNetwork` enum.
- `categories` — income/expense/adjustment categories (seeded defaults).
- `transaction_sources` — a merchant/place (optional lat/lng/address); a source *is* its location.
- `transactions` — `bank_account_id` (required), `payment_card_id` (optional FK), `transaction_source_id`, `category_id`, `amount`, `currency`, `type` (income|expense|adjustment), `latitude`/`longitude`, optional `pet_id`/`car_id`/`home_id`.
- `transfers` — between two `bank_accounts`.
- `financial_goals`, `goal_contributions` — savings goals against an account.

### Vehicles

- `cars`, `car_members`, `fuel_entries`, `car_maintenance_records` (type: mechanic/itv/tires/oil/insurance/other; optional `transaction_id`).

### Pets

- `pets`, `pet_health_records` (type: vet/vaccine/medication/grooming/deworming/other; optional `transaction_id`), `pet_measurements`.

### Home & shopping

- `homes`.
- `shopping_lists` — see shopping model below.
- `shopping_list_items` — the line items.
- `shopping_sessions` — start/end audit rows for an in-progress shopping run.

### Planning & notifications

- `appointments` (`timestamptz`; `source` = `'hestia'` | `'google'`), `appointment_pets`.
- `notifications`, `notification_settings`, `device_tokens` — per-user (scoped by `auth.uid()`).
- `scheduled_notifications` — reminder queue drained by `process-reminders`.
- `google_credentials` — RLS deny-all for `authenticated`; service-role only.
- `app_versions` — drives in-app update prompts.

## Shopping model (relations)

```text
shopping_lists (household-scoped)
  • kind   : template | session         (a reusable blueprint vs an actual trip)
  • status : active | paid | cancelled
  • scope  : personal | shared
  • template_id → shopping_lists(id)    (self-ref; set on a session spawned from a template)
  • bank_account_id / transaction_id / transaction_source_id (optional)
  • session_started_at / session_ended_at / paid_at (unix bigint)
  └─ shopping_list_items (list_id → shopping_lists, cascade)
       • name, qty (int default 1), sort_order (int default 0)
       • is_checked, checked_at
  └─ shopping_sessions (list_id, household_id) — started_at / ended_at audit rows
```

- A **template** stays editable. A **session** locks once `status != active`.
- Starting a session from a template creates a new `session` list and **copies the
  template's items** (name, qty, order; unchecked) — done in
  `ShoppingRepositoryImpl.startShoppingSession`, which then invokes
  `start-shopping-session` so shared sessions push a notification to the household.
- Finishing a session goes through `complete-shopping-session`: optionally creates
  the linked expense `transaction` (and recomputes the account balance), sets
  `status='paid'` + `transaction_id` + `paid_at`, and stamps `session_ended_at`.
  Cancelling sets `status='cancelled'`.

> **Status/scope vocabulary is canonical in the Dart enums**
> (`ShoppingListStatus`/`ShoppingListScope`): `active|paid|cancelled` and
> `personal|shared`. The shopping edge functions write these exact values. (The DB
> column defaults `scope='household'`/`kind='list'` from early schema; the app only
> ever writes the enum values.)

## Edge function contracts

| Function | POST body | Returns |
| --- | --- | --- |
| `create-transaction` | `{ transaction, id? }` | `{ transaction }` |
| `delete-transaction` | `{ id }` | `{ ok: true }` |
| `create-transfer` | `{ transfer, id? }` | `{ transfer }` |
| `create-fuel-entry` | `{ entry, transaction?, id? }` | `{ entry, transaction }` |
| `create-health-record` | `{ record, transaction?, id? }` | `{ record, transaction }` |
| `create-maintenance-record` | `{ record, transaction?, id? }` | `{ record, transaction }` |
| `start-shopping-session` | `{ list_id, user_id }` | `{ list, notified }` |
| `complete-shopping-session` | `{ list_id, transaction?, cancelled? }` | `{ list, transaction }` |
| `upsert-appointment` | `{ appointment, id? }` | `{ appointment }` |
| `delete-appointment` | `{ id }` | `{ ok: true }` |
| `google-oauth-exchange` | `{ action: 'link'\|'unlink'\|'status', server_auth_code? }` | `{ linked, email?, last_synced_at? }` |
| `google-calendar-sync` | `{}` (pg_cron) or `{ user_id }` (on-demand) | `{ synced }` |

## RLS summary

- Most tables: `is_household_member(household_id)` helper function.
- Per-user tables (`notifications`, `device_tokens`, `notification_settings`): `auth.uid() = user_id`.
- `google_credentials`: **deny-all** for `authenticated` — only service-role (edge functions) read/write.

## Making a schema change

1. **Change the Dart data layer first.** Update the entity + the
   `_fromJson`/`_toJson` mapping in the repository impl (or DTO/mapper) — that pair
   is the column contract. Dart fields are `camelCase`; columns/JSON are `snake_case`;
   the mapper is the boundary.
2. **Add a numbered migration.** Next number is **`0007_<description>.sql`** (highest
   today is `0006`). Write idempotent DDL (`alter table … add column if not exists`,
   `create index if not exists`). Update RLS in the same or a follow-up migration if
   the new table/column needs policies.
3. **Side-effecting write? Add/extend an edge function** rather than writing from the
   client. Keep triggers thin.
4. **Apply + redeploy** (see below), then run the smoke checklist in SETUP.md.

## Apply order

```sh
# Reset (dev only)
supabase db execute --file supabase/sql/nuke.sql

# Migrations in order
for f in 0001_extensions 0002_tables 0003_functions_triggers 0004_rls 0005_seed 0006_birth_date_text; do
  supabase db execute --file "supabase/migrations/$f.sql"
done

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

See [SETUP.md](./SETUP.md) for secrets, Firebase setup, Google OAuth, and the full
end-to-end runbook.
