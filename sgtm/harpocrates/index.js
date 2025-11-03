/**
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * Google Cloud Function to decrypt an AES-256-CBC encrypted string.
 * This file contains the main handler for the HTTP request and the core decryption logic.
 *
 * @param {!object} req The HTTP request object.
 * @param {!object} res The HTTP response object.
 */
const crypto = require('crypto');

// The encryption algorithm to use. Must match the algorithm used for encryption.
const ALGORITHM = 'aes-256-cbc';

/**
 * Performs the actual AES-26 decryption.
 * @param {string} encryptedTextHex The encrypted string in hexadecimal format.
 * @param {!Buffer} key The 32-byte (256-bit) decryption key.
 * @param {!Buffer} iv The 16-byte (128-bit) initialization vector.
 * @return {string} The decrypted plaintext string.
 * @throws {Error} Throws an error if decryption fails.
 */
const performDecryption = (encryptedTextHex, key, iv) => {
  const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
  // Assuming the encrypted value is sent in base64 format.
  let decrypted = decipher.update(encryptedTextHex, 'base64', 'utf8');
  decrypted += decipher.final('utf8');
  return decrypted;
};

/**
 * Handles the HTTP request, validates inputs, and calls the decryption logic.
 * @param {!object} req The HTTP request object from Cloud Functions.
 * @param {!object} res The HTTP response object from Cloud Functions.
 * @return {void}
 */
exports.decryptValue = (req, res) => {
  // --- 1. Set CORS headers for preflight requests and allow sGTM requests ---
  res.set('Access-Control-Allow-Origin', '*'); // For production, restrict this to your sGTM domain.
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    // Handle preflight CORS request.
    return res.status(204).send('');
  }

  // --- 2. Ensure the request method is POST ---
  if (req.method !== 'POST') {
    return res.status(405).send('Method Not Allowed');
  }

  // --- 3. Retrieve secrets from environment variables ---
  const keyHex = process.env.DECRYPTION_KEY;
  const ivHex = process.env.IV;

  if (!keyHex || !ivHex) {
    console.error('DECRYPTION_KEY or IV environment variables are not set.');
    return res.status(500).send('Server configuration error.');
  }

  // The key must be 32 bytes (64 hex characters) and the IV 16 bytes (32 hex characters).
  if (keyHex.length !== 64 || ivHex.length !== 32) {
    console.error('Invalid key or IV length. Key must be 64 hex chars, IV must be 32.');
    return res.status(500).send('Server configuration error: Invalid key length.');
  }

  const key = Buffer.from(keyHex, 'hex');
  const iv = Buffer.from(ivHex, 'hex');

  // --- 4. Get the encrypted value from the request body ---
  const encryptedValue = req.body.encryptedValue;

  if (!encryptedValue) {
    return res.status(400).send('Bad Request: "encryptedValue" is missing from the request body.');
  }

  // --- 5. Call the decryption logic and handle the response ---
  try {
    const decryptedText = performDecryption(encryptedValue, key, iv);

    // Send the successful response
    res.status(200).json({
      decryptedValue: decryptedText
    });

  } catch (error) {
    console.error('Decryption failed:', error.message);
    res.status(500).send('Internal Server Error: Decryption failed. Check if the encrypted value is correct.');
  }
};

exports.performDecryption = performDecryption;


