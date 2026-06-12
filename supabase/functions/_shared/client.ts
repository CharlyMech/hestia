// Shared helpers for Hestia edge functions.

import { createClient, SupabaseClient } from "jsr:@supabase/supabase-js@2";

export const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

/** Service-role client. Bypasses RLS — only use inside trusted edge fns. */
export function adminClient(): SupabaseClient {
  return createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );
}

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "Content-Type": "application/json" },
  });
}

export const nowUnix = () => Math.floor(Date.now() / 1000);

/**
 * Insert a transaction row and recompute its account balance. Shared by the
 * composite-write functions (create-fuel-entry, create-health-record,
 * create-maintenance-record, complete-shopping-session) so a record and its
 * expense are created in one round-trip from the app.
 */
export async function insertTransaction(
  db: SupabaseClient,
  row: Record<string, unknown>,
): Promise<{ transaction?: Record<string, unknown>; error?: string }> {
  if (!row.bank_account_id) return { error: "Missing transaction.bank_account_id" };
  const ts = nowUnix();
  const { data, error } = await db
    .from("transactions")
    .insert({ ...row, created_at: ts, last_update: ts })
    .select()
    .single();
  if (error) return { error: error.message };
  await recomputeBalance(db, data.bank_account_id as string);
  return { transaction: data };
}

/** Fire-and-forget call to the notify edge function (inbox + FCM push). */
export async function invokeNotify(payload: {
  type: string;
  household_id?: string | null;
  user_ids: string[];
  title: string;
  body: string;
  payload?: Record<string, unknown>;
}): Promise<void> {
  await fetch(`${Deno.env.get("SUPABASE_URL")}/functions/v1/notify`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")}`,
    },
    body: JSON.stringify(payload),
  }).catch(() => {});
}

/** Recompute a bank account's current_balance from transactions + transfers. */
export async function recomputeBalance(
  db: SupabaseClient,
  accountId: string,
): Promise<number | null> {
  const { data: acct } = await db
    .from("bank_accounts")
    .select("initial_balance")
    .eq("id", accountId)
    .single();
  if (!acct) return null;

  const { data: txs } = await db
    .from("transactions")
    .select("amount, type")
    .eq("bank_account_id", accountId);

  const { data: tin } = await db
    .from("transfers")
    .select("amount")
    .eq("to_account_id", accountId);
  const { data: tout } = await db
    .from("transfers")
    .select("amount")
    .eq("from_account_id", accountId);

  let balance = Number(acct.initial_balance) || 0;
  for (const t of txs ?? []) {
    if (t.type === "income") balance += Number(t.amount);
    else if (t.type === "expense") balance -= Number(t.amount);
  }
  for (const t of tin ?? []) balance += Number(t.amount);
  for (const t of tout ?? []) balance -= Number(t.amount);

  await db
    .from("bank_accounts")
    .update({ current_balance: balance, last_update: nowUnix() })
    .eq("id", accountId);

  return balance;
}
