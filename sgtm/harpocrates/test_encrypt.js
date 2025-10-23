const crypto = require('crypto');
const assert = require('assert');
const { performDecryption } = require('./index.js');

const ALGORITHM = 'aes-256-cbc';

// Generate a random 32-byte key and 16-byte IV
const key = crypto.randomBytes(32);
const iv = crypto.randomBytes(16);
const originalText = "999";

console.log(`Using Key: ${key.toString('hex')} and IV: ${iv.toString('hex')}`);

const performEncryption = (text, key, iv) => {
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);
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

console.log('\nEncryption and decryption successful!');
