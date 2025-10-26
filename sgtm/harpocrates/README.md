# 🚀 Harpocrates 🚀

Welcome! This guide will walk you through deploying and configuring the sGTM Profit Template. This template allows you to securely pass an encrypted value to your sGTM container, enhancing your data privacy and security.

Let's get started!

## 🏗️ Architecture

The following diagram illustrates the flow of data with this setup:

![Architecture Diagram](./assets/diagram.png)

Here's a step-by-step breakdown of how the data flows through the system:

1.  **Encrypted Value Sent to sGTM**: An AES-256 encrypted value is passed to the sGTM server within the `encryptedValueEventData` parameter of the incoming request.
2.  **Template Finds Encrypted Value**: The custom variable template in your sGTM container is triggered and reads the `encryptedValueEventData` from the event data.
3.  **Template Sends Value to Cloud Function**: The template sends the encrypted value to the deployed Google Cloud Function for decryption.
4.  **Cloud Function Decrypts**: The Cloud Function uses the secret key to decrypt the value and returns the plaintext result to the template.
5.  **Template Returns Decrypted Value**: The template receives the decrypted value from the Cloud Function and makes it available within the sGTM environment.
6.  **Value Reported to Google Ads**: The decrypted value can now be used in other tags, such as the Google Ads conversion tag, to report the accurate conversion value.



## ✅ Prerequisites

Before you begin, please ensure you have the following:

*   A Google Cloud project with billing enabled.
*   The `gcloud` CLI installed and authenticated.
*   A GTM server container up and running, and receiving events from a GTM web container.
*   It is recommended to have all the components in the same cloud region to reduce network latency.

## 🛠️ Setup & Deployment

Follow these steps to get everything up and running.

### 1. Clone the Repository

First, clone this repository:

```bash
git clone https://professional-services.googlesource.com/solutions/harpocrates
cd harpocrates
```

### 2. Configure Environment Variables

First, copy the example environment file to create your own configuration:

```bash
cp .env.example .env
```

Next, open the `.env` file and fill in the required values for your GCP project and sGTM setup.

### 3. Set Your GCP Region

Open the `deploy.sh` script and update the `REGION` variable to your desired Google Cloud region (e.g., `us-central1`). This ensures the Cloud Function is deployed to the correct location.

```bash
# deploy.sh
REGION="your-gcp-region"
```

### 4. Deploy the Cloud Function

Now, make the deployment script executable and run it:

```bash
chmod +x deploy.sh
./deploy.sh
```

This script will deploy a Google Cloud Function that handles the encryption.

### 5. Upload the Template to sGTM

It's time to add the custom template to your sGTM container:

1.  Navigate to your sGTM container in the Google Tag Manager interface.
2.  Go to the **Templates** section in the left-hand menu.
3.  Under **Tag Templates**, click **New**.
4.  Click the three dots (⋮) in the top-right corner and select **Import**.
5.  Select the `encryptedValue.tpl` file from this project.
6.  Save the template. You'll now have a new template available for your tags.

### 6. Create a Tag in sGTM

Finally, let's create a new tag to use the template:

1.  Go to the **Tags** section and click **New**.
2.  For the **Tag Configuration**, choose the **Encrypted Value** template you just imported.
3.  Configure the tag with the necessary parameters.
4.  Set up a trigger for when you want this tag to fire.
5.  Save the tag and publish your container.

### 7. Test Your Setup

After publishing your container, you can test the setup by sending a request to your sGTM endpoint. This will allow you to verify that the encrypted value is being correctly processed.

Construct a URL like the one below, replacing the placeholders with your specific values:

```
https://server-side-tagging-193100055804.${sGTM_REGION}.run.app/g/collect?v=2&tid=G-4C3C4XJ4CH&cid=12345.67890&en=encrypt&encryptedValueEventData=${ENCRYPTED_VALUE}%3D%3D&_dbg=1
```

**Placeholders:**

*   `${sGTM_REGION}`: The GCP region where your sGTM container is hosted.
*   `${ENCRYPTED_VALUE}`: The encrypted value you want to send.

You can use the sGTM debugger (`_dbg=1`) to see the incoming request and verify that your tag is firing as expected.

🎉 **You're all set!** Your sGTM container is now ready to work with encrypted values.
