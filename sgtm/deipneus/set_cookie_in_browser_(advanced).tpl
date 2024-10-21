___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Deipneus - Set Cookie in Browser (advanced)",
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
      },
      {
        "defaultValue": "",
        "displayName": "Path",
        "name": "path",
        "type": "TEXT"
      },
      {
        "defaultValue": "",
        "displayName": "httpOnly",
        "name": "httpOnly",
        "type": "SELECT",
        "selectItems": [
          {
            "value": "notSpecified",
            "displayValue": "Not Specified"
          },
          {
            "value": true,
            "displayValue": "True"
          },
          {
            "value": false,
            "displayValue": "False"
          }
        ]
      },
      {
        "defaultValue": "auto",
        "displayName": "Domain",
        "name": "domain",
        "type": "TEXT",
        "valueValidators": []
      }
    ],
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "advancedOptions",
    "displayName": "Advanced Options",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SELECT",
        "name": "samesite",
        "displayName": "Set samesite flag:",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "strict",
            "displayValue": "Strict"
          },
          {
            "value": "lax",
            "displayValue": "Lax"
          }
        ],
        "simpleValueType": true,
        "notSetText": "Not Set"
      },
      {
        "type": "CHECKBOX",
        "name": "secure",
        "checkboxText": "Set cookies using secure flag",
        "simpleValueType": true
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

    let options = {
      'max-age': expiryInSecond,
      'domain': cookies[cookie].domain,
    };
    
    if(cookies[cookie].httpOnly != "notSpecified") {
      options.httpOnly = cookies[cookie].httpOnly;
    }
    
    if(cookies[cookie].path) {
      options.path = cookies[cookie].path;
    }
    
    if(data.samesite == "strict" || data.samesite == "lax") {
      options.samesite = options.samesite;
    }
    
    if(data.secure) {
      options.secure = true;
    }
     
    logToConsole(
      "Cookie set - Name: ", name, 
      "Value: ", value, 
      "Expiry in days:", expiryInDays,
      "Expiry in seconds:", expiryInSecond,
      "Domain", cookies[cookie].domain,
      "httpOnly", cookies[cookie].httpOnly,
      "path", cookies[cookie].path,
      "samesite", data.samesite,
      "secure", data.secure);
    
    setCookie(
      makeString(name), 
      makeString(cookies[cookie].value),
      options
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


