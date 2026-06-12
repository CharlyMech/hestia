// process-reminders
// Drains due rows from scheduled_notifications and delivers them via the
// `notify` function (inbox row + FCM push). Intended to be invoked on a
// schedule by pg_cron (see SETUP.md) — keeps FCM work off the database.
//
// Can also be called manually (POST, empty body) for testing.

import { adminClient, CORS, json, nowUnix } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });

  const db = adminClient();
  const now = nowUnix();

  const { data: due, error } = await db
    .from("scheduled_notifications")
    .select("*")
    .is("sent_at", null)
    .lte("deliver_at", now)
    .limit(200);

  if (error) return json({ error: error.message }, 500);
  if (!due || due.length === 0) return json({ processed: 0 });

  const notifyUrl = `${Deno.env.get("SUPABASE_URL")}/functions/v1/notify`;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  let delivered = 0;
  for (const r of due) {
    try {
      const resp = await fetch(notifyUrl, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${serviceKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          type: r.type,
          household_id: r.household_id ?? r.user_id,
          user_ids: [r.user_id],
          title: r.title,
          body: r.body,
          payload: r.payload ?? {},
        }),
      });
      if (resp.ok) {
        await db
          .from("scheduled_notifications")
          .update({ sent_at: now })
          .eq("id", r.id);
        delivered++;
      }
    } catch (_) {
      // leave unsent; retried next tick
    }
  }

  return json({ processed: due.length, delivered });
});
