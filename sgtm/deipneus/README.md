# Deipneus

Send data from Server-side Google Tag Manager back to the website using durable 
first-party cookies for real-time website personalization.


## Why Deipneus?

[Deipneus](https://en.wikipedia.org/wiki/Deipneus) is the Greek God of food, in 
particular bread. (It's the closest God we could find who had even a tangential 
connection to cookies!)

Deipneus is pronounced a bit like "deep-KNEE-uss".


## Prerequisites

- sGTM deployed

## Get Started

1. Download a copy of the [set_cookie_in_browser.tpl](./set_cookie_in_browser.tpl) to
  your local machine. Make sure the file is saved with the extension `.tpl`. If you
  would like more control of the settings for the cookie you're setting an
  [advanced template](./set_cookie_in_browser.tpl) is available. This template gives
  you full control of path, domain, samesite, and secure settings for the cookies.
3. Open [Google Tag Manager](https://tagmanager.google.com) and select your
  server-side container.
4. Click on templates -> the new button in the tag templates section. Click the
   three dots in the top right hand corner and press import.
5. Select the set_cookie_in_browser.tpl from your machine. 
6. Optionally update the permissions for the cookies that the tag is allowed
   to set by going to permissions > sets a cookie. Use * to allow the tag to
   set any cookies. If you want to set a session cookie set the expiry (days)
   to 0.
7. Press save.
8. Go to the tags page and press new.
9. Under tag configuration select Deipneus - Set Cookie in Browser.
10. Add a row for each cookie you want to set in the browser by hard-coding
   the values or using variables already configured in sGTM.
11. Add a trigger, and preview/submit your code.
12. You can check the cookies have been set correctly by using browser dev
    tools.

Here is an example configuration:

![Example Tag configuration](./docs/set_cookie_in_browser_tag_example.png)



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
