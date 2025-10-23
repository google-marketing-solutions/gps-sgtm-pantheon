
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#!/bin/bash

# This script deploys the decryptValue function to Google Cloud Functions.

# --- Configuration ---
# Function name, region, and project ID
FUNCTION_NAME="decryptValue"
REGION="us-central1"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

# --- Load Environment Variables from .env ---
if [ -f ".env" ]; then
  # Expecting KEY=VALUE format in the .env file
  export $(grep -v '^#' .env | xargs)
fi

# --- User Input for Missing Variables ---
if [ -z "$PROJECT_ID" ]; then
  read -p "Enter your Google Cloud Project ID: " PROJECT_ID
fi

# DECRYPTION_KEY and IV will be loaded from the environment by the export command
# If they are still empty, prompt the user.
if [ -z "$DECRYPTION_KEY" ]; then
  read -p "Enter your DECRYPTION_KEY (64 hex characters): " DECRYPTION_KEY
fi

if [ -z "$IV" ]; then
  read -p "Enter your IV (32 hex characters): " IV
fi

# --- Validation ---
if [ -z "$PROJECT_ID" ]; then
  echo "Error: Google Cloud project ID is required."
  exit 1
fi

if [[ ! "$DECRYPTION_KEY" =~ ^[a-fA-F0-9]{64}$ ]]; then
    echo "Error: DECRYPTION_KEY must be a 64-character hexadecimal string."
    exit 1
fi

if [[ ! "$IV" =~ ^[a-fA-F0-9]{32}$ ]]; then
    echo "Error: IV must be a 32-character hexadecimal string."
    exit 1
fi


# --- Deployment ---
echo "Deploying function '$FUNCTION_NAME' to project '$PROJECT_ID' in region '$REGION'வுகளை..."

gcloud functions deploy "$FUNCTION_NAME" \
  --runtime nodejs20 \
  --trigger-http \
  --allow-unauthenticated \
  --entry-point "decryptValue" \
  --region "$REGION" \
  --project "$PROJECT_ID" \
  --set-env-vars="DECRYPTION_KEY=$DECRYPTION_KEY,IV=$IV" \
  --source .

# --- Verification ---
if [ $? -eq 0 ]; then
  echo "Function deployed successfully."
  echo "You can trigger it at: https://$REGION-$PROJECT_ID.cloudfunctions.net/$FUNCTION_NAME"
else
  echo "Deployment failed."
fi