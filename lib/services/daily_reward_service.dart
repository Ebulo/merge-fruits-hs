import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardService extends ChangeNotifier {
  static const String _currentDayKey = 'daily_reward_current_day';
  static const String _lastClaimDateKey = 'daily_reward_last_claim_date';

  int currentDay = 1;
  String? lastClaimDate;

  // ============================================================
  // LOAD SAVED DAILY REWARD DATA
  // ============================================================

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    currentDay = prefs.getInt(_currentDayKey) ?? 1;
    lastClaimDate = prefs.getString(_lastClaimDateKey);

    if (currentDay < 1) {
      currentDay = 1;
    }

    if (currentDay > 28) {
      currentDay = 28;
    }

    notifyListeners();
  }

  // ============================================================
  // TODAY DATE
  // ============================================================

  String get _todayDate {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // CHECK TODAY CLAIMED
  // ============================================================

  bool get claimedToday {
    return lastClaimDate == _todayDate;
  }

  // ============================================================
  // CAN CLAIM REWARD
  // ============================================================

  bool get canClaim {
    return !claimedToday;
  }

  // ============================================================
  // CURRENT REWARD
  // ============================================================

  int get currentReward {
    if (currentDay == 28) {
      return 1000;
    }

    if (currentDay % 7 == 0) {
      return 500;
    }

    return 100;
  }

  // ============================================================
  // CLAIM DAILY REWARD
  // ============================================================

  Future<bool> claimReward() async {
    if (!canClaim) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();

    lastClaimDate = _todayDate;

    await prefs.setString(
      _lastClaimDateKey,
      lastClaimDate!,
    );

    // Day 28 ke baad cycle dobara Day 1 se start hogi.
    if (currentDay >= 28) {
      currentDay = 1;
    } else {
      currentDay++;
    }

    await prefs.setInt(
      _currentDayKey,
      currentDay,
    );

    notifyListeners();

    return true;
  }

  // ============================================================
  // REWARD FOR SPECIFIC DAY
  // ============================================================

  int rewardForDay(int day) {
    if (day == 28) {
      return 1000;
    }

    if (day % 7 == 0) {
      return 500;
    }

    return 100;
  }

  // ============================================================
  // CHECK DAY COMPLETED
  // ============================================================

  bool isDayCompleted(int day) {
    if (claimedToday) {
      return day < currentDay;
    }

    return day < currentDay;
  }

  // ============================================================
  // CHECK CURRENT DAY
  // ============================================================

  bool isCurrentDay(int day) {
    return day == currentDay;
  }

  // ============================================================
  // RESET DAILY REWARD
  // ============================================================

  Future<void> reset() async {
    currentDay = 1;
    lastClaimDate = null;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_currentDayKey);
    await prefs.remove(_lastClaimDateKey);

    notifyListeners();
  }
}