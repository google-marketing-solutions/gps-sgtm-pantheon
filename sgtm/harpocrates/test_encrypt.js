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

const crypto = require('crypto');
const assert = require('assert');
const { performDecryption, decryptValue } = require('./index.js');

const ALGORITHM = 'aes-256-cbc';

// Generate a random 32-byte key and 16-byte IV
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);
const originalText = '999';

console.log(`Using Key: ${key.toString('hex')} and IV: ${iv.toString('hex')}`);

const performEncryption = (text, encKey, encIv) => {
  const cipher = crypto.createCipheriv(ALGORITHM, encKey, encIv);
  let encrypted = cipher.update(text, 'utf8', 'base64');
  encrypted += cipher.final('base64');
  return encrypted;
};

const encryptedText = performEncryption(originalText, key, iv);
const decryptedText = performDecryption(encryptedText, key, iv);

console.log('Original Text:', originalText);
console.log('Encrypted Text (Base64):', encryptedText);
console.log('Decrypted Text:', decryptedText);

assert.strictEqual(decryptedText, originalText, 'Decrypted text does not match original text!');

// --- HTTP Handler Regression Tests ---
process.env.DECRYPTION_KEY = key.toString('hex');
process.env.IV = iv.toString('hex');

const createMockRes = () => {
  const res = {
    headers: {},
    statusCode: 200,
    body: null,
    set(header, value) {
      this.headers[header] = value;
      return this;
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    send(payload) {
      this.body = payload;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };
  return res;
};

// 1. Rejects unauthenticated POST request (missing Authorization header) with 401
{
  const req = {
    method: 'POST',
    headers: {},
    body: { encryptedValue: encryptedText },
  };
  const res = createMockRes();
  decryptValue(req, res);
  assert.strictEqual(res.statusCode, 401, 'Expected 401 for missing Authorization header');
  assert.strictEqual(res.body, 'Unauthorized: missing Authorization header.');
}

// 2. Rejects empty Bearer token with 401
{
  const req = {
    method: 'POST',
    headers: { authorization: 'Bearer    ' },
    body: { encryptedValue: encryptedText },
  };
  const res = createMockRes();
  decryptValue(req, res);
  assert.strictEqual(res.statusCode, 401, 'Expected 401 for empty Bearer token');
}

// 3. Accepts authenticated POST request (including Cloud Run GFE lowercase 'bearer') and returns decrypted plaintext
{
  const req = {
    method: 'POST',
    headers: { authorization: 'bearer header.payload.SIGNATURE_REMOVED_BY_GOOGLE' },
    body: { encryptedValue: encryptedText },
  };
  const res = createMockRes();
  decryptValue(req, res);
  assert.strictEqual(res.statusCode, 200, 'Expected 200 for authenticated request');
  assert.deepStrictEqual(res.body, { decryptedValue: originalText });
  assert.strictEqual(res.headers['X-Content-Type-Options'], 'nosniff');
  assert.strictEqual(res.headers['Cache-Control'], 'no-store');
}

// 4. Handles OPTIONS preflight request and includes Authorization in Access-Control-Allow-Headers
{
  const req = {
    method: 'OPTIONS',
    headers: {},
  };
  const res = createMockRes();
  decryptValue(req, res);
  assert.strictEqual(res.statusCode, 204, 'Expected 204 for OPTIONS request');
  assert.ok(
    res.headers['Access-Control-Allow-Headers'].includes('Authorization'),
    'Access-Control-Allow-Headers must include Authorization'
  );
}

console.log('\nEncryption, decryption, and authentication handler tests passed!');
