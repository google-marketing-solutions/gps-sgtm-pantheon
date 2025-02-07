___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Zeus - Container Monitoring Tag",
  "brand": {
    "id": "brand_dummy",
    "displayName": ""
  },
  "description": "Monitor tags in your server container and log results to preview mode, Cloud Logging and BigQuery",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "SELECT",
    "name": "monitoringMode",
    "displayName": "Monitoring mode",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "monitorAll",
        "displayValue": "Monitor all tags"
      },
      {
        "value": "monitorAllTagsExceptExcludedTags",
        "displayValue": "Monitor all tags except excluded tags"
      },
      {
        "value": "monitorNoTagsExceptIncludedTags",
        "displayValue": "Monitor only included tags"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "TEXT",
    "name": "filterKey",
    "displayName": "Tag metadata key",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "monitoringMode",
        "paramValue": "monitorAllTagsExceptExcludedTags",
        "type": "EQUALS"
      },
      {
        "paramName": "monitoringMode",
        "paramValue": "monitorNoTagsExceptIncludedTags",
        "type": "EQUALS"
      }
    ],
    "defaultValue": "tag_monitoring_status",
    "valueValidators": [
      {
        "type": "STRING_LENGTH",
        "args": [
          1,
          255
        ]
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "filterValue",
    "displayName": "Tag metadata value",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "monitoringMode",
        "paramValue": "monitorAllTagsExceptExcludedTags",
        "type": "EQUALS"
      },
      {
        "paramName": "monitoringMode",
        "paramValue": "monitorNoTagsExceptIncludedTags",
        "type": "EQUALS"
      }
    ],
    "defaultValue": "include/exclude",
    "valueValidators": [
      {
        "type": "STRING_LENGTH",
        "args": [
          1,
          255
        ]
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "logGrouping",
    "displayName": "Log grouping",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "oneLogPerEvent",
        "displayValue": "One log per event (tags grouped)"
      },
      {
        "value": "oneLogPerTag",
        "displayValue": "One log per tag"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "GROUP",
    "name": "actions",
    "displayName": "Actions",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "logToPreviewModeConsole",
        "checkboxText": "Log to console in preview mode only",
        "simpleValueType": true,
        "enablingConditions": []
      },
      {
        "type": "CHECKBOX",
        "name": "logToCloudLogging",
        "checkboxText": "Log to Cloud Logging",
        "simpleValueType": true,
        "enablingConditions": [],
        "help": "Note this will create a second console log in preview mode"
      },
      {
        "type": "CHECKBOX",
        "name": "logToBigQuery",
        "checkboxText": "Log to BigQuery",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "cloudLogging",
    "displayName": "Cloud Logging",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "cloudLoggingCustomMessage",
        "displayName": "cloudLoggingCustomMessage",
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "bigQuery",
    "displayName": "BigQuery",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "TEXT",
        "name": "projectId",
        "displayName": "Project ID",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "datasetId",
        "displayName": "Dataset ID",
        "simpleValueType": true
      },
      {
        "type": "TEXT",
        "name": "tableId",
        "displayName": "Table ID",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "logBigQuerySuccessToPreviewMode",
        "checkboxText": "Log BigQuery success to preview mode",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "logBigQueryErrorsToPreviewMode",
        "checkboxText": "Log BigQuery failures to preview mode",
        "simpleValueType": true
      },
      {
        "type": "CHECKBOX",
        "name": "flagFailureOnBigQueryError",
        "checkboxText": "Flat tag as failed if BigQuery returns error(s)",
        "simpleValueType": true
      }
    ]
  }
]


___SANDBOXED_JS_FOR_SERVER___

const addEventCallback = require('addEventCallback');
const bigQuery = require('BigQuery');
const getClientName = require('getClientName');
const getEventData = require('getEventData');
const getTimestampMillis = require('getTimestampMillis');
const JSON = require('JSON');
const logToConsole = require('logToConsole');

const eventData = getEventData();
const event_name = getEventData('event_name') || '';
const timestamp = getTimestampMillis();

