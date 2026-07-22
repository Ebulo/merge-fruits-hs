# Fruit Merge Play Console Checklist

## Release identifiers

- App name: Fruit Merge
- Package name: `com.krishna.newgame.prism_paths`
- Version name: `1.0.1`
- Version code: `3`
- Target SDK: `36`
- Release bundle: `build/app/outputs/bundle/release/app-release.aab`

Keep the release keystore and `android/key.properties` backed up securely. Every future update to this Play listing must be signed with the same upload key unless the upload key is reset through Play Console.

## Store listing copy

Short description:

> Merge adorable fruits, build combos, and chase your highest score!

Full description:

> Drop, match, and merge cheerful fruits into bigger creations in Fruit Merge, a bright and relaxing puzzle game. Plan each drop, build satisfying combos, unlock new levels, and return each day to collect rewards.
>
> Features:
>
> - Simple drop-and-merge gameplay
> - Colorful fruit characters and satisfying effects
> - Levels, high scores, and combo challenges
> - Daily rewards that add to your in-game coin balance
> - Optional sound and vibration controls
> - No account required

## Graphic assets

- Store icon: `play_store/assets/store-icon-512.png` — 512×512 PNG
- Feature graphic: `play_store/assets/feature-graphic.png` — 1024×500 PNG
- Phone screenshots: `play_store/assets/phone-01-home.png` through `phone-04-privacy.png` — 2560×1440 PNG

## Privacy and app content

- Public privacy-policy URL: `https://ebulo.github.io/merge-fruits-hs/privacy.html`
- Public terms URL: `https://ebulo.github.io/merge-fruits-hs/terms.html`
- Publish the repository's `docs/` directory with GitHub Pages before submitting the app, then verify both URLs in a signed-out browser.
- Configure and publish the required privacy message in AdMob's Privacy & messaging section. The app already calls UMP on launch and exposes privacy choices when UMP says they are required.
- Complete Data safety using `play_store/DATA_SAFETY.md`. Do not select “No data collected” while Google Mobile Ads is included.
- Complete Ads, Content rating, Target audience, App access, and any other Play Console declarations truthfully.

## Release upload

1. Create or select the app in Play Console and confirm the default language and app/game classification.
2. Complete the Main store listing with the copy and assets above.
3. Add the public privacy-policy URL under App content and the store-listing privacy field wherever Play Console requests it.
4. Complete every required App content declaration, including Data safety and Ads.
5. Open Testing > Internal testing, create a release, and upload the release AAB.
6. Review Play's automated warnings, save the release, and roll it out to internal testers.
7. Install the Play-delivered build from the tester link and verify consent, test navigation, rewards, sound/vibration, ads, and legal links.
8. Promote the tested release to production, complete the production rollout screens, submit it for review, and monitor the Publishing overview.

Never upload `app-debug.apk` or a debug AAB. Rebuild the release AAB after changing the version in `pubspec.yaml`.
