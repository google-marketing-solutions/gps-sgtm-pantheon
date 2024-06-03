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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 03/06/2024, 15:07:08