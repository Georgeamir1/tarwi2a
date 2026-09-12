import assert from 'node:assert/strict';
import { test } from 'node:test';
import { handleDeleteAccount } from '../../supabase/functions/delete-account/handler.ts';

function fixture(overrides = {}) {
  const calls = [];
  const services = {
    getUser: async () => ({ data: { id: 'user-a' }, error: null }),
    listObjects: async () => ({ data: [], error: null }),
    removeObjects: async (bucket, names) => { calls.push(['storage', bucket, names]); return { error: null }; },
    deleteData: async (id) => { calls.push(['data', id]); return { error: null }; },
    deleteUser: async (id) => { calls.push(['auth', id]); return { error: null }; },
    ...overrides,
  };
  const request = (body = {}) => new Request('https://example.test/delete-account', {
    method: 'POST', headers: { authorization: 'Bearer valid-session', 'content-type': 'application/json' },
    body: JSON.stringify(body),
  });
  return { calls, services, request };
}

test('deletion rejects unauthenticated calls before any mutation', async () => {
  const { calls, services } = fixture();
  const response = await handleDeleteAccount(new Request('https://example.test', { method: 'POST' }), services);
  assert.equal(response.status, 401);
  assert.deepEqual(calls, []);
});

test('deletion ignores caller-supplied target identity', async () => {
  const { calls, services, request } = fixture();
  assert.equal((await handleDeleteAccount(request({ user_id: 'victim' }), services)).status, 200);
  assert.deepEqual(calls, [['data', 'user-a'], ['auth', 'user-a']]);
});

for (const step of ['listObjects', 'removeObjects', 'deleteData', 'deleteUser']) {
  test(`${step} failure never reports deletion success`, async () => {
    const { calls, services, request } = fixture({
      listObjects: async () => ({ data: [{ bucket_id: 'proofs', name: 'nested/path/photo.jpg' }], error: null }),
      [step]: async () => ({ data: null, error: { message: 'secret database information' } }),
    });
    if (step === 'deleteData' || step === 'deleteUser') services.listObjects = async () => ({ data: [], error: null });
    const response = await handleDeleteAccount(request(), services);
    assert.equal(response.status, 503);
    assert.doesNotMatch(await response.text(), /secret database/);
    if (step !== 'deleteUser') assert.ok(!calls.some(([stage]) => stage === 'auth'));
  });
}

test('all storage pages and nested paths are removed before data and Auth', async () => {
  const pages = [
    [{ bucket_id: 'proofs', name: 'user-a/deep/one.jpg' }],
    [{ bucket_id: 'proofs', name: 'outside-user-folder.jpg' }], [],
  ];
  const { calls, services, request } = fixture({ listObjects: async () => ({ data: pages.shift(), error: null }) });
  assert.equal((await handleDeleteAccount(request(), services)).status, 200);
  assert.deepEqual(calls, [
    ['storage', 'proofs', ['user-a/deep/one.jpg']], ['storage', 'proofs', ['outside-user-folder.jpg']],
    ['data', 'user-a'], ['auth', 'user-a'],
  ]);
});

test('storage reporting success without removing objects fails instead of looping', async () => {
  const { calls, services, request } = fixture({ listObjects: async () => ({ data: [{ bucket_id: 'files', name: 'same' }], error: null }) });
  assert.equal((await handleDeleteAccount(request(), services)).status, 503);
  assert.equal(calls.length, 1);
});

test('partial Auth failure can be retried to completion', async () => {
  let attempts = 0;
  const { services, request } = fixture({ deleteUser: async () => ({ error: attempts++ === 0 ? 'unavailable' : null }) });
  assert.equal((await handleDeleteAccount(request(), services)).status, 503);
  assert.equal((await handleDeleteAccount(request(), services)).status, 200);
});
