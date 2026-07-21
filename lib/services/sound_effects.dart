import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'settings_service.dart';

/// Shared short UI sound effects used outside the game controller.
class SoundEffects {
  SoundEffects._();

  static AudioPlayer? _buttonPlayer;

  static Future<void> playButtonTap(SettingsService settings) async {
    if (!settings.soundEnabled) {
      return;
    }

    try {
      final player = _buttonPlayer ??= AudioPlayer();
      await player.stop();
      await player.play(AssetSource('images/sounds/button_click.mp3'));
    } catch (error) {
      debugPrint('Button sound error: $error');
    }
  }
}
