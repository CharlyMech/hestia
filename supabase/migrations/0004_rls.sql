-- 0004_rls.sql
-- Row-level security. Access is scoped to the caller's household membership
-- (and ownership for personal rows). Edge functions use the service-role key
-- and bypass RLS, so authoritative writes there are unaffected.

-- ── helpers ──────────────────────────────────────────────────────────────
create or replace function is_household_member(h uuid)
returns boolean language sql stable security definer as $$
  select exists (
    select 1 from household_members
     where household_id = h and user_id = auth.uid()
  );
$$;

-- ── enable RLS everywhere ────────────────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array[
    'profiles','households','household_members','financial_institutions',
    'bank_accounts','account_members','payment_cards','categories',
    'transaction_sources','transactions','transfers','financial_goals',
    'goal_contributions','cars','car_members','car_maintenance_records',
    'fuel_entries','pets','pet_health_records',
    'pet_measurements','homes','shopping_lists','shopping_list_items',
    'shopping_sessions','appointments','appointment_pets','notifications',
    'notification_settings','device_tokens','scheduled_notifications',
    'google_credentials','app_versions'
  ] loop
    execute format('alter table %1$s enable row level security;', t);
  end loop;
end;
$$;

-- ── profiles: self + household co-members readable; self writable ─────────
drop policy if exists p_profiles_select on profiles;
create policy p_profiles_select on profiles for select
  using (
    id = auth.uid()
    or exists (
      select 1 from household_members m1
      join household_members m2 on m1.household_id = m2.household_id
      where m1.user_id = auth.uid() and m2.user_id = profiles.id
    )
  );
drop policy if exists p_profiles_update on profiles;
create policy p_profiles_update on profiles for update
  using (id = auth.uid()) with check (id = auth.uid());

-- ── households + membership ───────────────────────────────────────────────
drop policy if exists p_households_all on households;
create policy p_households_all on households for all
  using (is_household_member(id)) with check (is_household_member(id));

drop policy if exists p_hm_select on household_members;
create policy p_hm_select on household_members for select
  using (is_household_member(household_id) or user_id = auth.uid());
drop policy if exists p_hm_write on household_members;
create policy p_hm_write on household_members for all
  using (is_household_member(household_id) or user_id = auth.uid())
  with check (is_household_member(household_id) or user_id = auth.uid());

-- ── financial_institutions: readable by all authenticated ─────────────────
drop policy if exists p_fi_select on financial_institutions;
create policy p_fi_select on financial_institutions for select
  using (auth.uid() is not null);
drop policy if exists p_fi_write on financial_institutions;
create policy p_fi_write on financial_institutions for all
  using (auth.uid() is not null) with check (auth.uid() is not null);

-- ── generic household-scoped tables ───────────────────────────────────────
do $$
declare t text;
begin
  foreach t in array array[
    'bank_accounts','categories','transaction_sources','transactions',
    'transfers','financial_goals','cars','pets','homes','shopping_lists',
    'appointments','notifications'
  ] loop
    execute format($f$
      drop policy if exists p_%1$s_all on %1$s;
      create policy p_%1$s_all on %1$s for all
        using (is_household_member(household_id))
        with check (is_household_member(household_id));
    $f$, t);
  end loop;
end;
$$;

-- appointments also has personal (household_id null) rows owned by user_id.
drop policy if exists p_appointments_all on appointments;
create policy p_appointments_all on appointments for all
  using (user_id = auth.uid() or (household_id is not null and is_household_member(household_id)))
  with check (user_id = auth.uid() or (household_id is not null and is_household_member(household_id)));

-- ── child tables scoped via their parent ──────────────────────────────────
drop policy if exists p_account_members on account_members;
create policy p_account_members on account_members for all
  using (exists (select 1 from bank_accounts b where b.id = account_id and is_household_member(b.household_id)))
  with check (exists (select 1 from bank_accounts b where b.id = account_id and is_household_member(b.household_id)));

