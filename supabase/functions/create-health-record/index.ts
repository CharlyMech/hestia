// create-health-record
// Inserts (or updates) a pet health record (vet|vaccine|medicine|deworming|
// surgery|other) and, when requested, the linked expense transaction.
// Weight/size tracking is pet_measurements (plain client write); pet
// purchases are plain transactions with pet_id — neither goes through here.
//
// POST body: {
//   record: { ...pet_health_records row... },  // pet_id required
//   transaction?: { ...transactions row... },  // optional expense to create+link
//   id?: string                                // present → update that record
// }

import { adminClient, CORS, insertTransaction, json, nowUnix } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: {
    record: Record<string, unknown>;
    transaction?: Record<string, unknown>;
    id?: string;
  };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const record = input.record;
  if (!record || !record.pet_id) return json({ error: "Missing record.pet_id" }, 400);

  const db = adminClient();
  const ts = nowUnix();

  let createdTx: Record<string, unknown> | undefined;
  if (input.transaction) {
    const r = await insertTransaction(db, { ...input.transaction, pet_id: record.pet_id });
    if (r.error) return json({ error: r.error }, 500);
    createdTx = r.transaction;
    record.transaction_id = createdTx!.id;
  }

  let saved;
  if (input.id) {
    const { data, error } = await db
      .from("pet_health_records")
      .update({ ...record, last_update: ts })
      .eq("id", input.id)
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  } else {
    const { data, error } = await db
      .from("pet_health_records")
      .insert({ ...record, created_at: ts, last_update: ts })
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  }

  return json({ record: saved, transaction: createdTx ?? null });
});
