
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


