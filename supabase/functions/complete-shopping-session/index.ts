// complete-shopping-session
// Closes a shopping session and, when requested, creates the expense
// transaction and links it to the list — atomically from the app's view.
//
// POST body: {
//   list_id: string,
//   transaction?: { ...transactions row... },  // optional expense to create+link
//   cancelled?: boolean                        // true → no payment, back to active
// }

import { adminClient, CORS, insertTransaction, json, nowUnix } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: {
    list_id: string;
    transaction?: Record<string, unknown>;
    cancelled?: boolean;
  };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.list_id) return json({ error: "Missing list_id" }, 400);

  const db = adminClient();
  const ts = nowUnix();

  let createdTx: Record<string, unknown> | undefined;
  if (!input.cancelled && input.transaction) {
    const r = await insertTransaction(db, input.transaction);
    if (r.error) return json({ error: r.error }, 500);
    createdTx = r.transaction;
  }

  const patch: Record<string, unknown> = input.cancelled
    ? { status: "active", session_started_at: null, last_update: ts }
    : {
        status: "completed",
        session_ended_at: ts,
        last_update: ts,
        ...(createdTx
          ? {
              transaction_id: createdTx.id,
              bank_account_id: createdTx.bank_account_id,
              paid_at: ts,
            }
          : {}),
      };

  const { data: list, error } = await db
    .from("shopping_lists")
    .update(patch)
    .eq("id", input.list_id)
    .select()
    .single();
  if (error) return json({ error: error.message }, 500);

  // Close the open session row (latest without ended_at).
  await db
    .from("shopping_sessions")
    .update({ ended_at: ts })
    .eq("list_id", input.list_id)
    .is("ended_at", null);

  return json({ list, transaction: createdTx ?? null });
});
