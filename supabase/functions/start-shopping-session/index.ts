// start-shopping-session
// Notifies the other household members that a SHARED shopping session has
// started. Two modes:
//   * New model:    { session_id, user_id } → notify based on shopping_sessions.
//   * Legacy model: { list_id, user_id }    → mark a shopping_lists row active +
//                                             insert a shopping_sessions audit row
//                                             (kept for back-compat).
//
// POST body: { session_id?: string, list_id?: string, user_id: string }

import { adminClient, CORS, invokeNotify, json, nowUnix } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: { session_id?: string; list_id?: string; user_id: string };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.user_id || (!input.session_id && !input.list_id)) {
    return json({ error: "Missing session_id/list_id or user_id" }, 400);
  }

  const db = adminClient();
  const ts = nowUnix();

  // ── New session model ──────────────────────────────────────────────────
  if (input.session_id) {
    const { data: session, error } = await db
      .from("shopping_sessions")
      .select("id, name, scope, household_id")
      .eq("id", input.session_id)
      .single();
    if (error) return json({ error: error.message }, 500);

    let notified = 0;
    if (session.scope === "shared") {
      // Targeted share: notify only the listed members (minus the starter).
      // Empty member list = whole household ("All").
      const { data: shareRows } = await db
        .from("shopping_session_members")
        .select("user_id")
        .eq("session_id", session.id);
      const memberIds = (shareRows ?? [])
        .map((r: { user_id: string }) => r.user_id)
        .filter((id: string) => id !== input.user_id);

      if (memberIds.length > 0) {
        await invokeNotify({
          type: "shopping",
          household_id: session.household_id,
          user_ids: memberIds,
          title: session.name,
          body: "Shopping session started",
          payload: { session_id: session.id },
        });
        notified = memberIds.length;
      } else if ((shareRows ?? []).length === 0) {
        notified = await notifyHousehold(db, {
          householdId: session.household_id,
          excludeUserId: input.user_id,
          title: session.name,
          payload: { session_id: session.id },
        });
      }
    }
    return json({ session, notified });
  }

  // ── Legacy list model ────────────────────────────────────────────────────
  const { data: list, error } = await db
    .from("shopping_lists")
    .update({ status: "active", session_started_at: ts, last_update: ts })
    .eq("id", input.list_id!)
    .select()
    .single();
  if (error) return json({ error: error.message }, 500);

  await db.from("shopping_sessions").insert({
    list_id: list.id,
    household_id: list.household_id,
    started_at: ts,
    created_at: ts,
  });

  let notified = 0;
  if (list.scope === "shared") {
    notified = await notifyHousehold(db, {
      householdId: list.household_id,
      excludeUserId: input.user_id,
      title: list.name,
      payload: { list_id: list.id },
    });
  }
  return json({ list, notified });
});

// deno-lint-ignore no-explicit-any
async function notifyHousehold(db: any, opts: {
  householdId: string;
  excludeUserId: string;
  title: string;
  payload: Record<string, unknown>;
}): Promise<number> {
  const { data: members } = await db
    .from("household_members")
    .select("user_id")
    .eq("household_id", opts.householdId)
    .neq("user_id", opts.excludeUserId);
  const ids = (members ?? []).map((m: { user_id: string }) => m.user_id);
  if (ids.length === 0) return 0;
  await invokeNotify({
    type: "shopping",
    household_id: opts.householdId,
    user_ids: ids,
    title: opts.title,
    body: "Shopping session started",
    payload: opts.payload,
  });
  return ids.length;
}
