# Hestia — Supabase backend

Source of truth for the database schema and edge functions. The Flutter app's
DTOs (`lib/data/dtos/*`) are the column contract; these migrations match them.

## Layout

```
migrations/
  0001_extensions.sql        pgcrypto, pg_net (+ pg_cron via dashboard)
  0002_tables.sql            all tables (no payment_cards)
  0003_functions_triggers.sql touch last_update; balance safety-net; reminder enqueue
  0004_rls.sql               row-level security
  0005_seed.sql              default categories, household bootstrap, sample institutions
functions/
  notify/                    inbox insert + FCM v1 push (existing)
  create-transaction/        insert/update tx + recompute balance  ← authoritative
  delete-transaction/        delete tx + recompute balance
  create-transfer/           insert transfer + recompute both balances
  process-reminders/         drain scheduled_notifications → notify (pg_cron)
  _shared/client.ts          CORS, admin client, recomputeBalance()
nuke.sql                     drop everything EXCEPT auth.users + profiles
SETUP.md                     full recreate runbook + Firebase-from-scratch
```

## Architecture: edge-function-first

Any write with side effects goes through an edge function, not the client and
not a fat SQL trigger. Balance recompute, transfers, and reminder fan-out all
live in `functions/`. The DB triggers are thin: `last_update` touch, a balance
**safety net** (guards direct SQL writes), and a cheap reminder **enqueue**.

## Timestamps

Stored as **unix seconds** (`bigint`) to match the app's `.toUnix/.fromUnix`.

## Apply order

```
supabase db execute --file supabase/migrations/0001_extensions.sql
# … 0002 → 0005, in order
supabase functions deploy notify create-transaction delete-transaction \
  create-transfer process-reminders
```

See [SETUP.md](./SETUP.md) for the full runbook including secrets and Firebase.
