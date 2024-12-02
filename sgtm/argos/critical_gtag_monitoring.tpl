___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Argos - Critical gTag Monitoring",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Monitor critical gTag settings. Optionally log errors in the console, GA4, BigQuery, and Cloud Logging.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "expectedDomains",
    "displayName": "Expected Domains",
    "simpleValueType": true,
    "help": "Comma-separated list of the domains you expect to see sending data to your server-side container. If left blank the tag will not check the domain.",
    "valueValidators": []
  },
  {
    "type": "TEXT",
    "name": "expectedCountries",
    "displayName": "Expected Countries",
    "simpleValueType": true,
    "help": "Comma-separated list of the countries you expect to see sending data to your server-side container. Country codes use ISO-3166-1 alpha-2 format. If left blank the tag will not check the country."
  },
  {
    "type": "TEXT",
    "name": "expectedGAMeasurmentIds",
    "displayName": "Expected GA Measurment IDs",
    "simpleValueType": true,
    "help": "Comma-separated list of the GA Measurement IDs you expect to see firing on your site. If left blank the tag will not check the GA4 measurement IDs."
  },
  {
    "type": "SELECT",
    "name": "expectedDMAValues",
    "displayName": "Expected DMA parameter value",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "\"0\"",
        "displayValue": "0"
      },
      {
        "value": "\"1\"",
        "displayValue": "1"
      },
      {
        "value": "any",
        "displayValue": "Any"
      }
    ],
    "simpleValueType": true,
    "help": "DMA \u003d 1 is expected for EEA traffic and 0 for non-EEA traffic."
  },
  {
    "type": "TEXT",
    "name": "expectedGCSValues",
    "displayName": "Expected GCS Values",
    "simpleValueType": true,
    "help": "Comma-separated list of the GCS values you expect to see from your tag. Allowed values are: G100, G101, G110, and G111. If left blank the tag will not check the GCS values."
  },
  {
    "type": "GROUP",
    "name": "actions",
    "displayName": "Actions",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "logToConsoleIfError",
        "checkboxText": "Log to console in preview mode when there is an error",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "logToConsoleIfNoError",
        "checkboxText": "Log to console in preview mode even with no error",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "sendGa4Event",
        "checkboxText": "Send error event to GA4",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "logToBigQuery",
        "checkboxText": "Log request and error to BigQuery",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "logToCloudLogging",
        "checkboxText": "Log request and error to Cloud Logging",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "ga4Details",
    "displayName": "GA4 Details",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "ga4MeasurementId",
        "displayName": "GA4 Measurement ID",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "REGEX",
            "args": [
              "G-[A-Z0-9]+"
            ]
          },
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "ga4eventName",
        "displayName": "Event Name",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "STRING_LENGTH",
            "args": [
              1,
              40
            ]
          }
        ]
      },
      {
        "type": "CHECKBOX",
        "name": "sendErrorToGA4CustomDimension",
        "checkboxText": "Send error text to custom dimension",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "ga4CustomDimensionName",
        "displayName": "Custom dimension name",
        "simpleValueType": true,
        "enablingConditions": [
          {
            "paramName": "sendErrorToGA4CustomDimension",
            "paramValue": true,
            "type": "EQUALS"
          }
        ],
        "valueValidators": [
          {
            "type": "STRING_LENGTH",
            "args": [
              1,
              40
            ]
          }
        ]
      }
    ],
    "enablingConditions": [
      {
        "paramName": "sendGa4Event",
        "paramValue": true,
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "bigQueryDetails",
    "displayName": "BigQuery Details",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "bigQueryProjectId",
        "displayName": "Google Cloud Platform project ID",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "bigQueryDatasetID",
        "displayName": "Dataset ID",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "bigQueryTableId",
        "displayName": "Table ID",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "requestStringColumnName",
        "displayName": "Request string column name",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "errorMessageColumnName",
        "displayName": "Error message column name",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "addTimestamp",
        "checkboxText": "Insert timestamp column",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "timestampColumnName",
        "displayName": "Timestamp column name",
        "simpleValueType": true,
        "enablingConditions": [
          {
            "paramName": "addTimestamp",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
      }
    ],
    "enablingConditions": [
      {
        "paramName": "logToBigQuery",
        "paramValue": true,
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "cloudLoggingDetails",
    "displayName": "Cloud Logging Details",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "customCloudLoggingMessage",
        "displayName": "Custom Cloud Logging Message",
        "simpleValueType": true,
        "defaultValue": "sGTM Pantheon Argos gTag Error"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "logToCloudLogging",
        "paramValue": true,
        "type": "EQUALS"
      }
    ],
    "help": "sGTM console logs are automatically sent to Google Cloud Logging unless disabled. This section allows you to add a custom error message to the start of the log to allow you to filter these logs in Logging as required. Instructions on how to enable and disable specific logs can be found here: https://developers.google.com/tag-platform/tag-manager/server-side/cloud-run-setup-guide?provisioning\u003dmanual#console-logging"
  }
]


