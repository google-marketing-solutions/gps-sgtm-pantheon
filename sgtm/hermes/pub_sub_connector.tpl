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
  },
  {
    "type": "GROUP",
    "name": "usageTelemetryGroup",
    "displayName": "Usage telemetry (optional)",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "shareUsageTelemetry",
        "checkboxText": "Share usage telemetry with Google",
        "simpleValueType": true,
        "help": "Off by default. If ticked, this template sends at most one usage event per day per server instance to Google. The event contains the solution name, this container\u0027s ID and, if entered below, your Google Ads Customer ID. No event data is ever sent."
      },
      {
        "type": "TEXT",
        "name": "telemetryGoogleAdsCustomerId",
        "displayName": "Google Ads Customer ID (optional, format XXX-XXX-XXXX)",
        "simpleValueType": true,
        "enablingConditions": [
          {
            "paramName": "shareUsageTelemetry",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
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

// --- Optional usage telemetry ---
// Off unless "Share usage telemetry with Google" is ticked. Sends at most one
// SOLUTION_USAGE event per day per server instance. It never includes event
// data, and a failure never affects the result of this template.
const telemetrySendHttpRequest = require('sendHttpRequest');
const telemetryStorage = require('templateDataStorage');
const telemetryGetContainerVersion = require('getContainerVersion');
const telemetryGenerateRandom = require('generateRandom');
const telemetryGetTimestampMillis = require('getTimestampMillis');
const telemetryJson = require('JSON');
const telemetryMakeString = require('makeString');
const sendUsageTelemetry = (solution) => {
  if (data.shareUsageTelemetry !== true) return;
  const storageKey = 'pantheon_usage_telemetry_' + solution;
  const now = telemetryGetTimestampMillis();
  const lastSent = telemetryStorage.getItemCopy(storageKey);
  if (lastSent && now - lastSent < 86400000) return;
  telemetryStorage.setItemCopy(storageKey, now);
  const randomId = () =>
    telemetryMakeString(now) + '.' + telemetryMakeString(telemetryGenerateRandom(100000000, 999999999));
  const params = {
    app: 'sGTM Pantheon',
    is_agent_event: false,
    non_personalized_ads: false,
    external_event_id: randomId(),
    label: solution,
  };
  const containerId = telemetryGetContainerVersion().containerId;
  if (containerId) params.th_container_id = telemetryMakeString(containerId);
  // External Customer IDs must keep their hyphens (XXX-XXX-XXXX).
  const customerId = telemetryMakeString(data.telemetryGoogleAdsCustomerId || '');
  let isCustomerId = customerId.length === 12;
  for (let i = 0; isCustomerId && i < 12; i++) {
    const character = customerId.charAt(i);
    isCustomerId = i === 3 || i === 7 ? character === '-' : '0123456789'.indexOf(character) >= 0;
  }
  if (isCustomerId) params.th_google_ads_customer_id = customerId;
  if (!params.th_container_id && !params.th_google_ads_customer_id) return;
  telemetrySendHttpRequest(
    'https://www.google-analytics.com/mp/collect?measurement_id=G-Z2TKLQZ79K&api_secret=S7toNnNZQPWzViq44q_8gg',
    {method: 'POST', headers: {'Content-Type': 'application/json'}, timeout: 2000},
    telemetryJson.stringify({
      client_id: randomId(),
      non_personalized_ads: true,
      events: [{name: 'SOLUTION_USAGE', params: params}],
    })
  ).then(() => {}, () => {});
};
sendUsageTelemetry('hermes');
// --- End of optional usage telemetry ---

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
              },
              {
                "type": 1,
                "string": "https://www.google-analytics.com/*"
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
        "publicId": "access_template_storage",
        "versionId": "1"
      },
      "param": []
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
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


