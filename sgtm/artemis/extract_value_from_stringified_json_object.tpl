___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Artemis - Extract Value from Stringified JSON Object",
  "description": "Takes an input of Stringified JSON Object (e.g. a document from Firestore) and returns the value based on a given key.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "jsonString",
    "displayName": "Stringified JSON Object",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "key",
    "displayName": "Key",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "default",
    "displayName": "Default Value",
    "simpleValueType": true
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

const logToConsole = require("logToConsole");
const JSON = require("JSON");

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
sendUsageTelemetry('artemis_extract_value');
// --- End of optional usage telemetry ---

function getValueFromJSONString(jsonString, key) {
  
  // Attempt to parse the JSON string
  const parsedObject = JSON.parse(jsonString);

  // Check if parsing was successful
  if (parsedObject === undefined || parsedObject === null) {
    return "Error: Invalid JSON string";
  }

  // Check if the key exists in the parsed object
  if (parsedObject.hasOwnProperty(data.key)) {
    return parsedObject[key]; 
  } else {
    return data.default;
  }
  
}

//Entry point
return getValueFromJSONString(data.jsonString, data.key);


//Test to write: Mock invalid JSON should get error
//Check that you get value with key a:1
//Check that you get default if key doesn't exist


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

scenarios: []


___NOTES___

Created on 03/06/2024, 15:07:08