___SANDBOXED_JS_FOR_SERVER___

//Required Libraries
const getEventData = require("getEventData");
const getAllEventData = require("getAllEventData");
const getRequestQueryString = require('getRequestQueryString');
const logToConsole = require("logToConsole");
const sendEventToGoogleAnalytics = require("sendEventToGoogleAnalytics");
const bigQuery = require("BigQuery");
const getTimestampMillis = require("getTimestampMillis");
const JSON = require("JSON");
const makeString = require("makeString");

//Helper function to check if input is in a comma-separated list
function isValueInList(listString, valueToCheck) {
  if (listString === "") {
    return false; 
  }
  const values = listString.split(",")
    .map(value => value.trim()); 

  // Iterate over the array and compare each value
  for (let i = 0; i < values.length; i++) {
    if (values[i] === valueToCheck.trim()) { 
      return true; // Value found
    }
  }
  return false; // Value not found
}

//Helper function to extract domain from url
function extractDomain(url) {
    const urlWithoutProtocol = url.replace("https://", "");
    const domain = urlWithoutProtocol.split('/')[0];
    return domain;
}
                           
//Get event & request data
let event = getAllEventData();
let request = getRequestQueryString();

//Set up variables to track errors
let errorMessage = "Errors: ";
let shortErrorMessage = "";
let numErrors = 0;

//Check domains
if(data.expectedDomains) {
  const requestDomain = extractDomain(getEventData("page_referrer"));
  if(!isValueInList(data.expectedDomains, requestDomain)) {
    errorMessage += "Request sent by unlisted domain. Expected: " + data.expectedDomains + " but got " + requestDomain + ". ";
    shortErrorMessage += "domains;";
    numErrors++;
  }
}

//Check expected countries
if(data.expectedCountries) {
  const requestCountry = extractDomain(getEventData("event_location.country"));
  if(!isValueInList(data.expectedCountries, requestCountry)) {
    errorMessage += "Request sent by unlisted country. Expected: " + data.expectedCountries + " but got " + requestCountry + ". ";
    shortErrorMessage += "countries;";
    numErrors++;
  }
}

//Check expected GA measurement IDs
if(data.expectedGAMeasurmentIds) {
  const requestGaMeasurementId = extractDomain(getEventData("x-ga-measurement_id"));
  if(!isValueInList(data.expectedGAMeasurmentIds, requestGaMeasurementId)) {
    errorMessage += "Request sent by unlisted GA4 Measurement ID. Expected: " + data.expectedGAMeasurmentIds + " but got " + requestGaMeasurementId + ". ";
    shortErrorMessage += "ga4measurmentIds;";
    numErrors++;
  }
}

