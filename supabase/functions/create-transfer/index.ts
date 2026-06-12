// create-transfer
// Inserts a transfer row and recomputes BOTH accounts' balances atomically.
// POST body: { transfer: { household_id, user_id, from_account_id,
//                          to_account_id, amount, note?, date } }

import { adminClient, CORS, json, nowUnix, recomputeBalance } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: { transfer: Record<string, unknown> };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const row = input.transfer;
  if (!row?.from_account_id || !row?.to_account_id || row.amount == null) {
    return json({ error: "Missing transfer fields" }, 400);
  }
  if (row.from_account_id === row.to_account_id) {
    return json({ error: "from and to accounts must differ" }, 400);
  }

  const db = adminClient();
  const ts = nowUnix();

  const { data: saved, error } = await db
    .from("transfers")
    .insert({ ...row, created_at: ts, last_update: ts })
    .select()
    .single();
  if (error) return json({ error: error.message }, 500);

  const fromBalance = await recomputeBalance(db, row.from_account_id as string);
  const toBalance = await recomputeBalance(db, row.to_account_id as string);

  return json({ transfer: saved, from_balance: fromBalance, to_balance: toBalance });
});
