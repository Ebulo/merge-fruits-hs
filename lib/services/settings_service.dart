import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _soundKey = 'sound_enabled';
  static const String _vibrationKey = 'vibration_enabled';

  bool soundEnabled = true;
  bool vibrationEnabled = true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    soundEnabled = prefs.getBool(_soundKey) ?? true;
    vibrationEnabled = prefs.getBool(_vibrationKey) ?? true;

    notifyListeners();
  }

  Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, soundEnabled);
  }

  Future<void> toggleVibration() async {
    vibrationEnabled = !vibrationEnabled;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, vibrationEnabled);
  }
}
