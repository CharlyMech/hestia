-- superadmin_seed.sql
-- Idempotent. Promotes ONE auth user to superadmin and bootstraps their
-- household. Run in the SQL editor (service role) AFTER migrations 0001–0005.
--
-- PREREQUISITE — the auth user must already exist. Create it with the GoTrue
-- admin API (see supabase/SETUP.md):
--
--   curl -X POST 'https://<PROJECT_REF>.supabase.co/auth/v1/admin/users' \
--     -H 'apikey: <SERVICE_ROLE_KEY>' \
--     -H 'Authorization: Bearer <SERVICE_ROLE_KEY>' \
--     -H 'Content-Type: application/json' \
--     -d '{"email": "<SUPERADMIN_EMAIL>", "password": "<PASSWORD>", "email_confirm": true}'
--
-- The handle_new_auth_user trigger (0003) auto-creates the profiles row.
-- Edit the two variables at the top before running.

do $$
declare
  v_email          text := '<SUPERADMIN_EMAIL>';   -- ← EDIT
  v_household_name text := 'Casa';                 -- ← EDIT (display name only)
  v_user_id        uuid;
  v_household_id   uuid;
begin
  select id into v_user_id from auth.users where email = v_email;
  if v_user_id is null then
    raise exception 'auth user % not found — create it via the GoTrue admin API first', v_email;
  end if;

  -- Ensure the profile exists (safety net if the trigger was missing) and
  -- promote to superadmin.
  insert into profiles (id, email, display_name, is_superuser)
  values (v_user_id, v_email, split_part(v_email, '@', 1), true)
  on conflict (id) do update set is_superuser = true;

  -- Bootstrap the household if the user has none.
  select household_id into v_household_id
    from household_members where user_id = v_user_id limit 1;

  if v_household_id is null then
    insert into households (name, created_by)
    values (v_household_name, v_user_id)
    returning id into v_household_id;

    insert into household_members (household_id, user_id, role)
    values (v_household_id, v_user_id, 'owner');
    -- on_household_created (0005) auto-seeds default categories.
  end if;

  raise notice 'superadmin % ready — household %', v_email, v_household_id;
end;
$$;
