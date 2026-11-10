<!--
 Copyright 2026 Google LLC
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
      https://www.apache.org/licenses/LICENSE-2.0
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
-->

# 🚀 Harpocrates 🚀

Welcome! This guide will walk you through deploying and configuring the sGTM Profit Template. This template allows you to securely pass an AES-256 encrypted value to your sGTM container and decrypt it via an IAM-authenticated Google Cloud Function, enhancing your data privacy and security.

Let's get started!

## 🏗️ Architecture

The following diagram illustrates the flow of data with this setup:

![Architecture Diagram](./assets/diagram.png)

Here's a step-by-step breakdown of how the data flows through the system:

1.  **Encrypted Value Sent to sGTM**: An AES-256 encrypted value is passed to the sGTM server within the `encryptedValueEventData` parameter of the incoming request.
2.  **Template Finds Encrypted Value**: The custom variable template in your sGTM container is triggered and reads the `encryptedValueEventData` from the event data.
3.  **Template Mints an OIDC ID Token**: Using `getGoogleAuth` and the Google Cloud IAM Service Account Credentials API (`iamcredentials.googleapis.com`), the template mints a Google-signed OpenID Connect (OIDC) ID token scoped to your Cloud Function URL.
4.  **Template Sends Authenticated Request to Cloud Function**: The template sends the encrypted value along with `Authorization: Bearer <ID_TOKEN>` to the deployed Google Cloud Function (`--no-allow-unauthenticated`).
5.  **Cloud Function Verifies & Decrypts**: Cloud Functions IAM verifies the caller's identity and `roles/cloudfunctions.invoker` (and `roles/run.invoker`) permissions, and the function uses the secret key to decrypt the value and return the plaintext result to the template.
6.  **Template Returns Decrypted Value**: The template receives the decrypted value from the Cloud Function and makes it available as a number within the sGTM environment.
7.  **Value Reported to Google Ads**: The decrypted value can now be used in other tags, such as the Google Ads conversion tag, to report the accurate conversion value.

---

## ✅ Prerequisites

Before you begin, please ensure you have the following:

*   A Google Cloud project with billing enabled.
*   The `gcloud` CLI installed and authenticated.
*   A GTM server container (sGTM) up and running on Google Cloud (e.g., Cloud Run or App Engine), and receiving events from a GTM web container.
*   The email address of the **Google Cloud Service Account** running your sGTM container (e.g., `123456789-compute@developer.gserviceaccount.com`).
*   It is recommended to have all the components in the same cloud region to reduce network latency.

---

## 🛠️ Setup & Deployment (New Installations)

Follow these steps to get everything up and running from scratch.

### 1. Clone the Repository

First, clone this repository:

```bash
git clone https://github.com/google-marketing-solutions/gps-sgtm-pantheon.git
cd gps-sgtm-pantheon/sgtm/harpocrates
```

### 2. Find Your sGTM Service Account Email

Locate the Service Account email used by your sGTM Cloud Run service:

*   **Via Google Cloud Console**: Go to **Cloud Run** → click your sGTM service (e.g., `server-side-tagging`) → open the **Security** tab → copy the **Service account** email.
*   **Via `gcloud` CLI**:
    ```bash
    gcloud run services describe <YOUR_SGTM_CLOUD_RUN_SERVICE> \
      --region="<YOUR_SGTM_REGION>" \
      --project="<YOUR_PROJECT_ID>" \
      --format="value(spec.template.spec.serviceAccountName)"
    ```
    *(Note: If the output is empty, Cloud Run is using the default Compute Engine service account: `<PROJECT_NUMBER>-compute@developer.gserviceaccount.com`.)*

### 3. Configure Environment Variables

Copy the example environment file to create your own configuration:

```bash
cp .env.example .env
```

Open `.env` and fill in the required values:

*   `DECRYPTION_KEY`: 64-character hex string (32 bytes), e.g. generated with `openssl rand -hex 32`.
*   `IV`: 32-character hex string (16 bytes), e.g. generated with `openssl rand -hex 16`.
*   `SGTM_SERVICE_ACCOUNT`: The email address of the Service Account running your sGTM container (from Step 2).

### 4. Set Your GCP Region

Open the `deploy.sh` script (or set `REGION` in `.env`) to your desired Google Cloud region (e.g., `us-central1`). This ensures the Cloud Function is deployed to the correct location.

```bash
# deploy.sh
REGION="us-central1"
```

### 5. Deploy the Cloud Function

Make the deployment script executable and run it:

```bash
chmod +x deploy.sh
./deploy.sh
```

`deploy.sh` automatically:
1.  Enables the `iamcredentials.googleapis.com`, `cloudfunctions.googleapis.com`, and `run.googleapis.com` APIs.
2.  Grants your `SGTM_SERVICE_ACCOUNT` the `roles/iam.serviceAccountOpenIdTokenCreator` role on itself so it can mint OIDC ID tokens.
3.  Deploys the `decryptValue` Cloud Function with `--no-allow-unauthenticated` (blocking all unauthenticated internet traffic).
4.  Grants your `SGTM_SERVICE_ACCOUNT` the `roles/cloudfunctions.invoker` and `roles/run.invoker` roles on `decryptValue`.

### 6. Upload the Template to sGTM

Add the custom variable template to your sGTM container:

1.  Navigate to your sGTM container in the Google Tag Manager interface.
2.  Go to the **Templates** section in the left-hand menu.
3.  Under **Variable Templates**, click **New**.
4.  Click the three dots (**⋮**) in the top-right corner and select **Import**.
5.  Select the `encryptedValue.tpl` file from this project and click **Save**.

### 7. Create a Variable & Configure Your Tag in sGTM

