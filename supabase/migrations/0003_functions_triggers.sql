-- 0003_functions_triggers.sql
-- THIN triggers only. Heavy/side-effectful logic lives in edge functions
-- (create-transaction, create-transfer, process-reminders). See supabase/functions.

-- ── touch last_update on any update ──────────────────────────────────────
create or replace function touch_last_update()
returns trigger language plpgsql as $$
begin
  new.last_update := extract(epoch from now())::bigint;
  return new;
end;
$$;

do $$
declare t text;
begin
  foreach t in array array[
    'profiles','households','financial_institutions','bank_accounts',
    'payment_cards','categories','transaction_sources','transactions',
    'transfers','financial_goals','cars','car_maintenance_records',
    'fuel_entries','pets','pet_health_records',
    'homes','shopping_lists','shopping_list_items',
    'notification_settings','device_tokens','google_credentials'
  ] loop
    execute format(
      'drop trigger if exists trg_touch_%1$s on %1$s;
       create trigger trg_touch_%1$s before update on %1$s
       for each row execute function touch_last_update();', t);
  end loop;
end;
$$;

-- appointments use timestamptz for last_update.
create or replace function touch_last_update_ts()
returns trigger language plpgsql as $$
begin
  new.last_update := now();
  return new;
end;
$$;

drop trigger if exists trg_touch_appointments on appointments;
create trigger trg_touch_appointments before update on appointments
  for each row execute function touch_last_update_ts();

-- ── profile auto-provision on auth signup ────────────────────────────────
-- Keeps profiles in lockstep with auth.users (nuke preserves both).
create or replace function handle_new_auth_user()
returns trigger language plpgsql security definer as $$
begin
  insert into profiles (id, email, display_name)
  values (new.id, new.email, split_part(new.email, '@', 1))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists trg_auth_user_created on auth.users;
create trigger trg_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_auth_user();

-- ── payment cards: first card of an account becomes primary ──────────────
-- The partial unique index uq_payment_cards_primary enforces AT MOST one
-- primary per account; this trigger guarantees AT LEAST one once any exists.
-- "Set primary" from the client is a clear-then-set two-statement flow.
create or replace function ensure_primary_card()
returns trigger language plpgsql as $$
begin
  if not exists (
    select 1 from payment_cards
     where account_id = new.account_id and is_primary
  ) then
    new.is_primary := true;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_ensure_primary_card on payment_cards;
create trigger trg_ensure_primary_card
  before insert on payment_cards
  for each row execute function ensure_primary_card();

-- ── transactions: the card must belong to the transaction's account ───────
create or replace function check_card_account()
returns trigger language plpgsql as $$
begin
  if new.payment_card_id is not null and not exists (
    select 1 from payment_cards
     where id = new.payment_card_id and account_id = new.bank_account_id
  ) then
    raise exception 'payment_card % does not belong to bank_account %',
      new.payment_card_id, new.bank_account_id;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_check_card_account on transactions;
create trigger trg_check_card_account
  before insert or update of payment_card_id, bank_account_id on transactions
  for each row execute function check_card_account();

-- ── balance recompute SAFETY NET ─────────────────────────────────────────
-- AUTHORITATIVE path is the create-transaction / delete-transaction /
-- create-transfer edge functions. This trigger only guards against direct
-- table writes (e.g. SQL console, recurring jobs) so balances never drift.
create or replace function recompute_account_balance(p_account uuid)
returns void language plpgsql as $$
declare
  v_initial numeric;
  v_income  numeric;
  v_expense numeric;
  v_in      numeric;
  v_out     numeric;
begin
  select initial_balance into v_initial from bank_accounts where id = p_account;
  if v_initial is null then return; end if;

  select coalesce(sum(amount) filter (where type = 'income'), 0),
         coalesce(sum(amount) filter (where type = 'expense'), 0)
    into v_income, v_expense
    from transactions where bank_account_id = p_account;

  select coalesce(sum(amount), 0) into v_in
    from transfers where to_account_id = p_account;
  select coalesce(sum(amount), 0) into v_out
    from transfers where from_account_id = p_account;

  update bank_accounts
     set current_balance = v_initial + v_income - v_expense + v_in - v_out,
         last_update = extract(epoch from now())::bigint
   where id = p_account;
end;
$$;

create or replace function trg_tx_balance()
returns trigger language plpgsql as $$
begin
  if tg_op = 'DELETE' then
    perform recompute_account_balance(old.bank_account_id);
    return old;
  end if;
  perform recompute_account_balance(new.bank_account_id);
  if tg_op = 'UPDATE' and new.bank_account_id <> old.bank_account_id then
    perform recompute_account_balance(old.bank_account_id);
  end if;
  return new;
end;
$$;

drop trigger if exists trg_tx_balance on transactions;
create trigger trg_tx_balance
  after insert or update or delete on transactions
  for each row execute function trg_tx_balance();

create or replace function trg_transfer_balance()
returns trigger language plpgsql as $$
begin
  if tg_op = 'DELETE' then
    perform recompute_account_balance(old.from_account_id);
    perform recompute_account_balance(old.to_account_id);
    return old;
  end if;
  perform recompute_account_balance(new.from_account_id);
  perform recompute_account_balance(new.to_account_id);
  return new;
end;
$$;

drop trigger if exists trg_transfer_balance on transfers;
create trigger trg_transfer_balance
  after insert or update or delete on transfers
  for each row execute function trg_transfer_balance();

-- ── appointment → scheduled_notifications enqueue (CHEAP) ─────────────────
-- Only fans rows into the queue. process-reminders (pg_cron) does the FCM.
create or replace function enqueue_appointment_reminders()
returns trigger language plpgsql as $$
declare
  off int;
  members record;
begin
  -- Clear prior queue rows for this appointment on update.
  if tg_op = 'UPDATE' then
    delete from scheduled_notifications
     where source_id = new.id and sent_at is null;
  end if;

  -- Owner reminders.
  foreach off in array new.reminder_offsets_minutes loop
    insert into scheduled_notifications
      (user_id, household_id, type, title, body, payload, deliver_at, source_id)
    values (
      new.user_id, new.household_id, 'appointment_reminder',
      new.title,
      'Starts soon',
      jsonb_build_object('appointment_id', new.id),
      extract(epoch from new.starts_at)::bigint - (off * 60),
      new.id
    );
  end loop;

  -- Shared events: notify other household members once at creation.
  if new.is_shared and new.household_id is not null and tg_op = 'INSERT' then
    for members in
      select user_id from household_members
       where household_id = new.household_id and user_id <> new.user_id
    loop
      insert into scheduled_notifications
        (user_id, household_id, type, title, body, payload, deliver_at, source_id)
      values (
        members.user_id, new.household_id, 'shared_appointment',
        new.title, 'New shared event',
        jsonb_build_object('appointment_id', new.id),
        extract(epoch from now())::bigint,
        new.id
      );
    end loop;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_appt_reminders on appointments;
create trigger trg_appt_reminders
  after insert or update on appointments
  for each row execute function enqueue_appointment_reminders();
