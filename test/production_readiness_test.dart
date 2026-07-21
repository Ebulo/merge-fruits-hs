import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_paths/config/app_config.dart';
import 'package:prism_paths/screens/fruit_merge_home_screen.dart';
import 'package:prism_paths/services/ad_config.dart';
import 'package:prism_paths/services/daily_reward_service.dart';
import 'package:prism_paths/services/progress_service.dart';
import 'package:prism_paths/services/settings_service.dart';
import 'package:prism_paths/widgets/daily_sign_in_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('production configuration contains no placeholder contact values', () {
    expect(AppConfig.playStoreUrl, contains(AppConfig.applicationId));
    expect(AppConfig.supportEmail, contains('@'));
    expect(AppConfig.privacyPolicyUrl, isNot(contains('yourwebsite')));
    expect(AppConfig.termsOfServiceUrl, isNot(contains('yourwebsite')));
  });

  test('debug Android builds use Google test ad units', () {
    expect(
      AdConfig.bannerAdUnitId(
        platform: TargetPlatform.android,
        isRelease: false,
      ),
      'ca-app-pub-3940256099942544/6300978111',
    );
    expect(
      AdConfig.interstitialAdUnitId(
        platform: TargetPlatform.android,
        isRelease: false,
      ),
      'ca-app-pub-3940256099942544/1033173712',
    );
  });

  test('release Android builds use production ad units', () {
    expect(
      AdConfig.bannerAdUnitId(
        platform: TargetPlatform.android,
        isRelease: true,
      ),
      startsWith('ca-app-pub-5695270850021201/'),
    );
    expect(
      AdConfig.interstitialAdUnitId(
        platform: TargetPlatform.android,
        isRelease: true,
      ),
      startsWith('ca-app-pub-5695270850021201/'),
    );
  });

  test('coin balance persists and rejects invalid rewards', () async {
    final progress = ProgressService();
    await progress.load();

    await progress.addCoins(100);
    await progress.addCoins(-50);

    final reloaded = ProgressService();
    await reloaded.load();
    expect(reloaded.coins, 100);
  });

  test('settings persist sound and vibration choices', () async {
    final settings = SettingsService();
    await settings.load();

    await settings.toggleSound();
    await settings.toggleVibration();

    final reloaded = SettingsService();
    await reloaded.load();
    expect(reloaded.soundEnabled, isFalse);
    expect(reloaded.vibrationEnabled, isFalse);
  });

  testWidgets('claiming the daily reward credits the coin balance', (
    tester,
  ) async {
    final dailyReward = DailyRewardService();
    final progress = ProgressService();
    final settings = SettingsService()
      ..soundEnabled = false
      ..vibrationEnabled = false;
    await dailyReward.load();
    await progress.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DailySignInCard(
            dailyReward: dailyReward,
            progress: progress,
            settings: settings,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('daily-reward-1')));
    await tester.pumpAndSettle();

    expect(progress.coins, 100);
    expect(dailyReward.claimedToday, isTrue);
  });

  testWidgets('home screen fits a compact landscape phone', (tester) async {
    tester.view.physicalSize = const Size(952, 426);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final dailyReward = DailyRewardService();
    final progress = ProgressService();
    final settings = SettingsService()
      ..soundEnabled = false
      ..vibrationEnabled = false;
    await dailyReward.load();
    await progress.load();

    await tester.pumpWidget(
      MaterialApp(
        home: FruitMergeHomeScreen(
          progress: progress,
          settings: settings,
          dailyReward: dailyReward,
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('DAILY STREAK'), findsOneWidget);
  });
}
