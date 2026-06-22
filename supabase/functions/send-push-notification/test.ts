// Test scaffold for send-push-notification Edge Function
// Run: deno test --allow-net --allow-env supabase/functions/send-push-notification/test.ts

import { assertEquals, assertExists } from "jsr:@std/assert@1";

const FUNCTION_URL = Deno.env.get("SUPABASE_FUNCTIONS_URL") ?? "";
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

Deno.test({
  name: "send-push-notification rejects non-POST",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-push-notification`, {
      method: "GET",
    });
    assertEquals(res.status, 405);
  },
});

Deno.test({
  name: "send-push-notification rejects invalid JSON",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-push-notification`, {
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
  name: "send-push-notification rejects empty title",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-push-notification`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${ANON_KEY}`,
      },
      body: JSON.stringify({
        titleAr: "",
        bodyAr: "test",
        type: "promotion",
        target: { type: "all" },
        senderId: "00000000-0000-0000-0000-000000000000",
      }),
    });
    assertEquals(res.status, 400);
    const body = await res.json();
    assertExists(body.error);
  },
});

Deno.test({
  name: "send-push-notification rejects invalid type",
  ignore: !FUNCTION_URL,
  fn: async () => {
    const res = await fetch(`${FUNCTION_URL}/send-push-notification`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${ANON_KEY}`,
      },
      body: JSON.stringify({
        titleAr: "Valid title",
        bodyAr: "Valid body",
        type: "invalid_type",
        target: { type: "all" },
        senderId: "00000000-0000-0000-0000-000000000000",
      }),
    });
    assertEquals(res.status, 400);
  },
});
