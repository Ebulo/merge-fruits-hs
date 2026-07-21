# Fruit Merge Data Safety Notes

Use these notes as a source checklist, then verify every answer in Play Console against the exact SDK version in the uploaded bundle.

## App behavior

- No account creation or login.
- Game progress, coins, daily rewards, and preferences remain on-device in SharedPreferences.
- Google Mobile Ads supplies banner and interstitial ads.
- UMP requests consent where required before the app requests ads.

## Google Mobile Ads disclosures to review

Google documents automatic handling of:

- Approximate location derived from IP address.
- App interactions such as launches, taps, and video views.
- Diagnostics such as launch time, hang rate, and energy usage.
- Device or account identifiers, including the advertising ID and app set ID.

Purposes documented by Google include advertising, analytics, and fraud prevention. Google states that this data is encrypted in transit.

Reference: https://developers.google.com/admob/android/privacy/play-data-disclosure

Do not select **No data collected** while Google Mobile Ads remains in the app.
