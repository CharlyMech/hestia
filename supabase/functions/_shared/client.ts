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
