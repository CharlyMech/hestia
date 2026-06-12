-- 0001_extensions.sql
-- Required Postgres extensions for Hestia.
--
-- pgcrypto  → gen_random_uuid() for primary keys
-- pg_net    → async HTTP from SQL/triggers (used to invoke edge functions)
-- pg_cron   → scheduled jobs (drives process-reminders)
--
-- pg_net / pg_cron may need to be enabled from the Supabase dashboard
-- (Database → Extensions) on some plans. If unavailable, the reminder
-- fan-out falls back to client-scheduled local notifications.

create extension if not exists pgcrypto;
create extension if not exists pg_net;
-- create extension if not exists pg_cron;   -- enable via dashboard if supported
