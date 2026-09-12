type StorageObject = { bucket_id: string; name: string };
type Result<T> = { data: T | null; error: unknown };

export interface DeletionServices {
  getUser(token: string): Promise<Result<{ id: string }>>;
  listObjects(userId: string): Promise<Result<StorageObject[]>>;
  removeObjects(bucket: string, names: string[]): Promise<{ error: unknown }>;
  deleteData(userId: string): Promise<{ error: unknown }>;
  deleteUser(userId: string): Promise<{ error: unknown }>;
}

// Authenticate with Supabase, never a user ID supplied by the browser. Required
// stages fail closed, leaving the Auth account available for an authenticated retry.
export async function handleDeleteAccount(req: Request, services: DeletionServices): Promise<Response> {
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Content-Type': 'application/json',
    'Cache-Control': 'no-store',
  };
  const reply = (status: number, body: object) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === 'OPTIONS') return new Response(null, { status: 204, headers });
  if (req.method !== 'POST') return reply(405, { error: 'Method not allowed' });
  const token = /^Bearer\s+(\S+)$/i.exec(req.headers.get('authorization') ?? '')?.[1];
  if (!token) return reply(401, { error: 'Authentication required' });
  try {
    const user = await services.getUser(token);
    if (user.error || !user.data) return reply(401, { error: 'Authentication required' });
    const userId = user.data.id;
    let completed = false;
    let previousPage = '';
    // Read the first remaining page after removing each batch. Offsetting a
    // shrinking result set skips files; exact object paths include nested files.
    for (let page = 0; page < 1000; page++) {
      const result = await services.listObjects(userId);
      if (result.error || result.data === null) throw new Error('storage-list');
      if (result.data.length === 0) { completed = true; break; }
      const signature = JSON.stringify(result.data);
      if (signature === previousPage) throw new Error('storage-no-progress');
      previousPage = signature;
      const buckets = new Map<string, string[]>();
      for (const file of result.data) {
        if (!file.bucket_id || !file.name) throw new Error('storage-path');
        const names = buckets.get(file.bucket_id) ?? [];
        names.push(file.name);
        buckets.set(file.bucket_id, names);
      }
      for (const [bucket, names] of buckets) {
        if ((await services.removeObjects(bucket, names)).error) throw new Error('storage-remove');
      }
    }
    if (!completed) throw new Error('storage-page-limit');
    // Retain identifying references until storage has been removed. Retrying
    // after a database/Auth failure repeats idempotent cleanup stages.
    if ((await services.deleteData(userId)).error) throw new Error('database-delete');
    if ((await services.deleteUser(userId)).error) throw new Error('auth-delete');
    return reply(200, { success: true });
  } catch {
    // Never disclose server errors, SQL, storage paths or personal data.
    return reply(503, { error: 'Account deletion could not be completed. Please retry.' });
  }
}