1.  Go to the **Variables** section and click **New** under **User-Defined Variables**.
2.  Choose the **AES-256 Decryptor Variable** template you just imported.
3.  Fill in the variable parameters:
    *   **Google Cloud Project ID**: Your GCP project ID hosting the Cloud Function.
    *   **Cloud Function Region**: Your Cloud Function region (e.g., `us-central1`).
    *   **Cloud Function Name**: `decryptValue` (or your custom function name).
    *   **sGTM Service Account Email**: The Service Account email from Step 2 (must match `SGTM_SERVICE_ACCOUNT`).
    *   **Encrypted Value Event Data**: Reference to the Event Data variable containing the encrypted value (e.g., `{{ED - encryptedValueEventData}}`).
    *   **Default Value**: Fallback value if decryption fails (e.g., `0`).
4.  Save the variable, reference it in your conversion tag (e.g., Google Ads Conversion Tracking), and **Publish** your container.

---

## 🔄 Migrating from v1 (Unauthenticated) to v2 (Authenticated)

If you are already running an earlier version of Harpocrates where `decryptValue` was deployed with `--allow-unauthenticated`, follow these steps in order to upgrade to authenticated invocation with **zero downtime** and **no changes to your website or encryption keys**.

> **What stays the same?**
> Your `DECRYPTION_KEY`, `IV`, and website/backend encryption code do **not** change.

### Step 1: Identify Your sGTM Service Account Email

Find the email address of the Service Account running your sGTM Cloud Run service:

```bash
gcloud run services describe <YOUR_SGTM_SERVICE_NAME> \
  --region="<YOUR_REGION>" \
  --project="<YOUR_PROJECT_ID>" \
  --format="value(spec.template.spec.serviceAccountName)"
```

*(Or in the Google Cloud Console: **Cloud Run** → click your sGTM service → **Security** tab → copy **Service account**.)*

### Step 2: Pre-Grant IAM Token Creator Permission (Before Updating GTM)

Enable the IAM Credentials API and allow your sGTM Service Account to mint OIDC ID tokens while your existing Cloud Function is still accepting traffic:

```bash
gcloud services enable iamcredentials.googleapis.com \
  --project="<YOUR_PROJECT_ID>"

gcloud iam service-accounts add-iam-policy-binding "<YOUR_SGTM_SERVICE_ACCOUNT>" \
  --project="<YOUR_PROJECT_ID>" \
  --member="serviceAccount:<YOUR_SGTM_SERVICE_ACCOUNT>" \
  --role="roles/iam.serviceAccountOpenIdTokenCreator"
```

### Step 3: Update the `encryptedValue.tpl` Template in sGTM First (Zero-Downtime Step)

Updating your sGTM template *before* locking down the Cloud Function ensures sGTM begins attaching `Authorization: Bearer <ID_TOKEN>` while the old Cloud Function still allows all requests:

1.  Open your sGTM container in Google Tag Manager and go to **Templates**.
2.  Click your existing **AES-256 Decryptor Variable** template.
3.  Click the three dots (**⋮**) in the top-right corner, select **Import**, and choose the updated `encryptedValue.tpl` file.
4.  Click **Save** (review and accept the updated permissions for `iamcredentials.googleapis.com` and `use_google_credentials`).
5.  Go to **Variables**, open your Harpocrates variable, enter your **sGTM Service Account Email** in the new field, and click **Save**.
6.  Click **Submit** / **Publish** to publish your sGTM container.

### Step 4: Redeploy and Lock Down the Cloud Function

1.  Pull the latest code in your `harpocrates` directory.
2.  Open your existing `.env` file (keeping your existing `DECRYPTION_KEY` and `IV`) and add `SGTM_SERVICE_ACCOUNT`:
    ```dotenv
    DECRYPTION_KEY=<your-existing-64-char-hex-key>
    IV=<your-existing-32-char-hex-iv>
    SGTM_SERVICE_ACCOUNT=<your-sgtm-service-account-email>
    ```
3.  Run the updated deployment script:
    ```bash
    ./deploy.sh
    ```
    This deploys the updated `index.js` with `--no-allow-unauthenticated`, explicitly removes the legacy `allUsers` invoker binding from both Cloud Functions and Cloud Run, and grants `roles/cloudfunctions.invoker` and `roles/run.invoker` exclusively to `SGTM_SERVICE_ACCOUNT`.

### Step 5: Verify Your Migration

1.  **Verify unauthenticated requests are blocked (should return `401` or `403`)**:
    ```bash
    curl -i -X POST "https://<REGION>-<PROJECT_ID>.cloudfunctions.net/decryptValue" \
      -H "Content-Type: application/json" \
      -d '{"encryptedValue":"test"}'
    ```
2.  **Verify end-to-end decryption in sGTM**:
    Send a test request to your sGTM endpoint (see **Test Your Setup** below) and confirm in sGTM Preview mode or Cloud Run logs that the variable resolves to the decrypted conversion value.

---

## 🧪 Test Your Setup

After publishing your container, you can test the setup by sending a request to your sGTM endpoint to verify that the encrypted value is being decrypted end-to-end.

Construct a URL like the one below, replacing the placeholders with your specific values:

```
https://server-side-tagging-193100055804.${sGTM_REGION}.run.app/g/collect?v=2&tid=G-4C3C4XJ4CH&cid=12345.67890&en=encrypt&encryptedValueEventData=${ENCRYPTED_VALUE}&_dbg=1
```

**Placeholders:**

*   `${sGTM_REGION}`: The GCP region where your sGTM container is hosted.
*   `${ENCRYPTED_VALUE}`: The URL-encoded base64 encrypted value you want to send.

You can use the sGTM debugger (`_dbg=1`) to see the incoming request and verify that your tag is firing as expected.

🎉 **You're all set!** Your sGTM container is now securely working with encrypted values.
