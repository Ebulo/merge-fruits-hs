import 'package:flutter/material.dart';

import '../controllers/fruit_merge_controller.dart';
import '../services/progress_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/settings_service.dart';
import '../widgets/fruit_board.dart';
import '../widgets/level_success_popup.dart';
import 'game_settings_screen.dart';
import '../services/banner_ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FruitMergeGameScreen extends StatefulWidget {
  const FruitMergeGameScreen({
    super.key,
    required this.progress,
    required this.settings,
    this.startingLevel = 1,
  });

  final ProgressService progress;
  final SettingsService settings;
  final int startingLevel;

  @override
  State<FruitMergeGameScreen> createState() => _FruitMergeGameScreenState();
}

class _FruitMergeGameScreenState extends State<FruitMergeGameScreen> {
  late final FruitMergeController game;

  bool bestScoreSaved = false;
  bool levelUnlockSaved = false;
  bool _isAdvancingLevel = false;

  @override
  void initState() {
    super.initState();

    game = FruitMergeController(
      startingLevel: widget.startingLevel,
      settingsService: widget.settings,
    );

    BannerAdService.loadBanner(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    BannerAdService.dispose();

    game.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: game,
      builder: (context, _) {
        _handleGameState();

        return Scaffold(
          backgroundColor: const Color(0xFFFAE3B8),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _topArea(),

                    Expanded(child: FruitBoard(controller: game)),

                    if (BannerAdService.isLoaded &&
                        BannerAdService.bannerAd != null)
                      SizedBox(
                        width: BannerAdService.bannerAd!.size.width.toDouble(),
                        height: BannerAdService.bannerAd!.size.height
                            .toDouble(),
                        child: AdWidget(ad: BannerAdService.bannerAd!),
                      ),
                  ],
                ),

                if (game.state == MergeState.levelComplete)
                  LevelSuccessPopup(
                    level: game.currentLevel,
                    score: game.score,
                    onNextLevel: _nextLevel,
                    onHome: _goHome,
                  ),

                if (game.state == MergeState.gameOver) _gameOver(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HANDLE GAME STATE
  // ============================================================

  void _handleGameState() {
    if (game.state == MergeState.levelComplete && !levelUnlockSaved) {
      levelUnlockSaved = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await widget.progress.saveBest(game.score);

        await widget.progress.unlockLevel(game.currentLevel + 1);
      });
    }

    if (game.state == MergeState.gameOver && !bestScoreSaved) {
      bestScoreSaved = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.progress.saveBest(game.score);
      });
    }
  }

  // ============================================================
  // TOP AREA
  // ============================================================

  Widget _topArea() {
    return SizedBox(
      height: 125,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 15, top: 40, child: _backButton()),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 35),
              child: _levelCard(),
            ),
          ),

          Positioned(right: 15, top: 40, child: _settingsButton()),
        ],
      ),
    );
  }

  // ============================================================
  // BACK BUTTON
  // ============================================================

  Widget _backButton() {
    return GestureDetector(
      onTap: _goHome,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        'assets/images/Back.png',
        width: 52,
        height: 52,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFFA84B00),
              size: 35,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // LEVEL CARD
  // ============================================================

  Widget _levelCard() {
    return SizedBox(
      width: 102,
      height: 65,
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // MAIN CARD
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Container(
              height: 53,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCE5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD69A), width: 2.3),
              ),
            ),
          ),

          // LEVEL TITLE
          Positioned(
            top: 0,
            child: Container(
              width: 72,
              height: 19,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCE5),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: const Color(0xFFFFD69A), width: 2.3),
              ),
              child: Text(
                'Level ${game.currentLevel}',
                style: const TextStyle(
                  color: Color(0xFFA94A00),
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ),
          ),

          // PROGRESS BAR
          Positioned(
            top: 23,
            child: Container(
              width: 73,
              height: 9,
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: const Color(0xFF963600),
                borderRadius: BorderRadius.circular(3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: game.levelProgress.clamp(0.02, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFB8EA48), Color(0xFF73BD20)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // SCORE / TARGET
          Positioned(
            top: 36,
            child: Text(
              '${game.score} / ${game.levelTarget}',
              style: const TextStyle(
                color: Color(0xFFA63F00),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS BUTTON
  // ============================================================

  Widget _settingsButton() {
    return GestureDetector(
      onTap: _openSettings,
      behavior: HitTestBehavior.opaque,
      child: Image.asset(
        'assets/images/Setting1.png',
        width: 52,
        height: 52,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.settings_rounded,
              color: Color(0xFFA84B00),
              size: 38,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // OPEN SETTINGS
  // ============================================================

  Future<void> _openSettings() async {
    game.playButtonSound();
    final result = await Navigator.push<SettingsGameAction>(
      context,
      MaterialPageRoute(
        builder: (_) => GameSettingsScreen(
          settings: widget.settings,
          openSource: SettingsOpenSource.game,
        ),
      ),
    );

    if (!mounted) return;

    if (result == SettingsGameAction.restart) {
      bestScoreSaved = false;
      levelUnlockSaved = false;

      game.restartLevel();
    }

    if (result == SettingsGameAction.home) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // NEXT LEVEL
  // ============================================================

  Future<void> _nextLevel() async {
    if (_isAdvancingLevel) return;

    _isAdvancingLevel = true;

    await game.playButtonSound();

    await InterstitialAdService.showIfAvailable();

    if (!mounted) return;

    await widget.progress.unlockLevel(game.currentLevel + 1);

    bestScoreSaved = false;
    levelUnlockSaved = false;

    game.nextGameLevel();

    _isAdvancingLevel = false;
  }
  // ============================================================
  // GO HOME
  // ============================================================

  void _goHome() {
    game.playButtonSound();
    Navigator.pop(context);
  }

  // ============================================================
  // GAME OVER
  // ============================================================

  Widget _gameOver() {
    final best = widget.progress.bestScore > game.score
        ? widget.progress.bestScore
        : game.score;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.48),
        alignment: Alignment.center,
        child: Container(
          width: 270,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFAE3B8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFC77F), width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Color(0xFFA84B00),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'LEVEL ${game.currentLevel}',
                style: const TextStyle(
                  color: Color(0xFF8B664C),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                '${game.score}',
                style: const TextStyle(
                  color: Color(0xFFA84B00),
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'SCORE',
                style: TextStyle(
                  color: Color(0xFF9A7C67),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'BEST  $best',
                style: const TextStyle(
                  color: Color(0xFF765B49),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8A3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  onPressed: () {
                    game.playButtonSound();
                    bestScoreSaved = false;
                    levelUnlockSaved = false;

                    game.restartLevel();
                  },
                  child: const Text(
                    'RETRY LEVEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 7),

              TextButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home_rounded, color: Color(0xFFA84B00)),
                label: const Text(
                  'HOME',
                  style: TextStyle(
                    color: Color(0xFFA84B00),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
