import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'consent_service.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  //==========================================================
  // INITIALIZE
  //==========================================================

  static Future<void> initialize() async {
    if (!_isSupported) return;

    final canRequestAds = await ConsentService.gatherConsentAndInitializeAds();
    if (canRequestAds) {
      preload();
    }
  }

  //==========================================================
  // PRELOAD AD
  //==========================================================

  static Future<void> preload() async {
    if (!_isSupported || !await ConsentService.canRequestAds()) return;

    if (_interstitialAd != null) return;

    if (_isLoading) return;

    _isLoading = true;

    debugPrint("📥 Loading Interstitial...");

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint("✅ Interstitial Loaded");

          _interstitialAd = ad;
          _isLoading = false;

          ad.setImmersiveMode(true);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint("🎬 Interstitial Showing");
            },

            onAdDismissedFullScreenContent: (ad) {
              debugPrint("❎ Interstitial Closed");

              ad.dispose();

              _interstitialAd = null;

              preload();
            },

            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint("❌ Failed To Show: $error");

              ad.dispose();

              _interstitialAd = null;

              preload();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;

          debugPrint("❌ Failed To Load");
          debugPrint(error.toString());
        },
      ),
    );
  }

  //==========================================================
  // SHOW AD
  //==========================================================

  static Future<void> showIfAvailable() async {
    if (!_isSupported) return;

    if (_interstitialAd == null) {
      debugPrint("⚠️ Interstitial Not Ready");

      preload();

      return;
    }

    final ad = _interstitialAd!;

    _interstitialAd = null;

    ad.show();
  }
}
