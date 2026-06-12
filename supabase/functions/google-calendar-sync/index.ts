// google-calendar-sync
// Pulls Google Calendar events into appointments (source='google') for one
// user or for every linked user. Invoked by pg_cron every 15 minutes (no
// body) and on demand from the app (with user_id) on calendar open/refresh.
//
// Window: 7 days back → 90 days ahead. Dedupe key: google_event_id. Local
// google-sourced rows whose remote event disappeared from the window are
// deleted (event cancelled in Google).
//
// POST body: { user_id?: string }

import { adminClient, CORS, json, nowUnix } from "../_shared/client.ts";
import { gcalList, loadCreds } from "../_shared/google.ts";
import { refreshAccessToken } from "../_shared/google.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let userId: string | undefined;
  try {
    const body = await req.json();
    userId = body?.user_id;
  } catch {
    // Empty body (cron) is fine.
  }

  const db = adminClient();
  const creds = await loadCreds(db, userId);
  if (creds.length === 0) return json({ synced_users: 0 });

  const timeMin = new Date(Date.now() - 7 * 86400_000).toISOString();
  const timeMax = new Date(Date.now() + 90 * 86400_000).toISOString();
  const results: Record<string, unknown>[] = [];

  for (const c of creds) {
    const token = await refreshAccessToken(c.refresh_token);
    if (!token) {
      results.push({ user_id: c.user_id, error: "token_refresh_failed" });
      continue;
    }

    const events = await gcalList(token, c.calendar_id, timeMin, timeMax);
    const nowIso = new Date().toISOString();

    // Existing rows with a google_event_id for this user (both sources —
    // hestia-born mirrored events must not be re-imported as duplicates).
    const { data: existing } = await db
      .from("appointments")
      .select("id, google_event_id, source")
      .eq("user_id", c.user_id)
      .not("google_event_id", "is", null);
    const byEventId = new Map(
      (existing ?? []).map((a) => [a.google_event_id as string, a]),
    );

    let imported = 0, updated = 0, removed = 0;
    const seen = new Set<string>();

    for (const ev of events) {
      if (ev.status === "cancelled") continue;
      seen.add(ev.id);

      const isAllDay = ev.start?.dateTime == null && ev.start?.date != null;
      const startsAt = ev.start?.dateTime ??
        (ev.start?.date ? `${ev.start.date}T00:00:00Z` : null);
      if (!startsAt) continue;

      let durationMinutes = 60;
      if (!isAllDay && ev.end?.dateTime) {
        durationMinutes = Math.max(
          15,
          Math.round(
            (new Date(ev.end.dateTime).getTime() -
              new Date(startsAt).getTime()) / 60_000,
          ),
        );
      }

      const row = {
        title: ev.summary ?? "(untitled)",
        notes: ev.description ?? null,
        location: ev.location ?? null,
        starts_at: startsAt,
        duration_minutes: durationMinutes,
        is_all_day: isAllDay,
        last_update: nowIso,
      };

      const prior = byEventId.get(ev.id);
      if (prior) {
        // Only google-sourced rows follow remote edits; hestia-born events
        // are authoritative in Hestia.
        if (prior.source === "google") {
          await db.from("appointments").update(row).eq("id", prior.id);
          updated++;
        }
      } else {
        await db.from("appointments").insert({
          ...row,
          user_id: c.user_id,
          source: "google",
          google_event_id: ev.id,
          category: "other",
          is_shared: false,
          reminder_offsets_minutes: [60],
          created_at: nowIso,
        });
        imported++;
      }
    }

    // Remote-deleted google events → remove local copies (window-scoped).
    for (const a of existing ?? []) {
      if (a.source !== "google" || seen.has(a.google_event_id as string)) continue;
      const { error } = await db
        .from("appointments")
        .delete()
        .eq("id", a.id)
        .gte("starts_at", timeMin)
        .lte("starts_at", timeMax);
      if (!error) removed++;
    }

    await db
      .from("google_credentials")
      .update({ last_synced_at: nowUnix() })
      .eq("user_id", c.user_id);

    results.push({ user_id: c.user_id, imported, updated, removed });
  }

  return json({ synced_users: creds.length, results });
});
