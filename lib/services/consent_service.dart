import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ConsentService {
  ConsentService._();

  static bool _adsInitialized = false;
  static bool _privacyOptionsRequired = false;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static bool get privacyOptionsRequired => _privacyOptionsRequired;

  static Future<bool> gatherConsentAndInitializeAds() async {
    if (!isSupported) {
      return false;
    }

    final updateCompleter = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) {
            debugPrint('Consent form error: ${error.message}');
          }
        });
        updateCompleter.complete();
      },
      (error) {
        debugPrint('Consent information error: ${error.message}');
        updateCompleter.complete();
      },
    );

    await updateCompleter.future;
    await _refreshPrivacyOptionsStatus();

    final canRequestAds = await ConsentInformation.instance.canRequestAds();
    if (canRequestAds && !_adsInitialized) {
      await MobileAds.instance.initialize();
      _adsInitialized = true;
    }

    return canRequestAds;
  }

  static Future<bool> canRequestAds() async {
    if (!isSupported || !_adsInitialized) {
      return false;
    }

    return ConsentInformation.instance.canRequestAds();
  }

  static Future<String?> showPrivacyOptions() async {
    if (!isSupported) {
      return 'Privacy choices are only available on Android and iOS.';
    }

    String? errorMessage;
    await ConsentForm.showPrivacyOptionsForm((error) {
      errorMessage = error?.message;
    });
    await _refreshPrivacyOptionsStatus();
    return errorMessage;
  }

  static Future<void> _refreshPrivacyOptionsStatus() async {
    final status = await ConsentInformation.instance
        .getPrivacyOptionsRequirementStatus();
    _privacyOptionsRequired =
        status == PrivacyOptionsRequirementStatus.required;
  }
}
