// Test scaffold for the send-notification Edge Function
// Run with: deno test --allow-net --allow-env supabase/functions/send-notification/test.ts
//
// These tests require live Supabase + Firebase credentials to actually run.
// For CI, the structure is in place — wire up when env is available.

import { assertEquals, assertExists } from "jsr:@std/assert@1";

const FUNCTION_URL = Deno.env.get("SUPABASE_FUNCTIONS_URL") ?? "";
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? Deno.env.get("SUPABASE_ANON_KEY") ?? "";

Deno.test({
  name: "send-notification rejects non-POST methods",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-notification`, {
      method: "GET",
    });
    assertEquals(res.status, 405);
    const body = await res.json();
    assertExists(body.error);
  },
});

Deno.test({
  name: "send-notification rejects invalid JSON",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-notification`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${ANON_KEY}`,
      },
      body: "not-json",
    });
    assertEquals(res.status, 400);
  },
});

Deno.test({
  name: "send-notification skips non-INSERT events",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-notification`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({ type: "UPDATE", record: null }),
    });
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.skipped, "not an INSERT");
  },
});

Deno.test({
  name: "send-notification skips when no device tokens",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-notification`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({
        type: "INSERT",
        record: {
          id: "00000000-0000-0000-0000-000000000000",
          user_id: "00000000-0000-0000-0000-000000000000",
          title_ar: "test",
          body_ar: "test",
          type: "system",
          reference_type: null,
          reference_id: null,
          created_at: new Date().toISOString(),
        },
      }),
    });
    assertEquals(res.status, 200);
    const body = await res.json();
    assertEquals(body.ok, true);
  },
});