// Add the event callback to the container instance
addEventCallback((containerId, eventData) => {
  
  let tagArray = [];
  
  //Filters tags based on tag monitoring settings
  if (data.monitoringMode == "monitorAll") {
    tagArray = eventData.tags.map(tag => ({
      id: tag.id,
      name: tag.name,
      status: tag.status,
      execustion_time: tag.executionTime
    }));
  } else if (data.monitoringMode == "monitorAllTagsExceptExcludedTags") {
    //Checks if tag meta data includes flag to include tags
    tagArray = eventData.tags.filter(tag => tag[data.filterKey] !== data.filterValue).map(tag => ({
      id: tag.id,
      name: tag.name,
      status: tag.status,
      execustion_time: tag.executionTime
    }));
  } else if (data.monitoringMode == "monitorNoTagsExceptIncludedTags") {
    //Checks if tag meta data includes flag to include tag
    tagArray = eventData.tags.filter(tag => tag[data.filterKey] == data.filterValue).map(tag => ({
      id: tag.id,
      name: tag.name,
      status: tag.status,
      execustion_time: tag.executionTime
    }));
  }
  
  const event = {
    event_name: event_name,
    event_timestamp: timestamp,
    client_name: getClientName(),
    tag: tagArray,
  };
  
  //Log to Preview Mode
  if (data.logToPreviewModeConsole) {
    
    if(data.logGrouping == "oneLogPerEvent") {
      logToConsole(event);
    } else {
      logToConsole(eventData.tags);
      for (let tag of event.tag) {
        logToConsole("event_name: " + event_name + "; event_timestamp: " + timestamp + "; client_name: " + getClientName() + "; tag: " + JSON.stringify(tag));
      }
    }
    
  }
  
  //Log to Cloud Logging
  if (data.logToCloudLogging) {
    let log = {}; 
    if(data.logGrouping == "oneLogPerEvent") {
      log[data.cloudLoggingCustomMessage] = event;
      logToConsole(JSON.stringify(log));
    } else {
      logToConsole(eventData.tags);
      for (let tag of event.tag) {
        logToConsole(data.cloudLoggingCustomMessage + ": event_name: " + event_name + "; event_timestamp: " + timestamp + "; client_name: " + getClientName() + "; tag: " + JSON.stringify(tag));
      }
    }
    
  }
  
  //Send data to BigQuery  
  if (data.logToBigQuery) {
    
     if(data.logGrouping == "oneLogPerEvent") {
      bigQuery.insert({
        projectId: data.projectId,
        datasetId: data.datasetId,
        tableId: data.tableId,
      }, [event], {}, () => {
        if(data.logBigQuerySuccessToPreviewMode) {
          logToConsole("BigQuery: Success", event);
        }
      }, (errors) => {
        if(data.logBigQueryErrorsToPreviewMode) {
          logToConsole('BigQuery Error: ', JSON.stringify(errors));
          if(data.flagFailureOnBigQueryError) {
            data.gtmOnFailure();
          }
        }
      });
    } else {
      let bigQueryErrors = "BigQuery Errors: ";
      for (let tag of event.tag) {
        
        let row = {
          event_name: event_name,
          event_timestamp: timestamp,
          client_name: getClientName(),
          tag: [tag],
        };
        
        bigQuery.insert({
          projectId: data.projectId,
          datasetId: data.datasetId,
          tableId: data.tableId,
        }, [row], {}, () => {
          if(data.logBigQuerySuccessToPreviewMode) {
            logToConsole("BigQuery: Success", row);
          }
        }, (errors) => {
          bigQueryErrors +=  JSON.stringify(errors);
          data.gtmOnFailure();
          }
        );
        
      }
      
      if(data.logBigQueryErrorsToPreviewMode & bigQueryErrors != "BigQuery Errors: ") {
        logToConsole(bigQueryErrors);
      }
      
    }
    
  }
  
});

// Always signal success, as the tag completes actually only after eventCallback.
data.gtmOnSuccess();


___SERVER_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_event_metadata",
        "versionId": "1"
      },
      "param": []
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
            "string": "all"
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
        "publicId": "read_container_data",
        "versionId": "1"
      },
      "param": []
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
                    "string": "gps-asa-uk-sgtm-demo-account"
                  },
                  {
                    "type": 1,
                    "string": "gps_asa_uk_sgtm_demo_account_example_data"
                  },
                  {
                    "type": 1,
                    "string": "zeus_container_monitor"
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

Created on 07/02/2025, 12:51:11


