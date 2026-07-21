import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdService {
  InterstitialAdService._();

  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;

  static const String _androidAdUnitId =
      'ca-app-pub-5695270850021201/2967435494';

  static const String _iosAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  static bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static String get _adUnitId =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? _iosAdUnitId
          : _androidAdUnitId;

  //==========================================================
  // INITIALIZE
  //==========================================================

  static Future<void> initialize() async {
    if (!_isSupported) return;

    await MobileAds.instance.initialize();

    debugPrint("✅ AdMob Initialized");

    preload();
  }

  //==========================================================
  // PRELOAD AD
  //==========================================================

  static void preload() {
    if (!_isSupported) return;

    if (_interstitialAd != null) return;

    if (_isLoading) return;

    _isLoading = true;

    debugPrint("📥 Loading Interstitial...");

    InterstitialAd.load(
      adUnitId: _adUnitId,
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