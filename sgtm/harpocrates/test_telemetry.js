/*
 Copyright 2026 Google LLC
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
      https://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

// Hermetic tests for telemetry.js. No network request is ever made: fetch is
// always replaced with a fake.

const assert = require('assert');
const {
  isOptedIn,
  normalizeCustomerId,
  normalizeContainerId,
  sendUsageEvent,
} = require('./telemetry.js');

const createFakeFetch = (status = 204) => {
  const calls = [];
  const fakeFetch = async (url, options) => {
    calls.push({ url, options, body: JSON.parse(options.body) });
    return { status };
  };
  return { fakeFetch, calls };
};

const failingFetch = async () => {
  throw new Error('network down');
};

const run = async () => {
  // --- Opt-in parsing ---
  for (const value of ['true', 'TRUE', 'yes', 'y', '1', ' true ']) {
    assert.strictEqual(isOptedIn(value), true, `Expected opt-in for "${value}"`);
  }
  for (const value of [undefined, '', 'false', 'no', 'n', '0', 'maybe']) {
    assert.strictEqual(isOptedIn(value), false, `Expected no opt-in for "${value}"`);
  }

  // --- ID normalization ---
  assert.strictEqual(normalizeCustomerId('123-456-7890'), '123-456-7890');
  assert.strictEqual(normalizeCustomerId(' 1234567890 '), '123-456-7890');
  assert.strictEqual(normalizeCustomerId('12345'), null);
  assert.strictEqual(normalizeCustomerId('abc-def-ghij'), null);
  assert.strictEqual(normalizeCustomerId(undefined), null);
  assert.strictEqual(normalizeContainerId('gtm-abc1234'), 'GTM-ABC1234');
  assert.strictEqual(normalizeContainerId('ABC1234'), null);
  assert.strictEqual(normalizeContainerId(''), null);

  // 1. Sends nothing when the user has not opted in (unset or false).
  for (const optIn of [undefined, 'false']) {
    const { fakeFetch, calls } = createFakeFetch();
    const result = await sendUsageEvent(
      { TELEMETRY_OPT_IN: optIn, GOOGLE_ADS_CUSTOMER_ID: '123-456-7890' },
      fakeFetch
    );
    assert.strictEqual(result.sent, false);
    assert.strictEqual(calls.length, 0, 'No request may be sent without opt-in');
  }

  // 2. Sends nothing when opted in but no valid ID was provided.
  {
    const { fakeFetch, calls } = createFakeFetch();
    const result = await sendUsageEvent(
      { TELEMETRY_OPT_IN: 'true', GOOGLE_ADS_CUSTOMER_ID: 'not-an-id', GTM_CONTAINER_ID: '' },
      fakeFetch
    );
    assert.strictEqual(result.sent, false);
    assert.strictEqual(calls.length, 0, 'No request may be sent without a valid ID');
  }

  // 3. Sends one SOLUTION_USAGE event with both IDs when opted in.
  {
    const { fakeFetch, calls } = createFakeFetch();
    const result = await sendUsageEvent(
      {
        TELEMETRY_OPT_IN: 'true',
        GOOGLE_ADS_CUSTOMER_ID: '1234567890',
        GTM_CONTAINER_ID: 'GTM-ABC1234',
        DECRYPTION_KEY: 'must-never-be-sent',
        IV: 'must-never-be-sent-either',
        PROJECT_ID: 'my-secret-project',
        SGTM_SERVICE_ACCOUNT: 'sa@my-secret-project.iam.gserviceaccount.com',
      },
      fakeFetch
    );
    assert.deepStrictEqual(result, { sent: true, reason: 'ok' });
    assert.strictEqual(calls.length, 1, 'Expected exactly one request');

    const { url, options, body } = calls[0];
    assert.ok(url.startsWith('https://www.google-analytics.com/mp/collect?'));
    assert.ok(url.includes('measurement_id=G-Z2TKLQZ79K'));
    assert.strictEqual(options.method, 'POST');
    assert.strictEqual(body.events.length, 1);
    assert.ok(body.client_id, 'client_id is required by the Measurement Protocol');

    const event = body.events[0];
    assert.strictEqual(event.name, 'SOLUTION_USAGE');
    assert.strictEqual(event.params.app, 'sGTM Pantheon');
    assert.strictEqual(event.params.is_agent_event, false);
    assert.strictEqual(event.params.non_personalized_ads, false);
    assert.strictEqual(event.params.label, 'harpocrates_deploy');
    assert.ok(event.params.external_event_id, 'external_event_id is required');
    // External Customer IDs must keep their hyphens.
    assert.strictEqual(event.params.th_google_ads_customer_id, '123-456-7890');
    assert.strictEqual(event.params.th_container_id, 'GTM-ABC1234');

    // No secrets or deployment details may leak into the request.
    const serialized = JSON.stringify(calls[0]);
    for (const secret of ['must-never-be-sent', 'my-secret-project']) {
      assert.ok(!serialized.includes(secret), `Request must not contain "${secret}"`);
    }
  }

  // 4. Sends only the ID that was provided, with a fresh event ID each time.
  {
    const { fakeFetch, calls } = createFakeFetch();
    const env = { TELEMETRY_OPT_IN: 'yes', GTM_CONTAINER_ID: 'GTM-ABC1234' };
    await sendUsageEvent(env, fakeFetch);
    await sendUsageEvent(env, fakeFetch);
    const [first, second] = calls.map((call) => call.body.events[0].params);
    assert.strictEqual(first.th_container_id, 'GTM-ABC1234');
    assert.ok(!('th_google_ads_customer_id' in first));
    assert.notStrictEqual(first.external_event_id, second.external_event_id);
  }

  // 5. Fails open: network errors and bad statuses never throw.
  {
    const env = { TELEMETRY_OPT_IN: 'true', GOOGLE_ADS_CUSTOMER_ID: '123-456-7890' };
    const failed = await sendUsageEvent(env, failingFetch);
    assert.strictEqual(failed.sent, false);
    assert.ok(failed.reason.includes('network down'));

    const { fakeFetch } = createFakeFetch(500);
    const rejected = await sendUsageEvent(env, fakeFetch);
    assert.strictEqual(rejected.sent, false);

    const noFetch = await sendUsageEvent(env, undefined);
    assert.strictEqual(noFetch.sent, false);
  }

  console.log('Telemetry tests passed!');
};

run().catch((error) => {
  console.error(error);
  process.exit(1);
});
