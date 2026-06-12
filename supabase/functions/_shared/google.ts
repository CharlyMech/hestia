// Google Calendar helpers shared by google-oauth-exchange,
// google-calendar-sync, upsert-appointment and delete-appointment.
//
// Secrets required:
//   GOOGLE_CLIENT_ID      web OAuth client id (also used as serverClientId in the app)
//   GOOGLE_CLIENT_SECRET  web OAuth client secret

import { SupabaseClient } from "jsr:@supabase/supabase-js@2";

const TOKEN_URL = "https://oauth2.googleapis.com/token";
const CAL_BASE = "https://www.googleapis.com/calendar/v3";

export interface GoogleCreds {
  user_id: string;
  refresh_token: string;
  calendar_id: string;
  sync_enabled: boolean;
}

/** Exchange a serverAuthCode (from google_sign_in on device) for tokens. */
export async function exchangeAuthCode(
  code: string,
): Promise<{ refresh_token?: string; access_token?: string; error?: string }> {
  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      code,
      client_id: Deno.env.get("GOOGLE_CLIENT_ID")!,
      client_secret: Deno.env.get("GOOGLE_CLIENT_SECRET")!,
      grant_type: "authorization_code",
      // Required for installed-app serverAuthCode exchange.
      redirect_uri: "",
    }),
  });
  const body = await res.json();
  if (!res.ok) return { error: body.error_description ?? body.error };
  return { refresh_token: body.refresh_token, access_token: body.access_token };
}

/** Mint a short-lived access token from a stored refresh token. */
export async function refreshAccessToken(
  refreshToken: string,
): Promise<string | null> {
  const res = await fetch(TOKEN_URL, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      refresh_token: refreshToken,
      client_id: Deno.env.get("GOOGLE_CLIENT_ID")!,
      client_secret: Deno.env.get("GOOGLE_CLIENT_SECRET")!,
      grant_type: "refresh_token",
    }),
  });
  if (!res.ok) return null;
  const body = await res.json();
  return body.access_token ?? null;
}

export async function revokeToken(refreshToken: string): Promise<void> {
  await fetch(
    `https://oauth2.googleapis.com/revoke?token=${encodeURIComponent(refreshToken)}`,
    { method: "POST" },
  ).catch(() => {});
}

/** Load credentials for one user, or all sync-enabled users. */
export async function loadCreds(
  db: SupabaseClient,
  userId?: string,
): Promise<GoogleCreds[]> {
  let q = db
    .from("google_credentials")
    .select("user_id, refresh_token, calendar_id, sync_enabled")
    .eq("sync_enabled", true);
  if (userId) q = q.eq("user_id", userId);
  const { data } = await q;
  return (data ?? []) as GoogleCreds[];
}

// ── Calendar event payloads ────────────────────────────────────────────────

/** appointments row → Google Calendar event resource. */
export function appointmentToEvent(appt: {
  title: string;
  notes?: string | null;
  location?: string | null;
  starts_at: string; // ISO
  duration_minutes: number;
  is_all_day: boolean;
}): Record<string, unknown> {
  const start = new Date(appt.starts_at);
  if (appt.is_all_day) {
    const day = start.toISOString().slice(0, 10);
    return {
      summary: appt.title,
      description: appt.notes ?? undefined,
      location: appt.location ?? undefined,
      start: { date: day },
      end: { date: day },
    };
  }
  const end = new Date(start.getTime() + appt.duration_minutes * 60_000);
  return {
    summary: appt.title,
    description: appt.notes ?? undefined,
    location: appt.location ?? undefined,
    start: { dateTime: start.toISOString() },
    end: { dateTime: end.toISOString() },
  };
}

export async function gcalInsert(
  accessToken: string,
  calendarId: string,
  event: Record<string, unknown>,
): Promise<string | null> {
  const res = await fetch(
    `${CAL_BASE}/calendars/${encodeURIComponent(calendarId)}/events`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(event),
    },
  );
  if (!res.ok) return null;
  const body = await res.json();
  return body.id ?? null;
}

export async function gcalUpdate(
  accessToken: string,
  calendarId: string,
  eventId: string,
  event: Record<string, unknown>,
): Promise<boolean> {
  const res = await fetch(
    `${CAL_BASE}/calendars/${encodeURIComponent(calendarId)}/events/${eventId}`,
    {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(event),
    },
  );
  return res.ok;
}

export async function gcalDelete(
  accessToken: string,
  calendarId: string,
  eventId: string,
): Promise<boolean> {
  const res = await fetch(
    `${CAL_BASE}/calendars/${encodeURIComponent(calendarId)}/events/${eventId}`,
    { method: "DELETE", headers: { Authorization: `Bearer ${accessToken}` } },
  );
  return res.ok || res.status === 404 || res.status === 410;
}

export interface GcalEvent {
  id: string;
  status: string;
  summary?: string;
  description?: string;
  location?: string;
  start?: { dateTime?: string; date?: string };
  end?: { dateTime?: string; date?: string };
}

/** List events in [timeMin, timeMax] (singleEvents expands recurrences). */
export async function gcalList(
  accessToken: string,
  calendarId: string,
  timeMin: string,
  timeMax: string,
): Promise<GcalEvent[]> {
  const events: GcalEvent[] = [];
  let pageToken: string | undefined;
  do {
    const params = new URLSearchParams({
      timeMin,
      timeMax,
      singleEvents: "true",
      maxResults: "250",
      ...(pageToken ? { pageToken } : {}),
    });
    const res = await fetch(
      `${CAL_BASE}/calendars/${encodeURIComponent(calendarId)}/events?${params}`,
      { headers: { Authorization: `Bearer ${accessToken}` } },
    );
    if (!res.ok) break;
    const body = await res.json();
    events.push(...(body.items ?? []));
    pageToken = body.nextPageToken;
  } while (pageToken);
  return events;
}
