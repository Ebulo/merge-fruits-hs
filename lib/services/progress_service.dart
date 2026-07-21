import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  static const String _bestScoreKey = 'best_score';
  static const String _unlockedLevelKey = 'unlocked_level';

  int bestScore = 0;
  int unlockedLevel = 1;

  // Current playable level
  int get currentLevel => unlockedLevel;

  // ============================================================
  // LOAD SAVED PROGRESS
  // ============================================================

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    unlockedLevel = prefs.getInt(_unlockedLevelKey) ?? 1;

    // Safety check
    if (unlockedLevel < 1) {
      unlockedLevel = 1;
    }

    notifyListeners();
  }

  // ============================================================
  // SAVE BEST SCORE
  // ============================================================

  Future<void> saveBest(int score) async {
    if (score <= bestScore) {
      return;
    }

    bestScore = score;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _bestScoreKey,
      bestScore,
    );

    notifyListeners();
  }

  // ============================================================
  // UNLOCK / SAVE NEXT LEVEL
  // ============================================================

  Future<void> unlockLevel(int level) async {
    // Purana ya same level dobara save nahi hoga
    if (level <= unlockedLevel) {
      return;
    }

    unlockedLevel = level;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _unlockedLevelKey,
      unlockedLevel,
    );

    notifyListeners();
  }

  // ============================================================
  // LEVEL COMPLETE
  // ============================================================

  Future<void> completeLevel(int completedLevel) async {
    final nextLevel = completedLevel + 1;

    await unlockLevel(nextLevel);
  }

  // ============================================================
  // RESET ALL PROGRESS
  // ============================================================

  Future<void> resetProgress() async {
    bestScore = 0;
    unlockedLevel = 1;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _bestScoreKey,
      0,
    );

    await prefs.setInt(
      _unlockedLevelKey,
      1,
    );

    notifyListeners();
  }
}