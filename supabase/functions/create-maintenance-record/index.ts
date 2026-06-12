// create-maintenance-record
// Inserts (or updates) a car maintenance record (mechanic|itv|tires|oil|
// insurance|other) and, when requested, the linked expense transaction.
// Mirrors create-health-record. Also advances the car odometer.
//
// POST body: {
//   record: { ...car_maintenance_records row... },  // car_id required
//   transaction?: { ...transactions row... },       // optional expense to create+link
//   id?: string                                     // present → update that record
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
  if (!record || !record.car_id) return json({ error: "Missing record.car_id" }, 400);

  const db = adminClient();
  const ts = nowUnix();

  let createdTx: Record<string, unknown> | undefined;
  if (input.transaction) {
    const r = await insertTransaction(db, { ...input.transaction, car_id: record.car_id });
    if (r.error) return json({ error: r.error }, 500);
    createdTx = r.transaction;
    record.transaction_id = createdTx!.id;
  }

  let saved;
  if (input.id) {
    const { data, error } = await db
      .from("car_maintenance_records")
      .update({ ...record, last_update: ts })
      .eq("id", input.id)
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  } else {
    const { data, error } = await db
      .from("car_maintenance_records")
      .insert({ ...record, created_at: ts, last_update: ts })
      .select()
      .single();
    if (error) return json({ error: error.message }, 500);
    saved = data;
  }

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

  return json({ record: saved, transaction: createdTx ?? null });
});
