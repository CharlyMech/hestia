-- 0005_seed.sql
-- Optional defaults. Safe to re-run (guards on conflict / existence).

-- Default category set, applied to a household on creation.
create or replace function seed_default_categories(p_household uuid)
returns void language plpgsql as $$
begin
  insert into categories (household_id, name, type, color, icon) values
    (p_household, 'Salary',        'income',  '#4CB782', 'wallet'),
    (p_household, 'Other income',  'income',  '#3FA7D6', 'plus'),
    (p_household, 'Groceries',     'expense', '#E76F51', 'cart'),
    (p_household, 'Eating out',    'expense', '#F4A261', 'cutlery'),
    (p_household, 'Transport',     'expense', '#2A9D8F', 'car'),
    (p_household, 'Housing',       'expense', '#8D99AE', 'home'),
    (p_household, 'Utilities',     'expense', '#577590', 'bolt'),
    (p_household, 'Health',        'expense', '#E63946', 'heart'),
    (p_household, 'Pets',          'expense', '#B5838D', 'pawprint'),
    (p_household, 'Entertainment', 'expense', '#9B5DE5', 'star'),
    (p_household, 'Other',         'expense', '#6C757D', 'dots');
end;
$$;

-- Auto-seed categories + creator membership when a household is created.
create or replace function on_household_created()
returns trigger language plpgsql security definer as $$
begin
  if new.created_by is not null then
    insert into household_members (household_id, user_id, role)
    values (new.id, new.created_by, 'owner')
    on conflict (household_id, user_id) do nothing;
  end if;
  perform seed_default_categories(new.id);
  return new;
end;
$$;

drop trigger if exists trg_household_created on households;
create trigger trg_household_created
  after insert on households
  for each row execute function on_household_created();

-- A few common institutions (extend as needed).
insert into financial_institutions (name, slug, country, brand_color, institution_type)
values
  ('Lidl',      'lidl',      'ES', '#0050AA', 'merchant'),
  ('Mercadona', 'mercadona', 'ES', '#007A33', 'merchant')
on conflict do nothing;
