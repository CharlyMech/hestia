-- birth_date columns stored as ISO date strings (e.g. '2025-05-05'), not unix seconds.
alter table profiles alter column birth_date type text using null;
alter table pets     alter column birth_date type text using null;
