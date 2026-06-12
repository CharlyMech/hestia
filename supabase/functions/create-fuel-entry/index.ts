// create-fuel-entry
// Inserts (or updates) a fuel entry and, when requested, the linked expense
// transaction — atomically from the app's point of view. Also advances the
// car's current_odometer_km when the entry reports a higher reading.
//
// POST body: {
//   entry: { ...fuel_entries row... },        // car_id required
//   transaction?: { ...transactions row... }, // optional expense to create+link
//   id?: string                               // present → update that entry
// }

import { adminClient, CORS, insertTransaction, json, nowUnix } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: {
    entry: Record<string, unknown>;
    transaction?: Record<string, unknown>;
    id?: string;
  };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const entry = input.entry;
  if (!entry || !entry.car_id) return json({ error: "Missing entry.car_id" }, 400);

  const db = adminClient();
  const ts = nowUnix();

  // Optional expense first, so the entry row can carry the link.
  let createdTx: Record<string, unknown> | undefined;
  if (input.transaction) {
    const r = await insertTransaction(db, { ...input.transaction, car_id: entry.car_id });
    if (r.error) return json({ error: r.error }, 500);
    createdTx = r.transaction;
    entry.transaction_id = createdTx!.id;
  }

  let saved;
  if (input.id) {
    const { data, error } = await db
      .from("fuel_entries")
      .update({ ...entry, last_update: ts })
      .eq("id", input.id)
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  } else {
    const { data, error } = await db
      .from("fuel_entries")
      .insert({ ...entry, created_at: ts, last_update: ts })
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  }

  // Advance the car odometer (never move it backwards).
  if (saved.odometer_km != null) {
    const { data: car } = await db
      .from("cars")
      .select("current_odometer_km")
      .eq("id", saved.car_id)
      .single();
    if (car && (car.current_odometer_km == null ||
        Number(saved.odometer_km) > Number(car.current_odometer_km))) {
      await db
        .from("cars")
        .update({ current_odometer_km: saved.odometer_km, last_update: ts })
        .eq("id", saved.car_id);
    }
  }

  return json({ entry: saved, transaction: createdTx ?? null });
});
