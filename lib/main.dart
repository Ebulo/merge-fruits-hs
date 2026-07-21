import 'package:flutter/material.dart';

import 'screens/splash/loading_screen.dart';
import 'services/daily_reward_service.dart';
import 'services/interstitial_ad_service.dart';
import 'services/progress_service.dart';
import 'services/settings_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //==========================================================
  // SERVICES
  //==========================================================

  final progress = ProgressService();
  final settings = SettingsService();
  final dailyReward = DailyRewardService();

  //==========================================================
  // LOAD SAVED DATA
  //==========================================================

  await Future.wait([progress.load(), settings.load(), dailyReward.load()]);

  await InterstitialAdService.initialize();

  //==========================================================
  // RUN APP
  //==========================================================

  runApp(
    FruitMergeApp(
      progress: progress,
      settings: settings,
      dailyReward: dailyReward,
    ),
  );
}

class FruitMergeApp extends StatelessWidget {
  const FruitMergeApp({
    super.key,
    required this.progress,
    required this.settings,
    required this.dailyReward,
  });

  final ProgressService progress;
  final SettingsService settings;
  final DailyRewardService dailyReward;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fruit Merge',
      theme: ThemeData(useMaterial3: true, fontFamily: 'Arial'),

      // Splash / Loading Screen
      home: LoadingScreen(
        progress: progress,
        settings: settings,
        dailyReward: dailyReward,
      ),
    );
  }
}
