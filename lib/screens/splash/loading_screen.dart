import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/daily_reward_service.dart';
import '../../services/progress_service.dart';
import '../../services/settings_service.dart';
import '../fruit_merge_home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    required this.progress,
    required this.settings,
    required this.dailyReward,
  });

  final ProgressService progress;
  final SettingsService settings;
  final DailyRewardService dailyReward;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double progress = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (!mounted) {
        return;
      }

      setState(() {
        progress = (progress + 1).clamp(0, 100);
      });

      if (progress < 100) {
        return;
      }

      timer.cancel();

      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) {
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => FruitMergeHomeScreen(
              progress: widget.progress,
              settings: widget.settings,
              dailyReward: widget.dailyReward,
            ),
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06C968),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/app logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const Spacer(flex: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 54),
              child: _LoadingBar(progress: progress),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}

class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF202625),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFF17201D), width: 2),
      ),
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 80),
                    curve: Curves.easeOut,
                    widthFactor: progress / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF21BCEA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              '${progress.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: Color(0xFF18211F), offset: Offset(1.5, 1.5)),
                  Shadow(color: Color(0xFF18211F), offset: Offset(-1, -1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
