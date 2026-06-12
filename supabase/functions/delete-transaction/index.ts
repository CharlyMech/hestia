// delete-transaction
// Deletes a transaction and recomputes the affected account's balance.
// POST body: { id: string }

import { adminClient, CORS, json, recomputeBalance } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: { id: string };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.id) return json({ error: "Missing id" }, 400);

  const db = adminClient();

  const { data: row } = await db
    .from("transactions")
    .select("bank_account_id")
    .eq("id", input.id)
    .single();

  const { error } = await db.from("transactions").delete().eq("id", input.id);
  if (error) return json({ error: error.message }, 500);

  let newBalance: number | null = null;
  if (row?.bank_account_id) {
    newBalance = await recomputeBalance(db, row.bank_account_id);
  }

  return json({ deleted: input.id, current_balance: newBalance });
});
