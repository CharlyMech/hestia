-- 0008_shopping_sessions_rework.sql
-- Separate shopping SESSIONS from TEMPLATES.
--
-- Going forward:
--   * shopping_lists      = TEMPLATES only (kind='template').
--   * shopping_sessions   = first-class active/ended trips (own lifecycle).
--   * shopping_session_items = session line items (FK -> shopping_sessions).
--
-- Additive only. Legacy shopping_lists rows with kind='session' remain as
-- history until a later cleanup migration; the app unions both sources for the
-- History tab during the transition.

-- ── expand shopping_sessions into a full session entity ──────────────────────
alter table shopping_sessions
  add column if not exists owner_id              uuid references profiles (id) on delete set null,
  add column if not exists name                  text not null default '',
  add column if not exists scope                 text not null default 'personal',
  add column if not exists status                text not null default 'active',
  add column if not exists template_id           uuid references shopping_lists (id) on delete set null,
  add column if not exists transaction_id        uuid references transactions (id) on delete set null,
  add column if not exists bank_account_id       uuid references bank_accounts (id) on delete set null,
  add column if not exists transaction_source_id uuid references transaction_sources (id) on delete set null,
  add column if not exists paid_at               bigint,
  add column if not exists last_update           bigint not null default (extract(epoch from now())::bigint);

-- Personal local-first sessions have no source list; legacy rows keep theirs.
alter table shopping_sessions alter column list_id drop not null;

-- ── session line items (mirror of shopping_list_items, FK -> sessions) ───────
create table if not exists shopping_session_items (
  id          uuid primary key default gen_random_uuid(),
  session_id  uuid not null references shopping_sessions (id) on delete cascade,
  name        text not null,
  qty         int not null default 1,
  sort_order  int not null default 0,
  is_checked  boolean not null default false,
  checked_at  bigint,
  created_at  bigint not null default (extract(epoch from now())::bigint),
  last_update bigint not null default (extract(epoch from now())::bigint)
);

-- ── touch triggers (reuse touch_last_update from 0003) ───────────────────────
drop trigger if exists trg_touch_shopping_sessions on shopping_sessions;
create trigger trg_touch_shopping_sessions before update on shopping_sessions
  for each row execute function touch_last_update();

drop trigger if exists trg_touch_shopping_session_items on shopping_session_items;
create trigger trg_touch_shopping_session_items before update on shopping_session_items
  for each row execute function touch_last_update();

-- ── RLS ──────────────────────────────────────────────────────────────────────
alter table shopping_session_items enable row level security;

-- shopping_sessions already has p_shopping_sessions (household-member) from 0004.
-- Items scope through their parent session's household.
drop policy if exists p_shopping_session_items on shopping_session_items;
create policy p_shopping_session_items on shopping_session_items for all
  using (exists (select 1 from shopping_sessions s
                 where s.id = session_id and is_household_member(s.household_id)))
  with check (exists (select 1 from shopping_sessions s
                      where s.id = session_id and is_household_member(s.household_id)));

-- NOTE: enable Realtime for shopping_session_items in the Supabase dashboard
-- (Database → Replication) so shared-session item edits propagate. shopping_sessions
-- is already published.
