# sGTM Pantheon

sGTM Pantheon is a toolbox of solutions which helps gather, transform, 
and send data using [server-side Google Tag Manager](https://developers.google.com/tag-platform/tag-manager/server-side). The solutions within the toolbox augment the capabilities 
of sGTM significantly. It enables clients to improve their reporting, 
bidding, audience management, and data pipeline management and processes.

Use cases include:

- Accessing cloud-based customer, product, and business data in real time
- Bidding using advanced or secret values in marketing platforms
- Accessing data from external APIs (e.g. reCAPTCHA)
- Realtime website personalisation & conversion rate optimisation
- Streamlining of data pipelines
- Improved data collection
- Advanced analytics & reporting using cloud databases


## Solutions

The sGTM Pantheon includes lots of individual solutioins all with a specific 
purpose. The list of tools are broadly split into three categories: gathering 
data, sending data and monitoring data. The solutions can be combined very flexibility (more 
detail below).

### Gather Data

These solutions all get data from places outside of sGTM via API calls. They 
can be used to get data that is not available on the website dataLayer and 
the event data sent to sGTM when the hit is sent from the client-side tag.

|Solution|One-liner|Use Case|Why is it called that?|
|---|---|---|---|
|[Soteria](https://github.com/google-marketing-solutions/gps_soteria)|Sum metrics stored in Firestore|Calculate and bid to profit or other sensitive values for online transactions without exposing data|Goddess of safety, and deliverance and preservation from harm. Like the goddess, this project provides safety from end users to your sensitive value data (e.g. profit).|
|[Phoebe](https://github.com/google-marketing-solutions/gps-phoebe)|Access a model in VertexAI|Call Vertex AI in real time for LTV bidding, lead scoring, and real-time audience segmentation|Goddess of prediction|
|[Artemis](./sgtm/artemis/README.md)|Get data from Firestore|Get customer data from Firestore and use it for conditional tag firing, advanced metrics, audience segmentation, and real-time website personalization without exposing data|Goddess of the hunt. Like the goddess, the solution goes out hunting for data and returns with it.|
|[Apollo](./sgtm/apollo/README.md)|Get data from a Google sheet|Get data from a Google Sheet in realtime to generate lead gen value for lead scoring.|Greek god of knowledge, which can be stored in Sheets|
|[Cerberus](https://github.com/GoogleCloudPlatform/recaptcha-enterprise-google-tag-manager)|Get reCAPTCHA scores in sGTM|Integrate reCAPTCHA to filter bot-generated events & suspicious activity. Also, improves data models by using bot-likelihood signals|The multi-headed dog who guards the gates of the Underworld|
|[Dioscuri](./sgtm/dioscuri/README.md)|Get response from Gemini 1.0 Pro and Gemini 1.5 Pro APIs|Use realtime data from your website as well as customer & business data stored in the cloud to get responses from Gemini 1.0 Pro and 1.5 Pro|The Greek name for Gemini|

### Send Data

These solutions allow you to send data from sGTM to other destinations.

|Solution|One-liner|Use Case|Why is it called that?|
|---|---|---|---|
|[Hephaestus](./sgtm/hephaestus/README.md)|Write data to Firestore|Write or edit data in Firestore for advanced bidding (e.g. new/returning customer, nth transaction), advanced audience, analytics, and marketing data pipeline automation|God of fire|
|[Chaos](./sgtm/chaos/README.md)|Write data to BigQuery|Write data to BigQuery for advanced analytics, data recovery, audience creation, and marketing data pipeline automation|Chaos was the infinite void that came to be filled by the world, in the way BigQuey can be filled with data|
|[Deipneus](./sgtm/deipneus/README.md)|Write data to first-party cookies in browser|Send first-party data back to the website. Useful for real time web personalisation and audience creation|Greek god of food, in particular bread|
|[Hermes](./sgtm/hermes/README.md)|Send data to Pub/Sub to trigger other processes|Send data Pub/Sub in Google Cloud to trigger decoupled events, in a downstream pipeline.|The messenger god|

### Monitor Data

These solutions allow you to monitor data in sGTM more easily.

|Solution|One-liner|Use Case|Why is it called that?|
|---|---|---|---|
|[Argos](./sgtm/argos/README.md)|Monitor critical gTag settings|Monitor settings related to gTag configuration and log errors to the console, GA4, BigQuery, and/or Cloud Logging. Settings relate to domain, region, consent, privacy, and gTag measurment ID configuration|Argos is an all-seeing many-eye giant|

## Combining solutions

The solutions use sGTM tag & variable templates which allow to reuse them to
acheive different aims. Outputs from some tools can be used as inputs for
other tools in an extremely flexible and extendable way. For example, you 
could use [Artemis](./sgtm/artemis/README.md) to get some data from Firestore 
& [Cerberus](https://github.com/GoogleCloudPlatform/recaptcha-enterprise-google-tag-manager) 
to generate a reCAPTCHA score. These two outputs could then be used as inputs 
to [Phoebe](https://github.com/google-marketing-solutions/gps-phoebe) which
could call a lead scoring model hosted in VertexAI. This score could be sent 
to advertising platforms using sGTM's built-in tags but could also be stored in
Firestore and/or BigQuery by [Hephaestus](./sgtm/hephaestus/README.md) and 
[Chaos](./sgtm/chaos/README.md).

## Developer

To update the git submodules run:

```
git submodule update --init --remote
```

Do not use the `--recursive` flag.

## Disclaimer
__This is not an officially supported Google product.__

Copyright 2024 Google LLC. This solution, including any related sample code or
data, is made available on an "as is", "as available", and "with all faults"
basis, solely for illustrative purposes, and without warranty or representation
of any kind. This solution is experimental, unsupported and provided solely for
your convenience. Your use of it is subject to your agreements with Google, as
applicable, and may constitute a beta feature as defined under those agreements.
To the extent that you make any data available to Google in connection with your
use of the solution, you represent and warrant that you have all necessary and
appropriate rights, consents and permissions to permit Google to use and process
that data. By using any portion of this solution, you acknowledge, assume and
accept all risks, known and unknown, associated with its usage, including with
respect to your deployment of any portion of this solution in your systems, or
usage in connection with your business, if at all.
