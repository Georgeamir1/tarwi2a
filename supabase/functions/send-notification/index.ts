// Supabase Edge Function: send-notification
// Triggered by INSERT on notifications table via DB trigger
// Uses FCM HTTP v1 API with jsrsasign for JWT signing
// Deploy: supabase functions deploy send-notification --no-verify-jwt

import { createClient } from "jsr:@supabase/supabase-js@2";
import { KJUR } from "npm:jsrsasign@11.1.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const FIREBASE_PROJECT_ID = Deno.env.get("FIREBASE_PROJECT_ID") ?? "";
const FIREBASE_CLIENT_EMAIL = Deno.env.get("FIREBASE_CLIENT_EMAIL") ?? "";
const FIREBASE_PRIVATE_KEY = (Deno.env.get("FIREBASE_PRIVATE_KEY") ?? "")
  .replace(/\\n/g, "\n")
  .replace(/^"|"$/g, "");

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

function getCorsHeaders(req: Request) {
  const origin = req.headers.get("origin") ?? "";
  let allowedOrigin = "";
  
  if (
    origin === "" || 
    origin === "null" || 
    origin.startsWith("http://localhost:") || 
    origin.startsWith("https://localhost:") ||
    origin === "http://localhost" ||
    origin === "https://localhost"
  ) {
    allowedOrigin = origin || "*";
  } else {
    allowedOrigin = "null";
  }

  return {
    "Access-Control-Allow-Origin": allowedOrigin,
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  };
}

function getAccessToken(): string {
  const now = Math.floor(Date.now() / 1000);
  const header = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss: FIREBASE_CLIENT_EMAIL,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const jwt = KJUR.jws.JWS.sign("RS256", JSON.stringify(header), JSON.stringify(payload), FIREBASE_PRIVATE_KEY);
  return jwt;
}

async function fetchAccessToken(): Promise<string> {
  const jwt = getAccessToken();
  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const data = await resp.json() as { access_token?: string; error?: string };
  if (!data.access_token) {
    throw new Error("No access_token: " + JSON.stringify(data));
  }
  return data.access_token;
}

interface NotificationRow {
  id: string;
  user_id: string;
  title: string;
  body: string;
  title_ar?: string;
  body_ar?: string;
  type: string;
  reference_type?: string | null;
  reference_id?: string | null;
  created_at: string;
}

Deno.serve(async (req: Request) => {
  const corsHeaders = getCorsHeaders(req);
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }
  if (req.method === "GET") {
    return new Response(JSON.stringify({ ok: true, hasProjectId: !!FIREBASE_PROJECT_ID }), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });
  }
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), { status: 405, headers: { "Content-Type": "application/json", ...corsHeaders } });
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (authHeader !== `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`) {
    return new Response(
      JSON.stringify({ error: "Unauthorized: Service role only" }),
      { status: 401, headers: { "Content-Type": "application/json", ...corsHeaders } }
    );
  }

  let payload: { type?: string; record?: NotificationRow };
  try {
    payload = await req.json();
  } catch (_e) {
    return new Response(JSON.stringify({ error: "Invalid JSON" }), { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } });
  }

  if (payload.type !== "INSERT" || !payload.record) {
    return new Response(JSON.stringify({ ok: true, skipped: "not an INSERT" }), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });
  }

  const notification = payload.record;

  const { data: prefs } = await supabase.from("notification_preferences").select("order_updates, promotions, push_enabled").eq("user_id", notification.user_id).maybeSingle();
  const pushEnabled = prefs?.push_enabled ?? true;
  const orderUpdates = prefs?.order_updates ?? true;
  const promotions = prefs?.promotions ?? true;
  const isOrderType = notification.type.startsWith("order_");
  const isPromotion = notification.type === "promotion";

  if (!pushEnabled) return new Response(JSON.stringify({ ok: true, skipped: "push disabled" }), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });
  if (isOrderType && !orderUpdates) return new Response(JSON.stringify({ ok: true, skipped: "order updates disabled" }), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });
  if (isPromotion && !promotions) return new Response(JSON.stringify({ ok: true, skipped: "promotions disabled" }), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });

  const { data: tokens, error: tokensError } = await supabase.from("device_tokens").select("token, platform").eq("user_id", notification.user_id);
  if (tokensError || !tokens || tokens.length === 0) {
    return new Response(JSON.stringify({ ok: true, skipped: "no device tokens" }), { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } });
  }

  const title = notification.title_ar ?? notification.title ?? "إشعار";
  const bodyText = notification.body_ar ?? notification.body ?? "";
  const dataPayload: Record<string, string> = { notification_id: notification.id, type: notification.type };
  if (notification.reference_type) dataPayload.reference_type = notification.reference_type;
  if (notification.reference_id) dataPayload.reference_id = notification.reference_id;

  let accessToken: string;
  try {
    accessToken = await fetchAccessToken();
  } catch (e) {
    return new Response(JSON.stringify({ error: "Token error: " + (e instanceof Error ? e.message : String(e)) }), { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } });
  }

  const results: Array<{ token: string; ok: boolean; error?: string }> = [];
  const invalidTokens: string[] = [];

  for (const device of tokens) {
    try {
      const channelId = notification.type.startsWith("order_") ? "order_updates" : notification.type === "promotion" ? "promotions" : "general";
      const resp = await fetch(`https://fcm.googleapis.com/v1/projects/${FIREBASE_PROJECT_ID}/messages:send`, {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${accessToken}` },
        body: JSON.stringify({
          message: {
            token: device.token,
            notification: { title, body: bodyText },
            data: dataPayload,
            android: { priority: "high", notification: { channelId, sound: "default", clickAction: "OPEN_NOTIFICATION" } },
            apns: { payload: { aps: { sound: "default", badge: 1, category: "NOTIFICATION_CATEGORY" } } },
          },
        }),
      });
      const respData = await resp.json() as any;
      if (!resp.ok) {
        const fcmErrorCode = respData?.error?.details?.[0]?.errorCode;
        const err = fcmErrorCode ?? respData?.error?.status ?? respData?.error?.message ?? "unknown";
        if (
          err === "UNREGISTERED" ||
          err === "INVALID_ARGUMENT" ||
          err === "NOT_FOUND" ||
          resp.status === 404
        ) {
          invalidTokens.push(device.token);
        }
        results.push({ token: device.token, ok: false, error: err });
      } else {
        results.push({ token: device.token, ok: true });
        console.log(`[send-notification] sent: ${respData.name}`);
      }
    } catch (e) {
      results.push({ token: device.token, ok: false, error: e instanceof Error ? e.message : String(e) });
    }
  }

  if (invalidTokens.length > 0) {
    await supabase.from("device_tokens").delete().in("token", invalidTokens);
  }

  const sent = results.filter((r) => r.ok).length;
  return new Response(JSON.stringify({ ok: true, sent, failed: results.length - sent, total: results.length }), { status: 200, headers: { "Content-Type": "application/json" } });
});
