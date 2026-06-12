// delete-appointment
// Deletes an appointment and removes its mirrored Google Calendar event when
// the user has linked their account.
//
// POST body: { id: string }

import { adminClient, CORS, json } from "../_shared/client.ts";
import { gcalDelete, loadCreds, refreshAccessToken } from "../_shared/google.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: { id: string };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.id) return json({ error: "Missing id" }, 400);

  const db = adminClient();

  const { data: appt } = await db
    .from("appointments")
    .select("id, user_id, google_event_id")
    .eq("id", input.id)
    .single();
  if (!appt) return json({ deleted: false, error: "Not found" }, 404);

  let gcalDeleted = false;
  if (appt.google_event_id) {
    const [creds] = await loadCreds(db, appt.user_id as string);
    if (creds) {
      const token = await refreshAccessToken(creds.refresh_token);
      if (token) {
        gcalDeleted = await gcalDelete(
          token, creds.calendar_id, appt.google_event_id as string);
      }
    }
  }

  const { error } = await db.from("appointments").delete().eq("id", input.id);
  if (error) return json({ error: error.message }, 500);

  // Clear any pending reminders for it.
  await db
    .from("scheduled_notifications")
    .delete()
    .eq("source_id", input.id)
    .is("sent_at", null);

  return json({ deleted: true, gcal_deleted: gcalDeleted });
});
