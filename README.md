# sGTM Pantheon

A home for a variety of Server-side Google Tag Manager (sGTM) custom templates
for a number of use-cases.

## Solutions

### Soteria

**Use case**: value bidding to a secret conversion value, where the value can be
deteremined using a look up table.

See [Soteria](https://github.com/google-marketing-solutions/gps_soteria).

### Phoebe

**Use case**: value bidding to a conversion value that is calculated using AI in
real-time.

See [Phoebe](https://github.com/google-marketing-solutions/gps-phoebe).

### Apollo

**Use case**: Get data from a Google Sheet in realtime to generate lead gen value
for lead scoring. This value will be activated via VBB (value based bidding) to
optimize Google Ads campaign performance

See [Apollo](./sgtm/apollo/README.md).

### Hermes

**Use case**: Sending data Pub/Sub in Google Cloud to trigger decoupled events,
in a downstream pipeline.

See [Hermes](./sgtm/hermes/README.md).

### Cerberus

**Use case**: Integrate reCAPTCHA to filter bot-generated events & suspicious
activity and improve data models by using bot-likelihood signals.

See [Cerberus](https://github.com/GoogleCloudPlatform/recaptcha-enterprise-google-tag-manager).

## Developer

To update the git submodules run:

```
git submodule update --init --remote
```

Do not use the `--recursive` flag.

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
