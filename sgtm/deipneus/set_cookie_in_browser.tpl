___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Deipneus - Set Cookie in Browser",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Sets first-party cookies in the browser with customisable expiry dates.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SIMPLE_TABLE",
    "name": "cookiesToSet",
    "displayName": "Cookies To Set",
    "simpleTableColumns": [
      {
        "defaultValue": "",
        "displayName": "Name",
        "name": "name",
        "type": "TEXT",
        "isUnique": false,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "defaultValue": "",
        "displayName": "Value",
        "name": "value",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "Expiry (days)",
        "name": "expiryDays",
        "type": "TEXT",
        "valueValidators": [
          {
            "type": "NON_NEGATIVE_NUMBER"
          }
        ],
        "valueHint": "Use 0 for session cookie"
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY"
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
 * @fileoverview sGTM tag that writes data to the browser using 
 * cookies. Name, value, and expiry date are configurable by user.
 * @version 1.0.0
 */

const logToConsole = require('logToConsole');
const setCookie = require('setCookie');
const makeString = require('makeString');
const makeNumber = require('makeNumber');

if (data.cookiesToSet) {
  
  let cookies = data.cookiesToSet;
  
  // Loop through rows in tag and set cookies
  for (let cookie in cookies) {
    let name = makeString(cookies[cookie].name);
    let value = makeString(cookies[cookie].value);
    let expiryInDays = makeNumber(cookies[cookie].expiryDays);
    let expiryInSecond = cookies[cookie].expiryDays * 24 * 60 * 60;
    
    logToConsole(
      "Cookie set - Name: ", name, 
      "Value: ", value, 
      "Expiry in days:", expiryInDays,
      "Expiry in seconds:", expiryInSecond);
    
    setCookie(
      makeString(name), 
      makeString(cookies[cookie].value),
      {'domain': 'auto',
       'path': '/',
       'max-age': expiryInSecond}
    );
    
  }
  
} else {
  logToConsole("No cookies to set");
}

// Call data.gtmOnSuccess when the tag is finished.
data.gtmOnSuccess();


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
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
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Test cookies are set correctly
  code: |
    const mockData = {
      cookiesToSet: [
        {"name": "high-value", "value": "true", "expiryDays": "10"},
        {"name": "returning-customer", "value": "false", "expiryDays": "3"},
      ]
    };

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
    assertApi('setCookie').wasCalledWith(
      "high-value",
      "true",
      {
        "domain": "auto",
        "max-age": 10 * 24 * 60 * 60,
        "httpOnly": true
      }
    );
    assertApi('setCookie').wasCalledWith(
      "returning-customer",
      "false",
      {
        "domain": "auto",
        "max-age": 3 * 24 * 60 * 60,
        "httpOnly": true
      }
    );
- name: Test no cookies are set correctly
  code: |-
    const mockData = {
      cookiesToSet: []
    };

    runCode(mockData);

    assertApi('gtmOnSuccess').wasCalled();
    assertApi('setCookie').wasNotCalled();


___NOTES___

Created on 04/04/2024, 16:36:48


