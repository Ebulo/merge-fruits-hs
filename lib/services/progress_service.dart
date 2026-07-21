import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService extends ChangeNotifier {
  static const String _bestScoreKey = 'best_score';
  static const String _unlockedLevelKey = 'unlocked_level';
  static const String _coinsKey = 'coins';

  int bestScore = 0;
  int unlockedLevel = 1;
  int coins = 0;

  // Current playable level
  int get currentLevel => unlockedLevel;

  // ============================================================
  // LOAD SAVED PROGRESS
  // ============================================================

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    unlockedLevel = prefs.getInt(_unlockedLevelKey) ?? 1;
    coins = prefs.getInt(_coinsKey) ?? 0;

    // Safety check
    if (unlockedLevel < 1) {
      unlockedLevel = 1;
    }

    if (coins < 0) {
      coins = 0;
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

    await prefs.setInt(_bestScoreKey, bestScore);

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

    await prefs.setInt(_unlockedLevelKey, unlockedLevel);

    notifyListeners();
  }

  // ============================================================
  // LEVEL COMPLETE
  // ============================================================

  Future<void> completeLevel(int completedLevel) async {
    final nextLevel = completedLevel + 1;

    await unlockLevel(nextLevel);
  }

  Future<void> addCoins(int amount) async {
    if (amount <= 0) {
      return;
    }

    coins += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_coinsKey, coins);
    notifyListeners();
  }

  // ============================================================
  // RESET ALL PROGRESS
  // ============================================================

  Future<void> resetProgress() async {
    bestScore = 0;
    unlockedLevel = 1;
    coins = 0;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_bestScoreKey, 0);

    await prefs.setInt(_unlockedLevelKey, 1);

    await prefs.setInt(_coinsKey, 0);

    notifyListeners();
  }
}
