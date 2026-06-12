// upsert-appointment
// Inserts (or updates) an appointment, maintains the appointment_pets links,
// and mirrors the event to Google Calendar server-side when the user has
// linked their account (google_credentials). Reminder fan-out stays in the
// enqueue_appointment_reminders DB trigger.
//
// POST body: {
//   appointment: { ...appointments row... },  // user_id + starts_at required
//   pet_ids?: string[],                       // full replacement set
//   id?: string                               // present → update
// }

import { adminClient, CORS, json } from "../_shared/client.ts";
import {
  appointmentToEvent,
  gcalInsert,
  gcalUpdate,
  loadCreds,
  refreshAccessToken,
} from "../_shared/google.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: {
    appointment: Record<string, unknown>;
    pet_ids?: string[];
    id?: string;
  };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const appt = input.appointment;
  if (!appt || !appt.user_id || !appt.starts_at) {
    return json({ error: "Missing appointment.user_id or starts_at" }, 400);
  }

  const db = adminClient();
  const nowIso = new Date().toISOString();

  let saved;
  if (input.id) {
    const { data, error } = await db
      .from("appointments")
      .update({ ...appt, last_update: nowIso })
      .eq("id", input.id)
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  } else {
    const { data, error } = await db
      .from("appointments")
      .insert({ ...appt, created_at: nowIso, last_update: nowIso })
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  }

  // Replace pet links when provided.
  if (input.pet_ids) {
    await db.from("appointment_pets").delete().eq("appointment_id", saved.id);
    if (input.pet_ids.length > 0) {
      await db.from("appointment_pets").insert(
        input.pet_ids.map((p) => ({ appointment_id: saved.id, pet_id: p })),
      );
    }
  }

  // Mirror to Google Calendar — only Hestia-born events; google-sourced rows
  // are written back through their own google_event_id below as updates.
  let gcalSynced = false;
  const [creds] = await loadCreds(db, saved.user_id as string);
  if (creds) {
    const token = await refreshAccessToken(creds.refresh_token);
    if (token) {
      const event = appointmentToEvent(saved);
      if (saved.google_event_id) {
        gcalSynced = await gcalUpdate(
          token, creds.calendar_id, saved.google_event_id as string, event);
      } else if (saved.source === "hestia") {
        const eventId = await gcalInsert(token, creds.calendar_id, event);
        if (eventId) {
          await db
            .from("appointments")
            .update({ google_event_id: eventId })
            .eq("id", saved.id);
          saved.google_event_id = eventId;
          gcalSynced = true;
        }
      }
    }
  }

  return json({ appointment: saved, gcal_synced: gcalSynced });
});
