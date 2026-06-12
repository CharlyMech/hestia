-- 0002_tables.sql
-- Hestia schema. Source of truth — derived from lib/data/dtos/* and the
-- repository/service column literals. NO payment_cards (removed).
--
-- Convention: timestamps are stored as unix seconds (bigint) to match the
-- Flutter DTOs (.toUnix / .fromUnix). gen_random_uuid() for ids.

-- Helper default for unix-seconds columns.
-- (Postgres has no direct "unix now" default; use extract.)
--   default (extract(epoch from now())::bigint)

-- ── profiles ─────────────────────────────────────────────────────────────
-- NOTE: preserved by nuke.sql. Mirrors auth.users 1:1 (id = auth uid).
create table if not exists profiles (
  id                 uuid primary key references auth.users (id) on delete cascade,
  email              text not null,
  display_name       text,
  avatar_url         text,
  preferred_currency text not null default 'EUR',
  calendar_color     text,
  birth_date         bigint,
  is_superuser       boolean not null default false,
  is_active          boolean not null default true,
  created_at         bigint not null default (extract(epoch from now())::bigint),
  last_update        bigint not null default (extract(epoch from now())::bigint)
);

-- ── households ───────────────────────────────────────────────────────────
create table if not exists households (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  created_by  uuid references profiles (id) on delete set null,
  created_at  bigint not null default (extract(epoch from now())::bigint),
  last_update bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists household_members (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  user_id      uuid not null references profiles (id) on delete cascade,
  role         text not null default 'member',
  created_at   bigint not null default (extract(epoch from now())::bigint),
  unique (household_id, user_id)
);

-- ── financial_institutions ───────────────────────────────────────────────
create table if not exists financial_institutions (
  id               uuid primary key default gen_random_uuid(),
  name             text not null,
  slug             text not null,
  country          text not null default '',
  brand_color      text not null,
  logo_asset       text,
  institution_type text not null default 'bank',
  is_custom        boolean not null default false,
  created_at       bigint not null default (extract(epoch from now())::bigint),
  last_update      bigint not null default (extract(epoch from now())::bigint)
);

-- ── bank_accounts ────────────────────────────────────────────────────────
create table if not exists bank_accounts (
  id              uuid primary key default gen_random_uuid(),
  household_id    uuid not null references households (id) on delete cascade,
  owner_type      text not null default 'household',     -- 'household' | 'personal'
  owner_id        uuid references profiles (id) on delete set null,
  name            text not null,
  institution     text,
  institution_id  uuid references financial_institutions (id) on delete set null,
  iban            text,
  account_type    text not null default 'checking',
  currency        text not null default 'EUR',
  initial_balance numeric not null default 0,
  current_balance numeric not null default 0,
  is_primary      boolean not null default false,
  is_active       boolean not null default true,
  color           text,
  icon            text,
  sort_order      int not null default 0,
  created_at      bigint not null default (extract(epoch from now())::bigint),
  last_update     bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists account_members (
  id         uuid primary key default gen_random_uuid(),
  account_id uuid not null references bank_accounts (id) on delete cascade,
  user_id    uuid not null references profiles (id) on delete cascade,
  role       text not null default 'owner',
  joined_at  bigint not null default (extract(epoch from now())::bigint),
  unique (account_id, user_id)
);

-- ── categories ───────────────────────────────────────────────────────────
create table if not exists categories (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  name         text not null,
  type         text not null,            -- 'income' | 'expense'
  color        text,
  icon         text,
  is_active    boolean not null default true,
  sort_order   int not null default 0,
  created_at   bigint not null default (extract(epoch from now())::bigint),
  last_update  bigint not null default (extract(epoch from now())::bigint)
);

-- ── transaction_sources (merchants / employers / stations) ───────────────
-- Carries an optional location so a transaction's source IS its place.
create table if not exists transaction_sources (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  name         text not null,
  kind         text not null default 'merchant',
  icon         text,
  color        text,
  image_url    text,
  address      text,
  latitude     double precision,
  longitude    double precision,
  is_active    boolean not null default true,
  created_by   uuid references profiles (id) on delete set null,
  created_at   bigint not null default (extract(epoch from now())::bigint),
  last_update  bigint not null default (extract(epoch from now())::bigint)
);

-- ── transactions (NO payment_card_id; has currency + lat/lng + actors) ────
create table if not exists transactions (
  id                    uuid primary key default gen_random_uuid(),
  household_id          uuid not null references households (id) on delete cascade,
  user_id               uuid not null references profiles (id) on delete cascade,
  category_id           uuid references categories (id) on delete set null,
  bank_account_id       uuid not null references bank_accounts (id) on delete cascade,
  transaction_source_id uuid references transaction_sources (id) on delete set null,
  amount                numeric not null,
  currency              text not null default 'EUR',
  type                  text not null,          -- 'income' | 'expense' | 'adjustment'
  note                  text,
  date                  bigint not null,
  is_recurring          boolean not null default false,
  recurring_rule        jsonb,
  latitude              double precision,
  longitude             double precision,
  pet_id                uuid,
  car_id                uuid,
  home_id               uuid,
  created_at            bigint not null default (extract(epoch from now())::bigint),
  last_update           bigint not null default (extract(epoch from now())::bigint)
);

create index if not exists idx_transactions_account on transactions (bank_account_id);
create index if not exists idx_transactions_household on transactions (household_id);

-- ── transfers ────────────────────────────────────────────────────────────
create table if not exists transfers (
  id              uuid primary key default gen_random_uuid(),
  household_id    uuid not null references households (id) on delete cascade,
  user_id         uuid not null references profiles (id) on delete cascade,
  from_account_id uuid not null references bank_accounts (id) on delete cascade,
  to_account_id   uuid not null references bank_accounts (id) on delete cascade,
  amount          numeric not null,
  note            text,
  date            bigint not null,
  created_at      bigint not null default (extract(epoch from now())::bigint),
  last_update     bigint not null default (extract(epoch from now())::bigint)
);

-- ── financial_goals ──────────────────────────────────────────────────────
create table if not exists financial_goals (
  id              uuid primary key default gen_random_uuid(),
  household_id    uuid not null references households (id) on delete cascade,
  scope           text not null default 'personal',
  owner_id        uuid references profiles (id) on delete set null,
  bank_account_id uuid references bank_accounts (id) on delete set null,
  name            text not null,
  goal_type       text not null,
  target_amount   numeric,
  monthly_target  numeric,
  current_amount  numeric not null default 0,
  currency        text not null default 'EUR',
  start_date      bigint not null,
  end_date        bigint,
  is_active       boolean not null default true,
  color           text,
  icon            text,
  created_at      bigint not null default (extract(epoch from now())::bigint),
  last_update     bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists goal_contributions (
  id          uuid primary key default gen_random_uuid(),
  goal_id     uuid not null references financial_goals (id) on delete cascade,
  amount      numeric not null,
  note        text,
  date        bigint not null,
  created_at  bigint not null default (extract(epoch from now())::bigint)
);

-- ── cars + members + fuel ─────────────────────────────────────────────────
create table if not exists cars (
  id                  uuid primary key default gen_random_uuid(),
  household_id        uuid not null references households (id) on delete cascade,
  name                text not null,
  make                text,
  model               text,
  year                int,
  license_plate       text,
  fuel_type           text,
  tank_capacity_liters numeric,
  current_odometer_km numeric,
  image_url           text,
  is_active           boolean not null default true,
  created_by          uuid references profiles (id) on delete set null,
  created_at          bigint not null default (extract(epoch from now())::bigint),
  last_update         bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists car_members (
  id        uuid primary key default gen_random_uuid(),
  car_id    uuid not null references cars (id) on delete cascade,
  user_id   uuid not null references profiles (id) on delete cascade,
  role      text not null default 'owner',
  joined_at bigint not null default (extract(epoch from now())::bigint),
  unique (car_id, user_id)
);

create table if not exists fuel_entries (
  id                uuid primary key default gen_random_uuid(),
  car_id            uuid not null references cars (id) on delete cascade,
  station_source_id uuid references transaction_sources (id) on delete set null,
  transaction_id    uuid references transactions (id) on delete set null,
  liters            numeric not null,
  price_per_liter   numeric,
  total_amount      numeric,
  odometer_km       numeric,
  is_full_tank      boolean not null default true,
  notes             text,
  filled_at         bigint not null,
  created_by        uuid references profiles (id) on delete set null,
  created_at        bigint not null default (extract(epoch from now())::bigint),
  last_update       bigint not null default (extract(epoch from now())::bigint)
);

-- ── pets + health + measurements ──────────────────────────────────────────
create table if not exists pets (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  name         text not null,
  species      text not null default 'dog',
  breed        text,
  gender       text not null default 'unknown',
  birth_date   bigint,
  weight_kg    numeric,
  image_url    text,
  notes        text,
  is_active    boolean not null default true,
  created_by   uuid references profiles (id) on delete set null,
  created_at   bigint not null default (extract(epoch from now())::bigint),
  last_update  bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists pet_health_records (
  id          uuid primary key default gen_random_uuid(),
  pet_id      uuid not null references pets (id) on delete cascade,
  type        text not null,
  title       text not null,
  vet_name    text,
  cost        numeric,
  notes       text,
  recorded_at bigint not null,
  next_due_at bigint,
  created_by  uuid references profiles (id) on delete set null,
  created_at  bigint not null default (extract(epoch from now())::bigint),
  last_update bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists pet_measurements (
  id          uuid primary key default gen_random_uuid(),
  pet_id      uuid not null references pets (id) on delete cascade,
  weight_kg   numeric not null,
  age_months  int,
  recorded_at bigint not null,
  created_at  bigint not null default (extract(epoch from now())::bigint)
);

-- ── homes ─────────────────────────────────────────────────────────────────
create table if not exists homes (
  id           uuid primary key default gen_random_uuid(),
  household_id uuid not null references households (id) on delete cascade,
  name         text not null,
  description  text,
  address      text,
  latitude     double precision,
  longitude    double precision,
  image_url    text,
  is_active    boolean not null default true,
  created_at   bigint not null default (extract(epoch from now())::bigint),
  last_update  bigint not null default (extract(epoch from now())::bigint)
);

-- ── shopping ───────────────────────────────────────────────────────────────
create table if not exists shopping_lists (
  id                    uuid primary key default gen_random_uuid(),
  household_id          uuid not null references households (id) on delete cascade,
  owner_id              uuid references profiles (id) on delete set null,
  scope                 text not null default 'household',
  name                  text not null,
  status                text not null default 'active',
  kind                  text not null default 'list',
  template_id           uuid references shopping_lists (id) on delete set null,
  session_started_at    bigint,
  session_ended_at      bigint,
  bank_account_id       uuid references bank_accounts (id) on delete set null,
  transaction_id        uuid references transactions (id) on delete set null,
  transaction_source_id uuid references transaction_sources (id) on delete set null,
  paid_at               bigint,
  created_at            bigint not null default (extract(epoch from now())::bigint),
  last_update           bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists shopping_list_items (
  id          uuid primary key default gen_random_uuid(),
  list_id     uuid not null references shopping_lists (id) on delete cascade,
  name        text not null,
  qty         int not null default 1,
  sort_order  int not null default 0,
  is_checked  boolean not null default false,
  checked_at  bigint,
  created_at  bigint not null default (extract(epoch from now())::bigint),
  last_update bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists shopping_sessions (
  id           uuid primary key default gen_random_uuid(),
  list_id      uuid not null references shopping_lists (id) on delete cascade,
  household_id uuid not null references households (id) on delete cascade,
  started_at   bigint not null,
  ended_at     bigint,
  created_at   bigint not null default (extract(epoch from now())::bigint)
);

-- ── appointments + reminders ────────────────────────────────────────────────
-- NOTE: unlike the rest of the schema, the appointment service serialises
-- timestamps as ISO-8601 strings, so these columns are timestamptz (not bigint).
create table if not exists appointments (
  id                       uuid primary key default gen_random_uuid(),
  user_id                  uuid not null references profiles (id) on delete cascade,
  household_id             uuid references households (id) on delete cascade,
  title                    text not null,
  notes                    text,
  location                 text,
  latitude                 double precision,
  longitude                double precision,
  starts_at                timestamptz not null,
  duration_minutes         int not null default 60,
  category                 text not null default 'other',
  reminder_offsets_minutes int[] not null default '{60}',
  google_event_id          text,
  pet_id                   uuid references pets (id) on delete set null,
  car_id                   uuid references cars (id) on delete set null,
  is_all_day               boolean not null default false,
  is_shared                boolean not null default true,
  color                    text,
  created_at               timestamptz not null default now(),
  last_update              timestamptz not null default now()
);

-- Multi-pet links for an appointment (bug #10: pets are multi-select).
create table if not exists appointment_pets (
  appointment_id uuid not null references appointments (id) on delete cascade,
  pet_id         uuid not null references pets (id) on delete cascade,
  primary key (appointment_id, pet_id)
);

-- ── notifications + delivery ────────────────────────────────────────────────
create table if not exists notifications (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles (id) on delete cascade,
  household_id uuid references households (id) on delete cascade,
  title        text not null,
  body         text not null,
  type         text not null,
  payload      jsonb not null default '{}'::jsonb,
  is_read      boolean not null default false,
  created_at   bigint not null default (extract(epoch from now())::bigint)
);

create index if not exists idx_notifications_user on notifications (user_id, is_read);

create table if not exists notification_settings (
  user_id          uuid primary key references profiles (id) on delete cascade,
  appointments     boolean not null default true,
  shared_events    boolean not null default true,
  transactions     boolean not null default true,
  shopping         boolean not null default true,
  last_update      bigint not null default (extract(epoch from now())::bigint)
);

create table if not exists device_tokens (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references profiles (id) on delete cascade,
  token       text not null,
  platform    text not null,
  is_active   boolean not null default true,
  last_update bigint not null default (extract(epoch from now())::bigint),
  unique (user_id, token)
);

-- Queue drained by process-reminders → notify (keeps FCM work off the DB).
create table if not exists scheduled_notifications (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references profiles (id) on delete cascade,
  household_id uuid references households (id) on delete cascade,
  type         text not null,
  title        text not null,
  body         text not null,
  payload      jsonb not null default '{}'::jsonb,
  deliver_at   bigint not null,                 -- unix seconds; due when <= now
  sent_at      bigint,                          -- null until delivered
  source_id    uuid,                            -- e.g. appointment id
  created_at   bigint not null default (extract(epoch from now())::bigint)
);

create index if not exists idx_sched_notif_due
  on scheduled_notifications (deliver_at)
  where sent_at is null;

-- ── app_versions ────────────────────────────────────────────────────────────
create table if not exists app_versions (
  id           uuid primary key default gen_random_uuid(),
  platform     text not null,
  build_number int not null,
  version       text,
  is_active    boolean not null default true,
  notes        text,
  created_at   bigint not null default (extract(epoch from now())::bigint)
);
