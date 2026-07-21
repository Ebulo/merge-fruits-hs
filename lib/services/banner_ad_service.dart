import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_config.dart';
import 'consent_service.dart';

class BannerAdService {
  BannerAdService._();

  static BannerAd? bannerAd;
  static bool isLoaded = false;

  static Future<void> loadBanner(void Function() refresh) async {
    if (kIsWeb || !await ConsentService.canRequestAds()) {
      return;
    }

    bannerAd?.dispose();
    isLoaded = false;

    bannerAd = BannerAd(
      adUnitId: AdConfig.bannerAdUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner loaded');
          isLoaded = true;
          refresh();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner failed: $error');
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
