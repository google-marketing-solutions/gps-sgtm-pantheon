___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Pub/Sub Connector",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Send data in the inputs to Google Cloud Pub/sub",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "topicName",
    "displayName": "The name of the topic, e.g. projects/my-project-name/topics/topic-name",
    "simpleValueType": true
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "dataToSend",
    "displayName": "",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Key",
        "name": "key",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Value",
        "name": "value",
        "type": "TEXT"
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/**
 * @fileoverview sGTM tag to send data to Pub/Sub.
 * @version 1.0.0
 */
const getGoogleAuth = require("getGoogleAuth");
const JSON = require("JSON");
const logToConsole = require("logToConsole");
const makeTableMap = require("makeTableMap");
const makeInteger = require("makeInteger");
const makeNumber = require("makeNumber");
const makeString = require("makeString");
const sendHttpRequest = require("sendHttpRequest");
const toBase64 = require("toBase64");

const url = "https://pubsub.googleapis.com/v1/" + data.topicName + ":publish";

// Get Google credentials from the service account running the container.
const auth = getGoogleAuth({
  scopes: ["https://www.googleapis.com/auth/cloud-platform"]
});

// Helper function for determining if the string starts with a suffix.
const strEndsWith = (str, suffix) => {
  return str.indexOf(suffix, str.length - suffix.length) !== -1;
};

// Build an object containing the data to send to Pub/Sub
let pubSubMsg = {};
if (data.dataToSend){
  let pubSubData = makeTableMap(data.dataToSend, "key", "value");
  for (let key in pubSubData) {
    key = makeString(key);
    if (strEndsWith(key, "_int")) {
      const new_key = key.replace("_int", "");
      pubSubMsg[new_key] = makeInteger(pubSubData[key]);
    } else if (strEndsWith(key, "_num")) {
      const new_key = key.replace("_num", "");
      pubSubMsg[new_key] = makeNumber(pubSubData[key]);
    } else {
      pubSubMsg[key] = pubSubData[key];
    }
  }
  logToConsole(pubSubMsg);

  // The payload for VertexAI.
  const postBodyData = {
    "messages": [{
       "data": toBase64(JSON.stringify(pubSubMsg))
    }]
  };
  const postBody = JSON.stringify(postBodyData);

  const postHeaders = {
    "Content-Type": "application/json"
  };
  const requestOptions = {
    headers: postHeaders,
    method: "POST",
    authorization: auth
  };

  // Make the request to Pub/Sub & return the status code as the response.
  return sendHttpRequest(url, requestOptions, postBody)
    .then(success_result => {
      logToConsole("Status Code of the response: " + success_result.statusCode);
      if (success_result.statusCode >= 200 &&
          success_result.statusCode < 300) {
        logToConsole(JSON.stringify(success_result));
        data.gtmOnSuccess();
      }
      else {
        data.gtmOnFailure();
      }
    })
    .catch((error) => {
      logToConsole("Error with VertexAI call to " + url + ". Error: ", error);
      data.gtmOnFailure();
    });
}

data.gtmOnFailure();


___SERVER_PERMISSIONS___

[
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
                "string": "https://pubsub.googleapis.com/*"
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
  }
]


___TESTS___

scenarios:
- name: Successful test
  code: |
    const mockInputs = {
      topicName: "projects/my-project/topics/my-awesome-topic",
      dataToSend: [
        {"key": "transaction_id", "value": "abc-123"},
        {"key": "conversion_value", "value": "67.52"},
      ]
    };

    generateMockResponse(200, [123456]);

    runCode(mockInputs).then((resp) => {
      assertApi('gtmOnSuccess').wasCalled();
    });
- name: Error Test
  code: |
    const mockInputs = {
      topicName: "projects/my-project/topics/my-awesome-topic",
      dataToSend: [
        {"key": "transaction_id", "value": "abc-123"},
        {"key": "conversion_value", "value": "67.52"},
      ]
    };

    generateMockResponse(404, [123456]);

    runCode(mockInputs).then((resp) => {
      assertApi('gtmOnFailure').wasCalled();
    });
setup: |-
  const Promise = require("Promise");

  let pubSubResonse;

  /**
   * Build the mock response from Pub/Sub.
   * This method changes the global pubSubResonse variable, which is used in
   * the mock logic.
   * @param {number} statusCode - the status code to use in the VertexAI response.
   * @param {!Array<number>} messageIds - the messageIds in the response.
   */
  function generateMockResponse(statusCode, messageIds) {
    pubSubResonse = {
      "statusCode": statusCode,
      "body":"{\"messageIds\": [" + messageIds.join(', ') + "]}"
    };
  }

  // Change sendHttpRequest to return our mocked VertexAI response.
  mock("sendHttpRequest", () => {
    return Promise.create((resolve) => {
      resolve(pubSubResonse);
    });
  });


___NOTES___

Created on 12/11/2023, 11:02:46 AM


