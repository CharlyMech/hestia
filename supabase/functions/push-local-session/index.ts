// push-local-session
// Persists a finished PERSONAL (local-first) shopping session and its items to
// Supabase in one round-trip. Personal sessions live only in the device's local
// DB while active; this is called once on finish. Optionally creates the linked
// expense transaction (+ recomputes balance). No notification (personal).
//
// POST body: {
//   session: { id, household_id, owner_id, name, scope, status, template_id?,
//              bank_account_id?, transaction_source_id?, started_at, ended_at?,
//              paid_at? },
//   items: [{ name, qty, sort_order, is_checked, checked_at? }],
//   transaction?: { ...transactions row... },
//   cancelled?: boolean
// }

import { adminClient, CORS, insertTransaction, json, nowUnix } from "../_shared/client.ts";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let input: {
    session: Record<string, unknown>;
    items?: Array<Record<string, unknown>>;
    transaction?: Record<string, unknown>;
    cancelled?: boolean;
  };
  try {
    input = await req.json();
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }
  if (!input.session?.id || !input.session?.household_id) {
    return json({ error: "Missing session.id or session.household_id" }, 400);
  }

  const db = adminClient();
  const ts = nowUnix();

  let createdTx: Record<string, unknown> | undefined;
  if (!input.cancelled && input.transaction) {
    const r = await insertTransaction(db, input.transaction);
    if (r.error) return json({ error: r.error }, 500);
    createdTx = r.transaction;
  }

  const s = input.session;
  const sessionRow: Record<string, unknown> = {
    id: s.id,
    household_id: s.household_id,
    owner_id: s.owner_id,
    name: s.name ?? "",
    scope: s.scope ?? "personal",
    status: input.cancelled ? "cancelled" : "completed",
    template_id: s.template_id ?? null,
    transaction_source_id: s.transaction_source_id ?? null,
    started_at: s.started_at ?? ts,
    ended_at: ts,
    created_at: s.created_at ?? ts,
    last_update: ts,
    ...(createdTx
      ? {
          transaction_id: createdTx.id,
          bank_account_id: createdTx.bank_account_id,
          paid_at: ts,
        }
      : { bank_account_id: s.bank_account_id ?? null }),
  };

  const { data: session, error } = await db
    .from("shopping_sessions")
    .upsert(sessionRow)
    .select()
    .single();
  if (error) return json({ error: error.message }, 500);

  const items = input.items ?? [];
  if (items.length > 0) {
    const rows = items.map((it, i) => ({
      session_id: session.id,
      name: it.name,
      qty: (it.qty as number) ?? 1,
      sort_order: (it.sort_order as number) ?? i,
      is_checked: (it.is_checked as boolean) ?? false,
      checked_at: it.checked_at ?? null,
      created_at: ts,
      last_update: ts,
    }));
    const { error: itemsErr } = await db
      .from("shopping_session_items")
      .insert(rows);
    if (itemsErr) return json({ error: itemsErr.message }, 500);
  }

  return json({ session, transaction: createdTx ?? null });
});
