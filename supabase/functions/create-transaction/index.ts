// create-transaction
// Inserts (or updates) a transaction AND recomputes the bank account balance
// atomically from the server. The client invokes this instead of writing the
// transactions table directly, so balances are always authoritative.
//
// POST body: { transaction: { ...row... }, id?: string }
//   - id present  → update that transaction
//   - id absent   → insert new

import { adminClient, CORS, json, nowUnix, recomputeBalance } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: { transaction: Record<string, unknown>; id?: string };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const row = input.transaction;
  if (!row || !row.bank_account_id) {
    return json({ error: "Missing transaction.bank_account_id" }, 400);
  }

  const db = adminClient();
  const ts = nowUnix();

  // Capture both accounts when an update moves the tx between accounts.
  let priorAccount: string | null = null;
  if (input.id) {
    const { data: prev } = await db
      .from("transactions")
      .select("bank_account_id")
      .eq("id", input.id)
      .single();
    priorAccount = prev?.bank_account_id ?? null;
  }

  let saved;
  if (input.id) {
    const { data, error } = await db
      .from("transactions")
      .update({ ...row, last_update: ts })
      .eq("id", input.id)
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  } else {
    const { data, error } = await db
      .from("transactions")
      .insert({ ...row, created_at: ts, last_update: ts })
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  }

  const accountId = saved.bank_account_id as string;
  const newBalance = await recomputeBalance(db, accountId);
  if (priorAccount && priorAccount !== accountId) {
    await recomputeBalance(db, priorAccount);
  }

  return json({ transaction: saved, current_balance: newBalance });
});
