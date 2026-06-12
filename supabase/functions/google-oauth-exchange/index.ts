// google-oauth-exchange
// Link / unlink / query Google Calendar credentials. The app obtains a
// serverAuthCode via google_sign_in (using the WEB client id as
// serverClientId) and posts it here; we exchange it for a refresh token and
// keep that server-side only (google_credentials is deny-all under RLS).
//
// POST body:
//   { action: "link",   user_id: string, server_auth_code: string }
//   { action: "unlink", user_id: string }
//   { action: "status", user_id: string }

import { adminClient, CORS, json, nowUnix } from "../_shared/client.ts";
import { exchangeAuthCode, revokeToken } from "../_shared/google.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: { action: string; user_id: string; server_auth_code?: string };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.user_id || !input.action) {
    return json({ error: "Missing user_id or action" }, 400);
  }

  const db = adminClient();
  const ts = nowUnix();

  switch (input.action) {
    case "status": {
      const { data } = await db
        .from("google_credentials")
        .select("user_id, sync_enabled, last_synced_at")
        .eq("user_id", input.user_id)
        .maybeSingle();
      return json({
        linked: data != null,
        sync_enabled: data?.sync_enabled ?? false,
        last_synced_at: data?.last_synced_at ?? null,
      });
    }

    case "link": {
      if (!input.server_auth_code) {
        return json({ error: "Missing server_auth_code" }, 400);
      }
      const r = await exchangeAuthCode(input.server_auth_code);
      if (r.error || !r.refresh_token) {
        return json(
          { error: r.error ?? "No refresh_token returned (re-consent needed)" },
          400,
        );
      }
      const { error } = await db.from("google_credentials").upsert({
        user_id: input.user_id,
        refresh_token: r.refresh_token,
        sync_enabled: true,
        last_update: ts,
      });
      if (error) return json({ error: error.message }, 500);
      return json({ linked: true });
    }

    case "unlink": {
      const { data } = await db
        .from("google_credentials")
        .select("refresh_token")
        .eq("user_id", input.user_id)
        .maybeSingle();
      if (data) await revokeToken(data.refresh_token);
      await db.from("google_credentials").delete().eq("user_id", input.user_id);
      return json({ linked: false });
    }

    default:
      return json({ error: `Unknown action ${input.action}` }, 400);
  }
});
