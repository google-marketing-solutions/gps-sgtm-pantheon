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


___INFO___

{
  "type": "MACRO",
  "id": "cvt_aes_decryptor",
  "version": 1,
  "securityGroups": [],
  "displayName": "AES-256 Decryptor Variable",
  "description": "Takes an AES-256 encrypted value and sends it to an authenticated Google Cloud Function for decryption.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "projectId",
    "displayName": "Google Cloud Project ID",
    "help": "The ID of your Google Cloud project hosting the function.",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "cloudRegion",
    "displayName": "Cloud Function Region",
    "help": "The region where the Cloud Function is deployed (e.g., us-central1).",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "functionName",
    "displayName": "Cloud Function Name",
    "help": "The name of the deployed Cloud Function (e.g., decryptValue).",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "serviceAccountEmail",
    "displayName": "sGTM Service Account Email (Optional if deployed via deploy.sh)",
    "help": "The email address of the Google Cloud Service Account running your sGTM container. Automatically pre-populated when running deploy.sh.",
    "simpleValueType": true,
    "defaultValue": ""
  },
  {
    "type": "TEXT",
    "name": "encryptedValueEventData",
    "displayName": "Encrypted Value Event Data (Optional)",
    "help": "The encrypted value (or event data variable) to be decrypted. If left blank, automatically reads 'encryptedValueEventData' from incoming event data.",
    "simpleValueType": true,
    "defaultValue": ""
  },
  {
    "type": "TEXT",
    "name": "defaultValueOnError",
    "displayName": "Default Value",
    "help": "The value that should be returned if the decryption fails or an error occurs.",
    "simpleValueType": true,
    "defaultValue": ""
  }
]


___SANDBOXED_JS_FOR_SERVER___

const encodeUriComponent = require('encodeUriComponent');
const getEventData = require('getEventData');
const getGoogleAuth = require('getGoogleAuth');
const JSON = require('JSON');
const logToConsole = require('logToConsole');
const makeNumber = require('makeNumber');
const sendHttpRequest = require('sendHttpRequest');

// Populated automatically by deploy.sh when deploying the Cloud Function.
const DEFAULT_SERVICE_ACCOUNT_EMAIL = '';

// Build the URL for the decryption Cloud Function.
const url = 'https://' + data.cloudRegion + '-' + data.projectId + '.cloudfunctions.net/' + data.functionName;

const encryptedValue = data.encryptedValueEventData || getEventData('encryptedValueEventData');
const defaultValue = data.defaultValueOnError;
const serviceAccountEmail = data.serviceAccountEmail || DEFAULT_SERVICE_ACCOUNT_EMAIL;

// Ensure required parameters are provided.
if (!data.projectId || !data.cloudRegion || !data.functionName || !serviceAccountEmail || !encryptedValue) {
  logToConsole('Error: Project ID, Region, Function Name, Service Account Email, or Encrypted Value is not provided.');
  return defaultValue;
}

// Retrieve Google credentials from the service account running the sGTM container.
const auth = getGoogleAuth({
  scopes: ['https://www.googleapis.com/auth/cloud-platform']
});

// Step 1: Mint a Google-signed OIDC ID token with audience set to the Cloud Function URL.
const iamUrl = 'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/' +
  encodeUriComponent(serviceAccountEmail) + ':generateIdToken';
const iamPostBody = JSON.stringify({
  audience: url,
  includeEmail: true
});
const iamRequestOptions = {
  headers: {
    'Content-Type': 'application/json'
  },
  method: 'POST',
  authorization: auth
};

// Prepare the data to be sent to the Cloud Function.
const postBodyData = {
  encryptedValue: encryptedValue
};
const postBody = JSON.stringify(postBodyData);

