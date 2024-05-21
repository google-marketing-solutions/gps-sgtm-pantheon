___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Extract Value from Stringified JSON Object",
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
  }
]


___SANDBOXED_JS_FOR_SERVER___

const logToConsole = require("logToConsole");
const JSON = require("JSON");

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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 22/03/2024, 15:03:21


