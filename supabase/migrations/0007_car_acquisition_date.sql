-- Car acquisition date, stored as an ISO date string (e.g. '2025-05-05'),
-- mirroring how birth dates are stored (date-only, not a unix timestamp).
alter table cars add column if not exists acquisition_date text;
