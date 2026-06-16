-- 0009_shopping_share_members.sql
-- Per-member sharing for shared shopping TEMPLATES and SESSIONS.
--
-- Until now a `scope='shared'` row was visible to the whole household. This adds
-- explicit member lists so a shared template/session is visible only to its
-- owner + the members it was shared with. An empty member list on a shared row
-- means "whole household" (the "All" checkbox), preserving the old behaviour.
--
-- Visibility rule (enforced in RLS):
--   * personal              → owner only (already enforced by app scope).
--   * shared + no members   → any household member (legacy / "All").
--   * shared + has members  → owner OR a listed member.
-- Edge functions use the service-role key and bypass RLS, so authoritative
-- writes there are unaffected.

-- ── join tables ──────────────────────────────────────────────────────────────
create table if not exists shopping_list_members (
  list_id     uuid not null references shopping_lists (id) on delete cascade,
  user_id     uuid not null references profiles (id) on delete cascade,
  created_at  bigint not null default (extract(epoch from now())::bigint),
  primary key (list_id, user_id)
);

create table if not exists shopping_session_members (
  session_id  uuid not null references shopping_sessions (id) on delete cascade,
  user_id     uuid not null references profiles (id) on delete cascade,
  created_at  bigint not null default (extract(epoch from now())::bigint),
  primary key (session_id, user_id)
);

create index if not exists idx_shopping_list_members_user on shopping_list_members (user_id);
create index if not exists idx_shopping_session_members_user on shopping_session_members (user_id);

-- ── helpers ────────────────────────────────────────────────────────────────
-- True when the caller may see a shared list: owner, an explicit member, or
-- (no explicit members → whole household).
create or replace function can_see_shared_list(l_id uuid, l_owner uuid, l_household uuid)
returns boolean language sql stable security definer as $$
  select
    l_owner = auth.uid()
    or exists (select 1 from shopping_list_members m
                where m.list_id = l_id and m.user_id = auth.uid())
    or (not exists (select 1 from shopping_list_members m where m.list_id = l_id)
        and is_household_member(l_household));
$$;

create or replace function can_see_shared_session(s_id uuid, s_owner uuid, s_household uuid)
returns boolean language sql stable security definer as $$
  select
    s_owner = auth.uid()
    or exists (select 1 from shopping_session_members m
                where m.session_id = s_id and m.user_id = auth.uid())
    or (not exists (select 1 from shopping_session_members m where m.session_id = s_id)
        and is_household_member(s_household));
$$;

-- ── RLS ──────────────────────────────────────────────────────────────────────
alter table shopping_list_members enable row level security;
alter table shopping_session_members enable row level security;

-- Members tables: visible/writable to household members of the parent row.
drop policy if exists p_shopping_list_members on shopping_list_members;
create policy p_shopping_list_members on shopping_list_members for all
  using (exists (select 1 from shopping_lists l
                 where l.id = list_id and is_household_member(l.household_id)))
  with check (exists (select 1 from shopping_lists l
                      where l.id = list_id and is_household_member(l.household_id)));

drop policy if exists p_shopping_session_members on shopping_session_members;
create policy p_shopping_session_members on shopping_session_members for all
  using (exists (select 1 from shopping_sessions s
                 where s.id = session_id and is_household_member(s.household_id)))
  with check (exists (select 1 from shopping_sessions s
                      where s.id = session_id and is_household_member(s.household_id)));

-- Tighten the parent-row policies to respect member lists.
-- shopping_lists was covered by the generic p_shopping_lists_all (0004); replace it.
drop policy if exists p_shopping_lists_all on shopping_lists;
drop policy if exists p_shopping_lists on shopping_lists;
create policy p_shopping_lists on shopping_lists for all
  using (
    case scope
      when 'personal' then owner_id = auth.uid()
      else can_see_shared_list(id, owner_id, household_id)
    end
  )
  with check (is_household_member(household_id));

drop policy if exists p_shopping_sessions on shopping_sessions;
create policy p_shopping_sessions on shopping_sessions for all
  using (
    case scope
      when 'personal' then owner_id = auth.uid()
      else can_see_shared_session(id, owner_id, household_id)
    end
  )
  with check (is_household_member(household_id));

-- Realtime: publish the member tables so share changes propagate.
-- NOTE: enable Realtime for shopping_list_members / shopping_session_members in
-- the Supabase dashboard (Database → Replication) if live share updates are needed.
