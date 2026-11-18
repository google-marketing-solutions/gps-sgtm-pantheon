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

/**
 * @fileoverview Optional, opt-in usage telemetry for the Harpocrates
 * deployment flow.
 *
 * deploy.sh runs this script once after a successful deployment, and only if
 * the user opted in. It sends a single SOLUTION_USAGE event using the Tadau
 * (https://github.com/google-marketing-solutions/tadau) Google Analytics 4
 * Measurement Protocol format.
 *
 * This file is not used by the deployed Cloud Function (index.js) and never
 * runs in the decryption path. It is fail-open: it never throws and the CLI
 * always exits with code 0, so telemetry can never break a deployment.
 *
 * The event contains only: the solution name, a random event ID, and the
 * Google Ads Customer ID and/or GTM container ID the user chose to provide.
 * It never contains keys, IVs, encrypted or decrypted values, project IDs or
 * service account emails.
 */
const crypto = require('crypto');

const GA_COLLECT_URL = 'https://www.google-analytics.com/mp/collect';
const MEASUREMENT_ID = 'G-Z2TKLQZ79K';
const API_SECRET = 'S7toNnNZQPWzViq44q_8gg';
const APP_NAME = 'sGTM Pantheon';
const EVENT_NAME = 'SOLUTION_USAGE';
const EVENT_LABEL = 'harpocrates_deploy';
const REQUEST_TIMEOUT_MS = 5000;

/**
 * Returns true only for an explicit opt-in value.
 * @param {string|undefined} value The raw TELEMETRY_OPT_IN value.
 * @return {boolean} Whether the user opted in.
 */
const isOptedIn = (value) =>
  typeof value === 'string' && /^(true|yes|y|1)$/i.test(value.trim());

/**
 * Normalizes a Google Ads Customer ID to the hyphenated XXX-XXX-XXXX format.
 * The hyphens are required: they mark the ID as an external Customer ID and
 * keep Google Analytics from converting it to a number.
 * @param {string|undefined} value The raw Customer ID.
 * @return {string|null} The hyphenated ID, or null if it is not valid.
 */
const normalizeCustomerId = (value) => {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  const match =
    /^(\d{3})-(\d{3})-(\d{4})$/.exec(trimmed) ||
    /^(\d{3})(\d{3})(\d{4})$/.exec(trimmed);
  return match ? `${match[1]}-${match[2]}-${match[3]}` : null;
};

/**
 * Normalizes a Google Tag Manager container ID (GTM-XXXXXXX).
 * @param {string|undefined} value The raw container ID.
 * @return {string|null} The upper-cased ID, or null if it is not valid.
 */
const normalizeContainerId = (value) => {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim().toUpperCase();
  return /^GTM-[A-Z0-9]{4,12}$/.test(trimmed) ? trimmed : null;
};

/**
 * Builds the Measurement Protocol payload for one SOLUTION_USAGE event.
 * @param {{customerId: ?string, containerId: ?string}} ids Normalized IDs.
 * @return {!object} The request payload.
 */
const buildPayload = ({ customerId, containerId }) => {
  const params = {
    app: APP_NAME,
    is_agent_event: false,
    non_personalized_ads: false,
    external_event_id: crypto.randomUUID(),
    label: EVENT_LABEL,
  };
  if (customerId) params.th_google_ads_customer_id = customerId;
  if (containerId) params.th_container_id = containerId;
  return {
    non_personalized_ads: true,
    client_id: crypto.randomUUID(),
    events: [{ name: EVENT_NAME, params }],
  };
};

/**
 * Sends the usage event if the user opted in and gave at least one valid ID.
 * Never throws.
 * @param {!object=} env Environment variables to read the settings from.
 * @param {function=} fetchFn The fetch implementation (injectable for tests).
 * @return {!Promise<{sent: boolean, reason: string}>} The outcome.
 */
const sendUsageEvent = async (env = process.env, fetchFn = globalThis.fetch) => {
  try {
    if (!isOptedIn(env.TELEMETRY_OPT_IN)) {
      return { sent: false, reason: 'not opted in' };
    }
    const customerId = normalizeCustomerId(env.GOOGLE_ADS_CUSTOMER_ID);
    const containerId = normalizeContainerId(env.GTM_CONTAINER_ID);
    if (!customerId && !containerId) {
      return {
        sent: false,
        reason: 'no valid Google Ads Customer ID or GTM container ID',
      };
    }
    if (typeof fetchFn !== 'function') {
      return { sent: false, reason: 'fetch is unavailable (Node.js 18+ is required)' };
    }
    const url =
      `${GA_COLLECT_URL}?api_secret=${encodeURIComponent(API_SECRET)}` +
      `&measurement_id=${encodeURIComponent(MEASUREMENT_ID)}`;
    const response = await fetchFn(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(buildPayload({ customerId, containerId })),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });
    if (!response || response.status < 200 || response.status >= 300) {
      return { sent: false, reason: `unexpected response status ${response && response.status}` };
    }
    return { sent: true, reason: 'ok' };
  } catch (error) {
    return { sent: false, reason: `request failed: ${error && error.message}` };
  }
};

module.exports = {
  isOptedIn,
  normalizeCustomerId,
  normalizeContainerId,
  buildPayload,
  sendUsageEvent,
};

if (require.main === module) {
  sendUsageEvent()
    .then(({ sent, reason }) => {
      console.log(sent ? 'Usage telemetry sent.' : `Usage telemetry skipped (${reason}).`);
    })
    .catch(() => {})
    .finally(() => {
      process.exitCode = 0;
    });
}