return sendHttpRequest(iamUrl, iamRequestOptions, iamPostBody)
  .then(iamResponse => {
    if (iamResponse.statusCode < 200 || iamResponse.statusCode >= 300) {
      logToConsole('Failed to generate OIDC ID token with status code: ', iamResponse.statusCode);
      return defaultValue;
    }

    const iamResponseBody = JSON.parse(iamResponse.body);
    const idToken = iamResponseBody && iamResponseBody.token;
    if (!idToken) {
      logToConsole('Error: "token" key not found in IAM generateIdToken response.');
      return defaultValue;
    }

    // Step 2: Make the authenticated request to the decryption Cloud Function.
    const requestOptions = {
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + idToken
      },
      method: 'POST'
    };

    return sendHttpRequest(url, requestOptions, postBody)
      .then(response => {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          const responseBody = JSON.parse(response.body);
          // The Cloud Function should return a JSON object with a 'decryptedValue' key.
          if (responseBody && responseBody.decryptedValue !== undefined) {
            return makeNumber(responseBody.decryptedValue);
          }
          logToConsole('Error: "decryptedValue" key not found in response body.');
          return defaultValue;
        } else {
          logToConsole('Decryption request failed with status code: ', response.statusCode);
          return defaultValue;
        }
      });
  })
  .catch((error) => {
    logToConsole('Error calling decryption Cloud Function at ' + url + '. Error: ', error);
    return defaultValue;
  });


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "encryptedValueEventData"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://*.cloudfunctions.net/*"
              },
              {
                "type": 1,
                "string": "https://iamcredentials.googleapis.com/*"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "use_google_credentials",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedScopes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.googleapis.com/auth/cloud-platform"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Successful Decryption
  code: |
    const mockVariableData = {
      projectId: "my-gcp-project",
      cloudRegion: "us-central1",
      functionName: "sgtm-decryptor",
      serviceAccountEmail: "sgtm-sa@my-gcp-project.iam.gserviceaccount.com",
      encryptedValueEventData: "U2FsdGVkX1...",
      defaultValueOnError: "error_value"
    };

    mock('sendHttpRequest', (url, options, body) => {
      if (url.indexOf('https://iamcredentials.googleapis.com/') === 0) {
        const iamReq = JSON.parse(body);
        assertThat(iamReq.audience).isEqualTo("https://us-central1-my-gcp-project.cloudfunctions.net/sgtm-decryptor");
        return Promise.create((resolve) => {
          resolve({
            statusCode: 200,
            body: JSON.stringify({ token: "mock-oidc-id-token" })
          });
        });
      }

      assertThat(url).isEqualTo("https://us-central1-my-gcp-project.cloudfunctions.net/sgtm-decryptor");
      assertThat(options.headers.Authorization).isEqualTo("Bearer mock-oidc-id-token");
      const requestBody = JSON.parse(body);
      assertThat(requestBody.encryptedValue).isEqualTo("U2FsdGVkX1...");

      return Promise.create((resolve) => {
        resolve({
          statusCode: 200,
          body: JSON.stringify({ decryptedValue: "999" })
        });
      });
    });

    runCode(mockVariableData).then((result) => {
      assertThat(result).isEqualTo(999);
    });
- name: Failed Decryption (Server Error)
  code: |
    const mockVariableData = {
      projectId: "my-gcp-project",
      cloudRegion: "us-central1",
      functionName: "sgtm-decryptor",
      serviceAccountEmail: "sgtm-sa@my-gcp-project.iam.gserviceaccount.com",
      encryptedValueEventData: "U2FsdGVkX1...",
      defaultValueOnError: "error_value"
    };

    mock('sendHttpRequest', (url, options, body) => {
      if (url.indexOf('https://iamcredentials.googleapis.com/') === 0) {
        return Promise.create((resolve) => {
          resolve({
            statusCode: 200,
            body: JSON.stringify({ token: "mock-oidc-id-token" })
          });
        });
      }

      assertThat(url).isEqualTo("https://us-central1-my-gcp-project.cloudfunctions.net/sgtm-decryptor");
      return Promise.create((resolve) => {
        resolve({
          statusCode: 500,
          body: "Internal Server Error"
        });
      });
    });

    runCode(mockVariableData).then((result) => {
      assertThat(result).isEqualTo("error_value");
    });
- name: Failed Decryption (Invalid Response Body)
  code: |
    const mockVariableData = {
      projectId: "my-gcp-project",
      cloudRegion: "us-central1",
      functionName: "sgtm-decryptor",
      serviceAccountEmail: "sgtm-sa@my-gcp-project.iam.gserviceaccount.com",
      encryptedValueEventData: "U2FsdGVkX1...",
      defaultValueOnError: "error_value"
    };

    mock('sendHttpRequest', (url, options, body) => {
      if (url.indexOf('https://iamcredentials.googleapis.com/') === 0) {
        return Promise.create((resolve) => {
          resolve({
            statusCode: 200,
            body: JSON.stringify({ token: "mock-oidc-id-token" })
          });
        });
      }

      assertThat(url).isEqualTo("https://us-central1-my-gcp-project.cloudfunctions.net/sgtm-decryptor");
      return Promise.create((resolve) => {
        resolve({
          statusCode: 200,
          body: JSON.stringify({ wrongKey: "some_value" })
        });
      });
    });

    runCode(mockVariableData).then((result) => {
      assertThat(result).isEqualTo("error_value");
    });
- name: Failed Decryption (IAM Token Generation Error)
  code: |
    const mockVariableData = {
      projectId: "my-gcp-project",
      cloudRegion: "us-central1",
      functionName: "sgtm-decryptor",
      serviceAccountEmail: "sgtm-sa@my-gcp-project.iam.gserviceaccount.com",
      encryptedValueEventData: "U2FsdGVkX1...",
      defaultValueOnError: "error_value"
    };

    mock('sendHttpRequest', (url) => {
      assertThat(url).isEqualTo("https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/sgtm-sa%40my-gcp-project.iam.gserviceaccount.com:generateIdToken");
      return Promise.create((resolve) => {
        resolve({
          statusCode: 403,
          body: "Permission Denied"
        });
      });
    });

    runCode(mockVariableData).then((result) => {
      assertThat(result).isEqualTo("error_value");
    });
setup: |-
  const JSON = require('JSON');
  const Promise = require('Promise');
  mock('getGoogleAuth', () => ({}));
  mock('getEventData', () => '');


___NOTES___

v2: Added OIDC ID token authentication via getGoogleAuth and IAM Credentials API, and auto-fallback to getEventData('encryptedValueEventData').
v1: Initial release of the AES-256 Decryptor variable.
