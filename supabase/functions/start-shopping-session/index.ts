// start-shopping-session
// Marks a shopping list as an in-progress session and, when the list is
// household-scoped, pushes a "shopping session started" notification to the
// other household members — all server-side, one call from the app.
//
// POST body: { list_id: string, user_id: string }

import { adminClient, CORS, invokeNotify, json, nowUnix } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: { list_id: string; user_id: string };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.list_id || !input.user_id) {
    return json({ error: "Missing list_id or user_id" }, 400);
  }

  const db = adminClient();
  const ts = nowUnix();

  const { data: list, error } = await db
    .from("shopping_lists")
    .update({ status: "shopping", session_started_at: ts, last_update: ts })
    .eq("id", input.list_id)
    .select()
    .single();
  if (error) return json({ error: error.message }, 500);

  await db.from("shopping_sessions").insert({
    list_id: list.id,
    household_id: list.household_id,
    started_at: ts,
    created_at: ts,
  });

  // Shared list → tell the rest of the household someone is at the store.
  let notified = 0;
  if (list.scope === "household") {
    const { data: members } = await db
      .from("household_members")
      .select("user_id")
      .eq("household_id", list.household_id)
      .neq("user_id", input.user_id);
    const ids = (members ?? []).map((m) => m.user_id as string);
    if (ids.length > 0) {
      await invokeNotify({
        type: "shopping",
        household_id: list.household_id,
        user_ids: ids,
        title: list.name,
        body: "Shopping session started",
        payload: { list_id: list.id },
      });
      notified = ids.length;
    }
  }

  return json({ list, notified });
});
