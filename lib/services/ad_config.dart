import 'package:flutter/foundation.dart';

class AdConfig {
  AdConfig._();

  static const String _androidBannerProduction =
      'ca-app-pub-5695270850021201/6727313571';
  static const String _androidInterstitialProduction =
      'ca-app-pub-5695270850021201/2967435494';

  static const String _androidBannerTest =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _androidInterstitialTest =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _iosBannerTest = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosInterstitialTest =
      'ca-app-pub-3940256099942544/4411468910';

  static String bannerAdUnitId({
    TargetPlatform? platform,
    bool isRelease = kReleaseMode,
  }) {
    final resolvedPlatform = platform ?? defaultTargetPlatform;
    if (resolvedPlatform == TargetPlatform.android) {
      return isRelease ? _androidBannerProduction : _androidBannerTest;
    }
    return _iosBannerTest;
  }

  static String interstitialAdUnitId({
    TargetPlatform? platform,
    bool isRelease = kReleaseMode,
  }) {
    final resolvedPlatform = platform ?? defaultTargetPlatform;
    if (resolvedPlatform == TargetPlatform.android) {
      return isRelease
          ? _androidInterstitialProduction
          : _androidInterstitialTest;
    }
    return _iosInterstitialTest;
  }
}
