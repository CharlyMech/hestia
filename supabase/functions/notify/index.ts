/**
 * Supabase Edge Function: notify
 */

import { createClient } from "jsr:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID")!;
const FIREBASE_SERVICE_ACCOUNT = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON")!;

interface NotifyPayload {
  type: string;
  household_id: string;
  user_ids: string[];
  title: string;
  body: string;
  payload?: Record<string, unknown>;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  let input: NotifyPayload;
  try {
    input = await req.json();
  } catch {
    return new Response("Invalid JSON", { status: 400 });
  }

  const { type, household_id, user_ids, title, body, payload = {} } = input;

  if (!type || !household_id || !user_ids?.length || !title || !body) {
    return new Response("Missing required fields", { status: 400 });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  // 1. Insert inbox rows
  const now = Math.floor(Date.now() / 1000);
  const rows = user_ids.map((uid) => ({
    user_id: uid,
    household_id,
    title,
    body,
    type,
    payload,
    is_read: false,
    created_at: now,
  }));

  const { error: insertError } = await supabase.from("notifications").insert(rows);

  if (insertError) {
    console.error("notifications insert failed:", insertError);
    return new Response(JSON.stringify({ error: insertError.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }

  // 2. Active FCM tokens for these users
  const { data: tokenRows, error: tokenError } = await supabase
    .from("device_tokens")
    .select("token")
    .in("user_id", user_ids)
    .eq("is_active", true);

  if (tokenError) {
    console.error("device_tokens fetch failed:", tokenError);
    return new Response(
      JSON.stringify({ inserted: rows.length, pushed: 0 }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  }

  const tokens: string[] = (tokenRows ?? []).map((r) => r.token as string);
  if (tokens.length === 0) {
    return new Response(
      JSON.stringify({ inserted: rows.length, pushed: 0 }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  }

  // 3. Send FCM
  let pushed = 0;
  let fcmError: string | null = null;
  let tokenPreview: string | null = null;
  try {
    const { token: accessToken, oauth2Response } = await getFcmAccessToken();
    tokenPreview = `${accessToken.slice(0, 20)}... (len=${accessToken.length}, oauth2Keys=${Object.keys(oauth2Response).join(",")})`;
    pushed = await sendFcm({ tokens, title, body, type, payload, accessToken });
  } catch (err) {
    fcmError = String(err);
    console.error("FCM send failed:", err);
  }

  return new Response(
    JSON.stringify({ inserted: rows.length, pushed, fcmError, tokenCount: tokens.length, tokenPreview }),
    { status: 200, headers: { "Content-Type": "application/json" } },
  );
});

// ── FCM helpers ──────────────────────────────────────────────────────────────

async function getFcmAccessToken(): Promise<{ token: string; oauth2Response: Record<string, unknown> }> {
  const sa = JSON.parse(FIREBASE_SERVICE_ACCOUNT);

  const toB64Url = (bytes: Uint8Array) =>
    btoa(String.fromCharCode(...bytes))
      .replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");

  const encodeObj = (obj: unknown) =>
    toB64Url(new TextEncoder().encode(JSON.stringify(obj)));

  const nowSec = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const claim = {
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: nowSec,
    exp: nowSec + 3600,
  };

  const unsigned = `${encodeObj(header)}.${encodeObj(claim)}`;

  const pemBody = sa.private_key
    .replace(/\\n/g, "\n")
    .replace(/-----BEGIN PRIVATE KEY-----/g, "")
    .replace(/-----END PRIVATE KEY-----/g, "")
    .replace(/\s+/g, "");
  const keyBytes = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const sigBytes = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${toB64Url(new Uint8Array(sigBytes))}`;

  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const json = await resp.json() as Record<string, unknown>;
  if (!json.access_token) throw new Error(`OAuth2 error: ${JSON.stringify(json)}`);
  return { token: json.access_token as string, oauth2Response: json };
}

async function sendFcm(opts: {
  tokens: string[];
  title: string;
  body: string;
  type: string;
  payload: Record<string, unknown>;
  accessToken: string;
}): Promise<number> {
  const { tokens, title, body, type, payload, accessToken } = opts;
  const url = `https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`;

  const results = await Promise.allSettled(
    tokens.map((token) =>
      fetch(url, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token,
            notification: { title, body },
            data: {
              type,
              ...Object.fromEntries(
                Object.entries(payload).map(([k, v]) => [k, String(v)]),
              ),
            },
            apns: {
              payload: {
                aps: {
                  alert: { title, body },
                  sound: "default",
                  badge: 1,
                  "mutable-content": 1,
                },
              },
            },
          },
        }),
      }).then(async (r) => {
        if (r.ok) return r;
        const text = await r.text().catch(() => r.status.toString());
        return Promise.reject(`${r.status}: ${text}`);
      }),
    ),
  );

  const errors: string[] = [];
  results.forEach((r, i) => {
    if (r.status === "rejected") {
      const msg = `token[${i}]: ${r.reason}`;
      console.error("FCM send failed:", msg);
      errors.push(msg);
    }
  });

  if (errors.length > 0) throw new Error(errors.join(" | "));
  return results.filter((r) => r.status === "fulfilled").length;
}
