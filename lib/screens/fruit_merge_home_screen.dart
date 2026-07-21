import 'package:flutter/material.dart';

import '../services/daily_reward_service.dart';
import '../services/progress_service.dart';
import '../services/settings_service.dart';
import '../services/sound_effects.dart';
import '../widgets/daily_sign_in_card.dart';
import 'fruit_merge_game_screen.dart';
import 'game_settings_screen.dart';

class FruitMergeHomeScreen extends StatelessWidget {
  const FruitMergeHomeScreen({
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
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF9FE0F7),
          body: SafeArea(
            child: Stack(
              children: [
                // =====================================================
                // BACKGROUND
                // =====================================================
                const Positioned.fill(child: _StripedBackground()),

                // =====================================================
                // MAIN CONTENT
                // =====================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                  child: Column(
                    children: [
                      // =================================================
                      // TOP BAR
                      // =================================================
                      Row(
                        children: [
                          // =============================================
                          // PROFILE PNG + LEVEL + PROGRESS
                          // =============================================
                          _LevelProfileCard(level: progress.unlockedLevel),

                          const Spacer(),

                          _CoinChip(coins: progress.coins),

                          const SizedBox(width: 10),

                          // =============================================
                          // SETTINGS PNG
                          // =============================================
                          _SettingsButton(
                            onTap: () {
                              SoundEffects.playButtonTap(settings);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GameSettingsScreen(
                                    settings: settings,
                                    openSource: SettingsOpenSource.home,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      DailySignInCard(
                        dailyReward: dailyReward,
                        progress: progress,
                        settings: settings,
                      ),

                      // =================================================
                      // CENTER AREA
                      // =================================================
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final playButton = _PlayButton(
                              onTap: () {
                                SoundEffects.playButtonTap(settings);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FruitMergeGameScreen(
                                      progress: progress,
                                      settings: settings,
                                      startingLevel: progress.unlockedLevel,
                                    ),
                                  ),
                                );
                              },
                            );

                            if (constraints.maxHeight < 280) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/frutie logo.png',
                                    width: 185,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 46),
                                  playButton,
                                ],
                              );
                            }

                            return Column(
                              children: [
                                const Spacer(flex: 2),
                                Image.asset(
                                  'assets/images/frutie logo.png',
                                  width: 250,
                                  fit: BoxFit.contain,
                                ),
                                const Spacer(flex: 5),
                                playButton,
                                const SizedBox(height: 25),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4C7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFB83D), width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🍒', style: TextStyle(fontSize: 17)),
          const SizedBox(width: 5),
          Text(
            '$coins',
            style: const TextStyle(
              color: Color(0xFFA84B00),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// BACKGROUND
// =====================================================================

class _StripedBackground extends StatelessWidget {
  const _StripedBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const stripeWidth = 28.0;

    final lightPaint = Paint()..color = const Color(0xFFA9E4F8);

    final darkPaint = Paint()..color = const Color(0xFF98DCF5);

    for (double x = 0; x < size.width; x += stripeWidth) {
      final index = (x / stripeWidth).floor();

      canvas.drawRect(
        Rect.fromLTWH(x, 0, stripeWidth, size.height),
        index.isEven ? lightPaint : darkPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// =====================================================================
// PROFILE PNG + LEVEL + PROGRESS
// =====================================================================

class _LevelProfileCard extends StatelessWidget {
  const _LevelProfileCard({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ===========================================================
          // PROFILE PNG
          // ===========================================================
          Positioned.fill(
            child: Image.asset('assets/images/profile.png', fit: BoxFit.fill),
          ),

          // ===========================================================
          // LEVEL TEXT
          // ===========================================================
          Positioned(
            left: 60,
            top: 10,
            right: 1,
            child: Text(
              'Level $level',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(color: Color(0x66000000), offset: Offset(1, 1)),
                ],
              ),
            ),
          ),

          // ===========================================================
          // PROGRESS BAR
          // ===========================================================
          Positioned(
            left: 55,
            right: 8,
            bottom: 13,
            child: Container(
              height: 12,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                color: const Color(0xFF176FA8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: const LinearProgressIndicator(
                  value: 1,
                  minHeight: 6,
                  backgroundColor: Color(0xFF176FA8),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8DE33D)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// SETTINGS BUTTON WITH PNG
// =====================================================================

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        'assets/images/Setting.png',
        width: 50,
        height: 50,
        fit: BoxFit.contain,
      ),
    );
  }
}

// =====================================================================
// PLAY BUTTON
// =====================================================================

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        'assets/images/play button.png',
        width: 140,
        fit: BoxFit.contain,
      ),
    );
  }
}
