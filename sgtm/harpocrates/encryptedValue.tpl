___INFO___

{
  "type": "MACRO",
  "id": "cvt_aes_decryptor",
  "version": 1,
  "securityGroups": [],
  "displayName": "AES-256 Decryptor Variable",
  "description": "Takes an AES-256 encrypted value and sends it to a Google Cloud Function for decryption.",
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
    "help": "The name of the deployed Cloud Function (e.g., sgtm-decryptor).",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "encryptedValueEventData",
    "displayName": "Encrypted Value Event Data",
    "help": "The key in the event data that holds the encrypted value.",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
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

const JSON = require('JSON');
const logToConsole = require('logToConsole');
const sendHttpRequest = require('sendHttpRequest');
const makeNumber = require("makeNumber");

// Build the URL for the decryption Cloud Function.
const url = 'https://' + data.cloudRegion + '-' + data.projectId + '.cloudfunctions.net/' + data.functionName;

const encryptedValue = data.encryptedValueEventData;
const defaultValue = data.defaultValueOnError;

// Ensure required parameters are provided.
if (!data.projectId || !data.cloudRegion || !data.functionName || !encryptedValue) {
  logToConsole('Error: Project ID, Region, Function Name, or Encrypted Value is not provided.');
  return defaultValue;
}

// Prepare the data to be sent to the Cloud Function.
const postBodyData = {
  'encryptedValue': encryptedValue
};
const postBody = JSON.stringify(postBodyData);

// Set the request options.
const requestOptions = {
  headers: {
    'Content-Type': 'application/json'
  },
  method: 'POST'
};

// Make the request to the decryption Cloud Function.
return sendHttpRequest(url, requestOptions, postBody)
  .then(response => {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      const responseBody = JSON.parse(response.body);
      // The Cloud Function should return a JSON object with a 'decryptedValue' key.
      if (responseBody.decryptedValue !== undefined) {
        return makeNumber(responseBody.decryptedValue);
      }
      logToConsole('Error: "decryptedValue" key not found in response body.');
      return defaultValue;
    } else {
      logToConsole('Decryption request failed with status code: ', response.statusCode);
      return defaultValue;
    }
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
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "any"
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
      encryptedValueEventData: "U2FsdGVkX1...",
      defaultValueOnError: "error_value"
    };

    // Simulate a successful response from the Cloud Function
    mock('sendHttpRequest', (url, options, body) => {
      assertThat(url).isEqualTo("https://us-central1-my-gcp-project.cloudfunctions.net/sgtm-decryptor");
      const requestBody = JSON.parse(body);
      assertThat(requestBody.encryptedValue).isEqualTo("U2FsdGVkX1...");

      return Promise.create((resolve) => {
        resolve({
          statusCode: 200,
          body: JSON.stringify({ decryptedValue: "my_secret_value" })
        });
      });
    });

    runCode(mockVariableData).then((result) => {
      assertThat(result).isEqualTo("my_secret_value");
    });
- name: Failed Decryption (Server Error)
  code: |
    const mockVariableData = {
      projectId: "my-gcp-project",
      cloudRegion: "us-central1",
      functionName: "sgtm-decryptor",
      encryptedValueEventData: "U2FsdGVkX1...",
      defaultValueOnError: "error_value"
    };

    // Simulate a server error from the Cloud Function
    mock('sendHttpRequest', (url, options, body) => {
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
      encryptedValueEventData: "U2FsdGVkX1...",
      defaultValueOnError: "error_value"
    };

    // Simulate a successful response but with the wrong JSON key
    mock('sendHttpRequest', (url, options, body) => {
      assertThat(url).isEqualTo("https://us-central1-my-gcp-project.cloudfunctions.net/sgtm-decryptor");
      return Promise.create((resolve) => {
        resolve({
          statusCode: 200,
          body: JSON.stringify({ wrongKey: "some_value" }) // The key is not 'decryptedValue'
        });
      });
    });

    runCode(mockVariableData).then((result) => {
      assertThat(result).isEqualTo("error_value");
    });
setup: |-
  const JSON = require('JSON');
  const Promise = require('Promise');


___NOTES___

v1: Initial release of the AES-256 Decryptor variable.