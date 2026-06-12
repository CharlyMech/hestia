-- cron_schedule.sql
-- Registers the pg_cron jobs that drive server-side automation.
-- Run ONCE per environment in the SQL editor (service role), AFTER the edge
-- functions are deployed and secrets are set.
--
-- Replace before running:
--   <PROJECT_REF>        your Supabase project ref (e.g. abcdefghijklmnop)
--   <SERVICE_ROLE_KEY>   the service-role key (Settings → API)
--
-- Requires extensions pg_cron + pg_net (0001_extensions.sql).

-- Remove previous registrations so this file is re-runnable.
select cron.unschedule(jobid)
  from cron.job
 where jobname in ('hestia-process-reminders', 'hestia-google-calendar-sync');

-- Every minute: drain scheduled_notifications → notify (FCM fan-out).
select cron.schedule(
  'hestia-process-reminders',
  '* * * * *',
  $$
  select net.http_post(
    url     := 'https://<PROJECT_REF>.supabase.co/functions/v1/process-reminders',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
    ),
    body    := '{}'::jsonb
  );
  $$
);

-- Every 15 minutes: pull Google Calendar events for all linked users.
select cron.schedule(
  'hestia-google-calendar-sync',
  '*/15 * * * *',
  $$
  select net.http_post(
    url     := 'https://<PROJECT_REF>.supabase.co/functions/v1/google-calendar-sync',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
    ),
    body    := '{}'::jsonb
  );
  $$
);

-- Inspect with:  select jobid, jobname, schedule from cron.job;