drop policy if exists p_payment_cards on payment_cards;
create policy p_payment_cards on payment_cards for all
  using (exists (select 1 from bank_accounts b where b.id = account_id and is_household_member(b.household_id)))
  with check (exists (select 1 from bank_accounts b where b.id = account_id and is_household_member(b.household_id)));

drop policy if exists p_goal_contributions on goal_contributions;
create policy p_goal_contributions on goal_contributions for all
  using (exists (select 1 from financial_goals g where g.id = goal_id and is_household_member(g.household_id)))
  with check (exists (select 1 from financial_goals g where g.id = goal_id and is_household_member(g.household_id)));

drop policy if exists p_car_members on car_members;
create policy p_car_members on car_members for all
  using (exists (select 1 from cars c where c.id = car_id and is_household_member(c.household_id)))
  with check (exists (select 1 from cars c where c.id = car_id and is_household_member(c.household_id)));

drop policy if exists p_car_maintenance on car_maintenance_records;
create policy p_car_maintenance on car_maintenance_records for all
  using (exists (select 1 from cars c where c.id = car_id and is_household_member(c.household_id)))
  with check (exists (select 1 from cars c where c.id = car_id and is_household_member(c.household_id)));

drop policy if exists p_fuel_entries on fuel_entries;
create policy p_fuel_entries on fuel_entries for all
  using (exists (select 1 from cars c where c.id = car_id and is_household_member(c.household_id)))
  with check (exists (select 1 from cars c where c.id = car_id and is_household_member(c.household_id)));

drop policy if exists p_pet_health on pet_health_records;
create policy p_pet_health on pet_health_records for all
  using (exists (select 1 from pets p where p.id = pet_id and is_household_member(p.household_id)))
  with check (exists (select 1 from pets p where p.id = pet_id and is_household_member(p.household_id)));

drop policy if exists p_pet_meas on pet_measurements;
create policy p_pet_meas on pet_measurements for all
  using (exists (select 1 from pets p where p.id = pet_id and is_household_member(p.household_id)))
  with check (exists (select 1 from pets p where p.id = pet_id and is_household_member(p.household_id)));

drop policy if exists p_shopping_items on shopping_list_items;
create policy p_shopping_items on shopping_list_items for all
  using (exists (select 1 from shopping_lists l where l.id = list_id and is_household_member(l.household_id)))
  with check (exists (select 1 from shopping_lists l where l.id = list_id and is_household_member(l.household_id)));

drop policy if exists p_shopping_sessions on shopping_sessions;
create policy p_shopping_sessions on shopping_sessions for all
  using (is_household_member(household_id)) with check (is_household_member(household_id));

drop policy if exists p_appt_pets on appointment_pets;
create policy p_appt_pets on appointment_pets for all
  using (exists (select 1 from appointments a where a.id = appointment_id
                 and (a.user_id = auth.uid() or (a.household_id is not null and is_household_member(a.household_id)))))
  with check (exists (select 1 from appointments a where a.id = appointment_id
                 and (a.user_id = auth.uid() or (a.household_id is not null and is_household_member(a.household_id)))));

-- ── per-user tables ────────────────────────────────────────────────────────
drop policy if exists p_notifications on notifications;
create policy p_notifications on notifications for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists p_notif_settings on notification_settings;
create policy p_notif_settings on notification_settings for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists p_device_tokens on device_tokens;
create policy p_device_tokens on device_tokens for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

drop policy if exists p_sched_notif on scheduled_notifications;
create policy p_sched_notif on scheduled_notifications for select
  using (user_id = auth.uid());
-- inserts/sends happen via triggers + service role (edge fn), not the client.

-- ── google_credentials: service-role only ──────────────────────────────────
-- RLS enabled with NO policies = deny-all for authenticated users. Only the
-- google-oauth-exchange / google-calendar-sync / upsert-appointment edge
-- functions (service role) touch this table. Clients check link state via
-- the google-oauth-exchange function's status endpoint, never directly.

-- ── app_versions: read-only for clients ────────────────────────────────────
drop policy if exists p_app_versions on app_versions;
create policy p_app_versions on app_versions for select
  using (auth.uid() is not null);
