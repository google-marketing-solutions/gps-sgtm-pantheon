
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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 06/02/2025, 16:28:20


