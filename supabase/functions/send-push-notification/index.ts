// Supabase Edge Function: send-push-notification
// Admin-only: send a single notification (promotion or system) to many users
// Triggers the existing `send-notification` FCM pipeline via DB INSERT
// Deploy: supabase functions deploy send-push-notification --no-verify-jwt

// deno-lint-ignore-file no-explicit-any
import { createClient } from "jsr:@supabase/supabase-js@2";

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

const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY =
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

type BroadcastTarget =
  | { type: "all" }
  | { type: "customers" }
  | { type: "admins" }
  | { type: "specific"; userIds: string[] };

interface BroadcastRequest {
  titleAr: string;
  bodyAr: string;
  type: "promotion" | "system";
  target: BroadcastTarget;
  referenceType?: string;
  referenceId?: string;
  senderId: string;
}

interface BroadcastResponse {
  ok: boolean;
  recipientCount: number;
  sentCount?: number;
  skippedCount?: number;
  notificationIds: string[];
  skipped: number;
  error?: string;
}

Deno.serve(async (req: Request) => {
  const corsHeaders = getCorsHeaders(req);
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return new Response(
      JSON.stringify({ ok: false, error: "Server configuration error" }),
      { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ ok: false, error: "Method not allowed" }),
      { status: 405, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  let payload: BroadcastRequest;
  try {
    payload = await req.json();
  } catch (_e) {
    return new Response(
      JSON.stringify({ ok: false, error: "Invalid JSON" }),
      { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  const validation = validateBroadcastRequest(payload);
  if (validation) {
    return new Response(
      JSON.stringify({ ok: false, error: validation }),
      { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  // Extract authorization header
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return new Response(
      JSON.stringify({ ok: false, error: "Unauthorized: Missing token" }),
      { status: 401, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }
  const token = authHeader.substring(7);

  // Verify token using supabase auth API
  const authResponse = await supabase.auth.getUser(token);
  const user = authResponse.data?.user;
  const authError = authResponse.error;
  if (authError || !user) {
    return new Response(
      JSON.stringify({ ok: false, error: "Unauthorized: Invalid token" }),
      { status: 401, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  // Prevent impersonation: senderId must match authenticated user's ID
  if (payload.senderId !== user.id) {
    return new Response(
      JSON.stringify({ ok: false, error: "Forbidden: senderId mismatch" }),
      { status: 403, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  // Verify sender is admin
  const { data: senderProfile, error: senderError } = await supabase
    .from("profiles")
    .select("id, role")
    .eq("id", user.id)
    .single();

  if (senderError || !senderProfile) {
    return new Response(
      JSON.stringify({ ok: false, error: "Sender profile not found" }),
      { status: 404, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  if (senderProfile.role !== "admin") {
    return new Response(
      JSON.stringify({ ok: false, error: "Forbidden: admin only" }),
      { status: 403, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  // Resolve target user IDs
  const targetUserIds = await resolveTargetUserIds(payload.target);
  if (targetUserIds.error) {
    return new Response(
      JSON.stringify({ ok: false, error: targetUserIds.error }),
      { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  if (targetUserIds.userIds.length === 0) {
    return new Response(
      JSON.stringify({
        ok: true,
        recipientCount: 0,
        sentCount: 0,
        skippedCount: 0,
        notificationIds: [],
        skipped: 0,
      } as BroadcastResponse),
      { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } },
    );
  }

  // Record broadcast log first
  const { data: logData, error: logError } = await supabase
    .from("broadcast_logs")
    .insert({
      sender_id: payload.senderId,
      title_ar: payload.titleAr,
      body_ar: payload.bodyAr,
      type: payload.type,
      target_type: payload.target.type,
      target_user_ids:
        payload.target.type === "specific" ? payload.target.userIds : null,
      reference_type: payload.referenceType ?? null,
      reference_id: payload.referenceId ?? null,
      recipient_count: targetUserIds.userIds.length,
    })
    .select("id")
    .single();

  if (logError) {
    console.error(
      "[send-push-notification] failed to log broadcast:",
      logError.message,
    );
  }

  // Batch insert notification rows (DB trigger will fire FCM send)
  const rows = targetUserIds.userIds.map((userId) => ({
    user_id: userId,
    title_ar: payload.titleAr,
    body_ar: payload.bodyAr,
    type: payload.type,
    reference_type: payload.referenceType ?? null,
    reference_id: payload.referenceId ?? null,
  }));

  // Insert in batches of 500 to avoid request body limits
  const batchSize = 500;
  const insertedIds: string[] = [];
  let skipped = 0;

  for (let i = 0; i < rows.length; i += batchSize) {
    const batch = rows.slice(i, i + batchSize);
    const { data, error } = await supabase
      .from("notifications")
      .insert(batch)
      .select("id");

    if (error) {
      console.error(
        `[send-push-notification] batch ${i}-${i + batch.length} failed:`,
        error.message,
      );
      skipped += batch.length;
    } else {
      insertedIds.push(...(data ?? []).map((row) => row.id as string));
    }
  }

  // Update log with actual sent count
  if (logData?.id) {
    await supabase
      .from("broadcast_logs")
      .update({
        sent_count: insertedIds.length,
        skipped_count: skipped,
      })
      .eq("id", logData.id);
  }

  return new Response(
    JSON.stringify({
      ok: true,
      recipientCount: insertedIds.length,
      sentCount: insertedIds.length,
      skippedCount: skipped,
      notificationIds: insertedIds,
      skipped,
    } as BroadcastResponse),
    { status: 200, headers: { "Content-Type": "application/json", ...corsHeaders } },
  );
});

function validateBroadcastRequest(req: BroadcastRequest | any): string | null {
  if (!req || typeof req !== "object") return "Empty body";
  if (!req.titleAr || typeof req.titleAr !== "string" || req.titleAr.trim().length === 0) {
    return "titleAr is required";
  }
  if (req.titleAr.length > 200) return "titleAr too long (max 200 chars)";
  if (!req.bodyAr || typeof req.bodyAr !== "string" || req.bodyAr.trim().length === 0) {
    return "bodyAr is required";
  }
  if (req.bodyAr.length > 1000) return "bodyAr too long (max 1000 chars)";
  if (req.type !== "promotion" && req.type !== "system") {
    return "type must be 'promotion' or 'system'";
  }
  if (!req.senderId || typeof req.senderId !== "string") {
    return "senderId is required";
  }
  if (!req.target || typeof req.target !== "object") return "target is required";

  const t = req.target;
  if (t.type === "all" || t.type === "customers" || t.type === "admins") {
    return null;
  }
  if (t.type === "specific") {
    if (!Array.isArray(t.userIds) || t.userIds.length === 0) {
      return "specific target requires non-empty userIds array";
    }
    if (t.userIds.length > 10000) return "specific target too large (max 10000)";
    for (const id of t.userIds) {
      if (typeof id !== "string" || id.length === 0) {
        return "userIds must be non-empty strings";
      }
    }
    return null;
  }
  return "target.type must be all, customers, admins, or specific";
}

async function resolveTargetUserIds(
  target: BroadcastTarget,
): Promise<{ userIds: string[]; error?: string }> {
  if (target.type === "all") {
    const { data, error } = await supabase
      .from("profiles")
      .select("id");
    if (error) return { userIds: [], error: error.message };
    return { userIds: (data ?? []).map((r) => r.id as string) };
  }

  if (target.type === "customers") {
    const { data, error } = await supabase
      .from("profiles")
      .select("id")
      .eq("role", "customer");
    if (error) return { userIds: [], error: error.message };
    return { userIds: (data ?? []).map((r) => r.id as string) };
  }

  if (target.type === "admins") {
    const { data, error } = await supabase
      .from("profiles")
      .select("id")
      .eq("role", "admin");
    if (error) return { userIds: [], error: error.message };
    return { userIds: (data ?? []).map((r) => r.id as string) };
  }

  // specific
  return { userIds: target.userIds };
}
