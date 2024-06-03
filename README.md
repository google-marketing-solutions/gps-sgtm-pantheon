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
purpose. The list of tools are broadly split into two categories: gathering 
data or sending data. The solutions can be combined very flexibility (more 
detail below).

### Gather Data

#### Soteria
*Sum metrics stored in Firestore* <br/>
**Use case**: Calculate and bid to profit or other sensitive values for online 
transactions without exposing data

See [Soteria](https://github.com/google-marketing-solutions/gps_soteria).

#### Phoebe
*Access model in VertexAI* <br/>
**Use case**: Call Vertex AI in real time for LTV bidding, lead scoring, and 
real-time audience segmentation

See [Phoebe](https://github.com/google-marketing-solutions/gps-phoebe).

#### Artemis
*Get data from Firestore* <br/>
**Use case**: Get customer data from Firestore and use it for conditional tag 
firing, advanced metrics, audience segmentation, and real-time website 
personalization without exposing data

See [Hermes](./sgtm/hermes/README.md).

#### Apollo
*Get data from a Google sheet* <br/>
**Use case**: Get data from a Google Sheet in realtime to generate lead gen value 
for lead scoring. This value will be activated via VBB (value based bidding) to 
optimize Google Ads campaign performance 

See [Apollo](./sgtm/apollo/README.md).

#### Cerberus
*Get reCAPTCHA scores in sGTM* <br/>
**Use case**: Integrates reCAPTCHA to filter bot-generated events & suspicious 
activity. Also, improves data models by using bot-likelihood signals

See [Cerberus](https://github.com/GoogleCloudPlatform/recaptcha-enterprise-google-tag-manager).

### Send Data

#### Hephaestus
*Write data to Firestore* <br/>
**Use case**: Write or edit data in Firestore for advanced bidding (e.g. new/
returning customer, nth transaction), advanced audience, analytics, and marketing 
data pipeline automation

See [Hephaestus](./sgtm/hephaestus/README.md).

#### Chaos
*Write data to BigQuery* <br/>
**Use case**: Write data to BigQuery for advanced analytics, data recovery, 
audience creation, and marketing data pipeline automation

See [Chaos](./sgtm/choas/README.md).

#### Deipneus
*Write data to first-party cookies in browser* <br/>
**Use case**: Sends first-party  data back to the website. Useful for real time web 
personalisation and audience creation

See [Deipneus](./sgtm/deipneus/README.md).

#### Hermes
*Send data to Pub/Sub to trigger other processes* <br/>
**Use case**: Sending data Pub/Sub in Google Cloud to trigger decoupled events,
in a downstream pipeline.

See [Hermes](./sgtm/hermes/README.md).

## Combining solutions

The solutions use sGTM tag & variable templates which allow to reuse them to
acheive different aims. Outputs from some tools can be used as inputs for
other tools in an extremely flexible and extendable way. For example, you 
could use [Artemis](./sgtm/artemis/README.md) to get some data from Firestore 
& [Cerberus](https://github.com/GoogleCloudPlatform/recaptcha-enterprise-google-tag-manager) 
to generate a reCAPTCHA score. These two outputs could then be used as inputs 
to [Phoebe](https://github.com/google-marketing-solutions/gps-phoebe) which
could call a lead scoring model hosted in Vertext AI. This score could be sent 
to advertising platforms using sGTM's built-in tags but could also be stored in
Firestore and/or BigQuery by [Hephaestus](./sgtm/hephaestus/README.md) and 
[Chaos](./sgtm/choas/README.md).

## Disclaimer
__This is not an officially supported Google product.__

Copyright 2023 Google LLC. This solution, including any related sample code or
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
