#!/bin/bash
# Copyright 2026 Google LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#      https://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script deploys the decryptValue function to Google Cloud Functions
# with IAM authentication enabled (--no-allow-unauthenticated) and configures
# the sGTM service account permissions.

if ! command -v gcloud >/dev/null 2>&1 && [ -x "$HOME/google-cloud-sdk/bin/gcloud" ]; then
  export PATH="$HOME/google-cloud-sdk/bin:$PATH"
fi

# --- Load Environment Variables from .env ---
if [ -f ".env" ]; then
  # Expecting KEY=VALUE format in the .env file
  export $(grep -v '^#' .env | xargs)
fi

# --- Configuration ---
# Function name, region, and project ID
FUNCTION_NAME="${FUNCTION_NAME:-decryptValue}"
REGION="${REGION:-us-central1}"
if [ -z "$PROJECT_ID" ]; then
  PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
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

if [ -z "$SGTM_SERVICE_ACCOUNT" ]; then
  read -p "Enter the Service Account email running your sGTM container: " SGTM_SERVICE_ACCOUNT
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

if [[ ! "$SGTM_SERVICE_ACCOUNT" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
  echo "Error: SGTM_SERVICE_ACCOUNT must be a valid Service Account email address."
  exit 1
fi

# --- Step 1: Enable Required APIs & Pre-Migration IAM Binding ---
echo "Enabling IAM Service Account Credentials API in project '$PROJECT_ID'..."
gcloud services enable iamcredentials.googleapis.com cloudfunctions.googleapis.com run.googleapis.com \
  --project "$PROJECT_ID"

echo "Granting roles/iam.serviceAccountOpenIdTokenCreator to '$SGTM_SERVICE_ACCOUNT'..."
gcloud iam service-accounts add-iam-policy-binding "$SGTM_SERVICE_ACCOUNT" \
  --project="$PROJECT_ID" \
  --member="serviceAccount:$SGTM_SERVICE_ACCOUNT" \
  --role="roles/iam.serviceAccountOpenIdTokenCreator" >/dev/null

# --- Step 2: Deployment ---
echo "Deploying function '$FUNCTION_NAME' to project '$PROJECT_ID' in region '$REGION'..."

# NOTE: This function is a decryption oracle and MUST NOT be public.
# --no-allow-unauthenticated requires callers to present a Google-signed ID
# token. The sGTM custom template (encryptedValue.tpl) must use getGoogleAuth
# to attach that token when calling this endpoint.
gcloud functions deploy "$FUNCTION_NAME" \
  --runtime nodejs20 \
  --trigger-http \
  --no-allow-unauthenticated \
  --entry-point "decryptValue" \
  --region "$REGION" \
  --project "$PROJECT_ID" \
  --set-env-vars="DECRYPTION_KEY=$DECRYPTION_KEY,IV=$IV" \
  --source .

if [ $? -ne 0 ]; then
  echo "Deployment failed."
  exit 1
fi

# --- Step 3: Lock Down Legacy Public Access & Grant Invoker Role ---
echo "Ensuring public (allUsers) access is removed and granting invoker access to '$SGTM_SERVICE_ACCOUNT'..."
gcloud functions remove-invoker-policy-binding "$FUNCTION_NAME" \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --member="allUsers" >/dev/null 2>&1 || true

CLOUD_RUN_SERVICE=$(echo "$FUNCTION_NAME" | tr '[:upper:]' '[:lower:]')
gcloud run services remove-iam-policy-binding "$CLOUD_RUN_SERVICE" \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --member="allUsers" \
  --role="roles/run.invoker" >/dev/null 2>&1 || true

gcloud functions add-invoker-policy-binding "$FUNCTION_NAME" \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --member="serviceAccount:$SGTM_SERVICE_ACCOUNT" >/dev/null

gcloud run services add-iam-policy-binding "$CLOUD_RUN_SERVICE" \
  --region="$REGION" \
  --project="$PROJECT_ID" \
  --member="serviceAccount:$SGTM_SERVICE_ACCOUNT" \
  --role="roles/run.invoker" >/dev/null 2>&1 || true

echo "Function deployed and secured successfully."
echo "Endpoint URL: https://$REGION-$PROJECT_ID.cloudfunctions.net/$FUNCTION_NAME"
echo "Authorized sGTM Service Account: $SGTM_SERVICE_ACCOUNT"
