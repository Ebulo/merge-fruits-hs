import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdService {
  BannerAdService._();

  static BannerAd? bannerAd;
  static bool isLoaded = false;

  static String get adUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-5695270850021201/6727313571';
    }

    return 'ca-app-pub-3940256099942544/2934735716';
  }

  static void loadBanner(void Function() refresh) {
    bannerAd?.dispose();

    bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('✅ Banner Loaded');
          isLoaded = true;
          refresh();
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner Failed: $error');
          ad.dispose();
          isLoaded = false;
        },
      ),
    );

    bannerAd!.load();
  }

  static void dispose() {
    bannerAd?.dispose();
    bannerAd = null;
    isLoaded = false;
  }
}