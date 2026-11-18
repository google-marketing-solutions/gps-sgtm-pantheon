
___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Theia - Logging in Preview Mode \u0026 Cloud Logging",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Easily log custom messages to preview mode \u0026 Google Cloud Logging in sGTM",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "logTitle",
    "displayName": "Log Message Title",
    "simpleValueType": true,
    "defaultValue": "theia_sgtm_log",
    "help": "Logging to Cloud Logging is expensive so it is not recommended that you log all events. You can filter events that are logged in Cloud Logging based on keywords included in the log. Use this field to add a message at the beginning of each log."
  },
  {
    "type": "SELECT",
    "name": "logGrouping",
    "displayName": "Log Grouping",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "onePerRow",
        "displayValue": "One per row"
      },
      {
        "value": "groupLogs",
        "displayValue": "Group all rows into single logs"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "CHECKBOX",
    "name": "logIfNull",
    "checkboxText": "Log default if log is null",
    "simpleValueType": true
  },
  {
    "type": "SIMPLE_TABLE",
    "name": "logs",
    "displayName": "Logs",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Log Message",
        "name": "logMessage",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Default Message if Null",
        "name": "defaultMessage",
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
 * @fileoverview sGTM variable tag that uses data from Firestore to calculate a
 * new conversion value based on items in the datalayer.
 * @see {@link https://developers.google.com/analytics/devguides/collection/ga4/reference/events?client_type=gtag#purchase_item}
 * @version 3.0.0
 */

const logToConsole = require("logToConsole");

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
sendUsageTelemetry('theia');
// --- End of optional usage telemetry ---

const logs = data.logs;
  
if (data.logGrouping == "onePerRow") {
    
  for (let log of logs) {  
    if (log.logMessage) {
      logToConsole(data.logTitle + ": " + log.logMessage);
    }
    if (log.logMessage == "" & data.logIfNull) {
      logToConsole(data.logTitle + ": " + log.defaultMessage);
    }
  }
    
} else {
   
  let finalMessage = {};
  let filteredLogs = [];
  
  for (let log of logs) {
    if (log.logMessage) {
      filteredLogs.push(log.logMessage);
    }
    if (log.logMessage == "" & data.logIfNull) {
      filteredLogs.push(log.defaultMessage);
    }
  }
  finalMessage[data.logTitle] = filteredLogs;
  logToConsole(finalMessage);
    
}

// Call data.gtmOnSuccess when the tag is finished.
data.gtmOnSuccess();


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

Created on 06/02/2025, 16:28:20


