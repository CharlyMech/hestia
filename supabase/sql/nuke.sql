-- nuke.sql
-- ⚠️  DESTRUCTIVE. Drops ALL Hestia app tables, functions, and triggers and
-- wipes their data. PRESERVES auth.users and the profiles table (the user
-- chose "keep auth users + profiles"). After running, re-apply migrations
-- 0001 → 0005 to rebuild.
--
-- Run with the service role (SQL editor / `supabase db execute`).

begin;

-- Drop dependent triggers on auth/profiles first.
drop trigger if exists trg_auth_user_created on auth.users;
drop trigger if exists trg_touch_profiles on profiles;

-- Drop all app tables (CASCADE clears FKs, policies, child triggers).
drop table if exists
  appointment_pets,
  scheduled_notifications,
  notification_settings,
  device_tokens,
  notifications,
  google_credentials,
  appointments,
  shopping_sessions,
  shopping_list_items,
  shopping_lists,
  homes,
  pet_measurements,
  pet_health_records,
  pets,
  fuel_entries,
  car_maintenance_records,
  car_members,
  cars,
  goal_contributions,
  financial_goals,
  transfers,
  transactions,
  payment_cards,
  transaction_sources,
  categories,
  account_members,
  bank_accounts,
  financial_institutions,
  household_members,
  households,
  app_versions
cascade;

-- Drop app functions.
drop function if exists touch_last_update() cascade;
drop function if exists touch_last_update_ts() cascade;
drop function if exists handle_new_auth_user() cascade;
drop function if exists recompute_account_balance(uuid) cascade;
drop function if exists trg_tx_balance() cascade;
drop function if exists trg_transfer_balance() cascade;
drop function if exists enqueue_appointment_reminders() cascade;
drop function if exists ensure_primary_card() cascade;
drop function if exists check_card_account() cascade;
drop function if exists is_household_member(uuid) cascade;
drop function if exists seed_default_categories(uuid) cascade;
drop function if exists on_household_created() cascade;

-- profiles and auth.users intentionally preserved.
-- (If you also want to wipe profiles, uncomment:)
-- truncate profiles cascade;

commit;
