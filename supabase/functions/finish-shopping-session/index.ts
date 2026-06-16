// finish-shopping-session
// Finishes a SHARED shopping session for everyone and notifies the other
// household members that user X ended it. Optionally creates the linked
// expense transaction (+ recomputes the account balance) in the same call.
//
// POST body: {
//   session_id: string,
//   user_id: string,                          // the finisher
//   transaction?: { ...transactions row... },  // optional expense to create+link
//   cancelled?: boolean                        // true → no payment, status=cancelled
// }

import {
  adminClient,
  CORS,
  insertTransaction,
  invokeNotify,
  json,
  nowUnix,
} from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: {
    session_id: string;
    user_id: string;
    transaction?: Record<string, unknown>;
    cancelled?: boolean;
  };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.session_id || !input.user_id) {
    return json({ error: "Missing session_id or user_id" }, 400);
  }

  const db = adminClient();
  const ts = nowUnix();

  let createdTx: Record<string, unknown> | undefined;
  if (!input.cancelled && input.transaction) {
    const r = await insertTransaction(db, input.transaction);
    if (r.error) return json({ error: r.error }, 500);
    createdTx = r.transaction;
  }

  const patch: Record<string, unknown> = input.cancelled
    ? { status: "cancelled", ended_at: ts, last_update: ts }
    : {
        status: "completed",
        ended_at: ts,
        last_update: ts,
        ...(createdTx
          ? {
              transaction_id: createdTx.id,
              bank_account_id: createdTx.bank_account_id,
              paid_at: ts,
            }
          : {}),
      };

  const { data: session, error } = await db
    .from("shopping_sessions")
    .update(patch)
    .eq("id", input.session_id)
    .select()
    .single();
  if (error) return json({ error: error.message }, 500);

  // Notify the other household members that this shared session ended.
  let notified = 0;
  if (session.scope === "shared") {
    const { data: members } = await db
      .from("household_members")
      .select("user_id")
      .eq("household_id", session.household_id)
      .neq("user_id", input.user_id);
    const ids = (members ?? []).map((m) => m.user_id as string);

    const { data: finisher } = await db
      .from("profiles")
      .select("display_name")
      .eq("id", input.user_id)
      .maybeSingle();
    const who = (finisher?.display_name as string | null) ?? "Someone";

    if (ids.length > 0) {
      await invokeNotify({
        type: "shopping",
        household_id: session.household_id,
        user_ids: ids,
        title: session.name,
        body: input.cancelled
          ? `${who} cancelled the shopping session`
          : `${who} ended the shopping session`,
        payload: { session_id: session.id },
      });
      notified = ids.length;
    }
  }

  return json({ session, transaction: createdTx ?? null, notified });
});