//Check expected DMA parameter value
if(data.expectedDMAValues != "any") {
  const requestDMAParameterValue = extractDomain(getEventData("x-ga-dma"));
  let expectedDMAValue;
  if (data.expectedDMAValues == '\"0\"') {
    expectedDMAValue = 0;
  } else {
    expectedDMAValue = 1;
  }
  if(expectedDMAValue != requestDMAParameterValue) {
    errorMessage += "Request included unexpected DMA Parameter Value. Expected: " + expectedDMAValue + " but got " + requestDMAParameterValue + ". ";
    shortErrorMessage += "dmaParameter;";
    numErrors++;
  }
}

//Check expected GCS values
if(data.expectedGCSValues) {
  const requestGCSValue = extractDomain(getEventData("x-ga-gcs"));
  if(!isValueInList(data.expectedGCSValues, requestGCSValue)) {
    errorMessage += "Request included unexpected GCS Value. Expected: " + data.expectedGCSValues + " but got " + requestGCSValue + ". ";
    shortErrorMessage += "gcsValue;";
    numErrors++;
  }
}

//Actions
//Log to console if there is an error
if(data.logToConsoleIfError && numErrors > 0) {
  logToConsole(errorMessage);
}

//Log to console even without an error
if(data.logToConsoleIfNoError && numErrors == 0) {
  logToConsole("No errors found.");
}

//Send event to GA4, overriding GA measurement ID and event name
if(data.sendGa4Event && numErrors > 0) {
  let errorEvent = event;
  errorEvent["x-ga-measurement_id"] = data.ga4MeasurementId;
  errorEvent["event_name"] = data.ga4eventName;
  if(data.sendErrorToGA4CustomDimension && data.ga4CustomDimensionName) {
    errorEvent[data.ga4CustomDimensionName] = shortErrorMessage;
  }
  sendEventToGoogleAnalytics(errorEvent).then((response) => {
    data.gtmOnSuccess();
  }).catch((error) => {
    logToConsole(error.reason);
    data.gtmOnFailure();
  });
}

//Log to BiqQuery
if(data.logToBigQuery && numErrors > 0) {

  //Create object to insert into BigQuery
  let bigQueryData = {};
  if(data.addTimestamp) {
    bigQueryData[data.timestampColumnName] = getTimestampMillis() / (10 ^ 6);
  }
  bigQueryData[data.requestStringColumnName] = makeString(request);
  bigQueryData[data.errorMessageColumnName] = errorMessage;
  
  //Send data to BigQuery  
  bigQuery.insert({
    projectId: data.bigQueryProjectId,
    datasetId: data.bigQueryDatasetID,
    tableId: data.bigQueryTableId,
  }, [bigQueryData], {}, () => {
    logToConsole('BigQuery Success: ', [bigQueryData]);
  }, (errors) => {
    logToConsole('BigQuery Failure: ', JSON.stringify(errors));
    data.gtmOnFailure();
  });
}

//Log to Cloud Logging using custom Error Message
if(data.logToCloudLogging && numErrors > 0) {
  logToConsole(data.customCloudLoggingMessage + '; Request: ' + request + '; ' + errorMessage);
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
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_event_data",
        "versionId": "1"
      },
      "param": [
        {
          "key": "eventDataAccess",
          "value": {
            "type": 1,
            "string": "any"
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
        "publicId": "read_request",
        "versionId": "1"
      },
      "param": [
        {
          "key": "requestAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "headerAccess",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queryParameterAccess",
          "value": {
            "type": 1,
            "string": "any"
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
          "key": "allowGoogleDomains",
          "value": {
            "type": 8,
            "boolean": true
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
        "publicId": "access_bigquery",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedTables",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "projectId"
                  },
                  {
                    "type": 1,
                    "string": "datasetId"
                  },
                  {
                    "type": 1,
                    "string": "tableId"
                  },
                  {
                    "type": 1,
                    "string": "operation"
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
                    "string": "write"
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
  }
]


___TESTS___

scenarios: []


___NOTES___

Created on 02/12/2024, 10:03:10


