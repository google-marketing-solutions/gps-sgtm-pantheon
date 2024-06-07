___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Dioscuri - Get Gemini Response",
  "description": "Variable which returns the response from Gemini 1.0 Pro or 1.5 Pro.",
  "containerContexts": [
    "SERVER"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "projectID",
    "displayName": "Google Cloud Project",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "cloudLocation",
    "displayName": "Cloud region where the Vertex AI model is deployed",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "geminiModel",
    "displayName": "Gemini Model",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "gemini-1.5-pro",
        "displayValue": "Gemini 1.5 Pro"
      },
      {
        "value": "gemini-1.0-pro",
        "displayValue": "Gemini 1.0 Pro"
      }
    ],
    "simpleValueType": true
  },
  {
    "type": "GROUP",
    "name": "textPrompts",
    "displayName": "Text Prompts",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "textPromptData",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "Text Prompts",
            "name": "text",
            "type": "TEXT"
          }
        ],
        "newRowButtonText": "Add prompt"
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "filePrompts",
    "displayName": "File Prompts",
    "groupStyle": "NO_ZIPPY",
    "subParams": [
      {
        "type": "SIMPLE_TABLE",
        "name": "filePromptData",
        "displayName": "",
        "simpleTableColumns": [
          {
            "defaultValue": "",
            "displayName": "File Cloud Storage URL",
            "name": "fileUrl",
            "type": "TEXT",
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ],
            "isUnique": true
          },
          {
            "defaultValue": "",
            "displayName": "File Type",
            "name": "mimeType",
            "type": "SELECT",
            "selectItems": [
              {
                "value": "application/pdf",
                "displayValue": "application/pdf"
              },
              {
                "value": "audio/mpeg",
                "displayValue": "audio/mpeg"
              },
              {
                "value": "audio/mp3",
                "displayValue": "audio/mp3"
              },
              {
                "value": "audio/wav",
                "displayValue": "audio/wav"
              },
              {
                "value": "image/png",
                "displayValue": "image/png"
              },
              {
                "value": "image/jpeg",
                "displayValue": "image/jpeg"
              },
              {
                "value": "text/plain",
                "displayValue": "text/plain"
              },
              {
                "value": "video/mov",
                "displayValue": "video/mov"
              },
              {
                "value": "video/mpeg",
                "displayValue": "video/mpeg"
              },
              {
                "value": "video/mp4",
                "displayValue": "video/mp4"
              },
              {
                "value": "video/mpg",
                "displayValue": "video/mpg"
              },
              {
                "value": "video/avi",
                "displayValue": "video/avi"
              },
              {
                "value": "video/wmv",
                "displayValue": "video/wmv"
              },
              {
                "value": "video/mpegps",
                "displayValue": "video/mpegps"
              },
              {
                "value": "video/flv",
                "displayValue": "video/flv"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              }
            ]
          }
        ],
        "newRowButtonText": "Add file"
      }
    ],
    "enablingConditions": [
      {
        "paramName": "geminiModel",
        "paramValue": "gemini-1.5-pro",
        "type": "EQUALS"
      }
    ]
  },
  {
    "type": "TEXT",
    "name": "systemInstruction",
    "displayName": "System Instruction",
    "simpleValueType": true,
    "help": "Instructions for the model to steer it toward better performance. For example, \"Answer as concisely as possible\" or \"Don\u0027t use technical terms in your response\"."
  },
  {
    "type": "TEXT",
    "name": "defaultValueOnError",
    "displayName": "The value that should be returned if an error occurs",
    "simpleValueType": true,
    "defaultValue": 0
  },
  {
    "type": "GROUP",
    "name": "safetySettings",
    "displayName": "Safety Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "SELECT",
        "name": "sexuallyExplicit",
        "displayName": "Sexually explicit",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "BLOCK_NONE",
            "displayValue": "Block none"
          },
          {
            "value": "BLOCK_LOW_AND_ABOVE",
            "displayValue": "Block low and above"
          },
          {
            "value": "BLOCK_MED_AND_ABOVE",
            "displayValue": "Block medium and above"
          },
          {
            "value": "BLOCK_ONLY_HIGH",
            "displayValue": "Block only high"
          }
        ],
        "simpleValueType": true
      },
      {
        "type": "SELECT",
        "name": "hateSpeech",
        "displayName": "Hate Speech",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "BLOCK_NONE",
            "displayValue": "Block none"
          },
          {
            "value": "BLOCK_LOW_AND_ABOVE",
            "displayValue": "Block low and above"
          },
          {
            "value": "BLOCK_MED_AND_ABOVE",
            "displayValue": "Block medium and above"
          },
          {
            "value": "BLOCK_ONLY_HIGH",
            "displayValue": "Block only high"
          }
        ],
        "simpleValueType": true
      },
      {
        "type": "SELECT",
        "name": "harassment",
        "displayName": "Harassment",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "BLOCK_NONE",
            "displayValue": "Block none"
          },
          {
            "value": "BLOCK_LOW_AND_ABOVE",
            "displayValue": "Block low and above"
          },
          {
            "value": "BLOCK_MED_AND_ABOVE",
            "displayValue": "Block medium and above"
          },
          {
            "value": "BLOCK_ONLY_HIGH",
            "displayValue": "Block only high"
          }
        ],
        "simpleValueType": true
      },
      {
        "type": "SELECT",
        "name": "dangerousContent",
        "displayName": "Dangerous Content",
        "macrosInSelect": false,
        "selectItems": [
          {
            "value": "BLOCK_NONE",
            "displayValue": "Block none"
          },
          {
            "value": "BLOCK_LOW_AND_ABOVE",
            "displayValue": "Block low and above"
          },
          {
            "value": "BLOCK_MED_AND_ABOVE",
            "displayValue": "Block medium and above"
          },
          {
            "value": "BLOCK_ONLY_HIGH",
            "displayValue": "Block only high"
          }
        ],
        "simpleValueType": true
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "generationConfig",
    "displayName": "Generation Config (Optional)",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "temperature",
        "displayName": "Temperature",
        "simpleValueType": true,
        "defaultValue": 1,
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "help": "Must be between 0 and 2. The temperature is used for sampling during response generation, which occurs when topP and topK are applied. Temperature controls the degree of randomness in token selection. Lower temperatures are good for prompts that require a less open-ended or creative response, while higher temperatures can lead to more diverse or creative results. A temperature of 0 means that the highest probability tokens are always selected. In this case, responses for a given prompt are mostly deterministic, but a small amount of variation is still possible."
      },
      {
        "type": "TEXT",
        "name": "maxOutputTokens",
        "displayName": "Max Output Tokens",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "NUMBER"
          },
          {
            "type": "NON_EMPTY"
          }
        ],
        "defaultValue": 100,
        "help": "Maximum number of tokens that can be generated in the response. A token is approximately four characters. 100 tokens correspond to roughly 60-80 words."
      },
      {
        "type": "TEXT",
        "name": "topP",
        "displayName": "Top-P",
        "simpleValueType": true,
        "valueValidators": [
          {
            "type": "DECIMAL"
          },
          {
            "type": "NON_EMPTY"
          }
        ],
        "defaultValue": 0.94,
        "help": "Top-P changes how the model selects tokens for output. Tokens are selected from the most (see top-K) to least probable until the sum of their probabilities equals the top-P value. For example, if tokens A, B, and C have a probability of 0.3, 0.2, and 0.1 and the top-P value is 0.5, then the model will select either A or B as the next token by using temperature and excludes C as a candidate."
      },
      {
        "type": "TEXT",
        "name": "frequencyPenalty",
        "displayName": "Frequency Penalty",
        "simpleValueType": true,
        "defaultValue": 1,
        "help": "Positive values penalize tokens that repeatedly appear in the generated text, decreasing the probability of repeating content.  This maximum value for frequencyPenalty is up to, but not including, 2.0. Its minimum value is -2.0.",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "presencePenalty",
        "displayName": "Presence Penalty",
        "simpleValueType": true,
        "defaultValue": 1,
        "help": "Positive values penalize tokens that already appear in the generated text, increasing the probability of generating more diverse content. This maximum value for presencePenalty is up to, but not including, 2.0. Its minimum value is -2.0.",
        "valueValidators": [
          {
            "type": "NON_EMPTY"
          }
        ],
        "enablingConditions": [
          {
            "paramName": "geminiModel",
            "paramValue": "gemini-1.5-pro",
            "type": "EQUALS"
          }
        ]
      },
      {
        "type": "TEXT",
        "name": "stopSequences",
        "displayName": "Stop Sequences",
        "simpleValueType": true,
        "help": "Specifies a list of strings that tells the model to stop generating text if one of the strings is encountered in the response. If a string appears multiple times in the response, then the response truncates where it\u0027s first encountered. The strings are case-sensitive.",
        "valueValidators": [
          {
            "type": "REGEX",
            "args": [
              "[a-z]+(?:, +?[a-z]+){0,4}"
            ],
            "errorMessage": "Must be a comma-separated list containing a maximum of five words"
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
 * @fileoverview sGTM variable tag that makes a call to Gemini API
 * @version 1.0.0
 */
const getGoogleAuth = require("getGoogleAuth");
const JSON = require("JSON");
const logToConsole = require("logToConsole");
const sendHttpRequest = require("sendHttpRequest");

//Function to convert string of words to array of strings
function splitAndTrim(commaSeparatedString) {
  commaSeparatedString = "hello, goodbye";
  const words = commaSeparatedString.split(',');
  const trimmedWords = []; 
  for (let i = 0; i < words.length; i++) {
    trimmedWords.push(words[i].trim()); // Trim and add to new array
  }
  return trimmedWords;
}

// Build the URL for Vertex AI.
const url = "https://" + data.cloudLocation + 
  "-aiplatform.googleapis.com/v1/projects/" + data.projectID + 
  "/locations/" + data.cloudLocation + "/publishers/google/models/" + 
  data.geminiModel + ":generateContent";

logToConsole(url);

// Get Google credentials from the service account running the container.
const auth = getGoogleAuth({
  scopes: ["https://www.googleapis.com/auth/cloud-platform"]
});

// Create parts object which contains text and file prompts
logToConsole(data);
const parts = [];

if (data.textPromptData) {
  data.textPromptData.forEach((textPrompt) => {
    parts.push({"text": textPrompt.text});
  });
}


if (data.filePromptData && data.geminiModel == "gemini-1.5-pro") {
  data.filePromptData.forEach((filePrompt) => {
    parts.push({"fileData": {
      "fileUri": filePrompt.fileUrl,
      "mimeType": filePrompt.mimeType
    }});
  });
}

if (parts.length == 0) {
  logToConsole("At least one prompt must be supplied");
  //data.gtmOnFailure();
}

// The payload for VertexAI Gemini
const postBodyData = {
  "contents": [
    {
      "role": "USER",
      "parts": parts 
    }
  ],
  "systemInstruction": {
    "role": "USER",
    "parts": [
      {
        "text": data.systemInstruction
      }
    ]
  },
  "safetySettings": [
    {
      "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
      "threshold": data.sexuallyExplicit
    },
    {
      "category": "HARM_CATEGORY_HATE_SPEECH",
      "threshold": data.hateSpeech
    },
    {
      "category": "HARM_CATEGORY_HARASSMENT",
      "threshold": data.harassment
    },
    {
      "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
      "threshold": data.dangerousContent
    }
  ],
  "generationConfig": {
    "temperature": data.temperature,
    "topP": data.topP,
    "candidateCount": 1,
    "maxOutputTokens": data.maxOutputTokens,
    "stopSequences": splitAndTrim(data.stopSequence),
    "responseMimeType": "text/plain"
  }
};

//Some features only available in gemini 1.5
if (data.geminiModel == "gemini-1.5-pro") {
  postBodyData.generationConfig.presencePenalty = data.presencePenalty;
  postBodyData.generationConfig.frequencyPenalty = data.frequencyPenalty;
}

const postBody = JSON.stringify(postBodyData);

const postHeaders = {
  "Content-Type": "application/json; charset=utf-8"
};

const requestOptions = {
  headers: postHeaders,
  method: "POST",
  authorization: auth
};

// Make the request to Vertex AI & process the response.
return sendHttpRequest(url, requestOptions, postBody)
  .then(response => {
    logToConsole(JSON.stringify(response));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      let body = JSON.parse(response.body);
      return body.candidates[0].content.parts[0].text;
    } else {
      return data.defaultValueOnError;
    }
  })
  .catch((error) => {
    logToConsole("Error with VertexAI call to " + url + ". Error: ", error);
    return data.defaultValueOnError;
  });


___SERVER_PERMISSIONS___

[
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
        "publicId": "use_google_credentials",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedScopes",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://www.googleapis.com/auth/cloud-platform"
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
setup: ''


___NOTES___

Created on 5/3/2023, 5:16:28 PM


