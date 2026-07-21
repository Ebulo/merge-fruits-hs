import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'settings_service.dart';

/// Shared short UI sound effects used outside the game controller.
class SoundEffects {
  SoundEffects._();

  static AudioPlayer? _buttonPlayer;

  static Future<void> playButtonTap(SettingsService settings) async {
    if (settings.vibrationEnabled) {
      await HapticFeedback.selectionClick();
    }

    if (settings.soundEnabled) {
      try {
        final player = _buttonPlayer ??= AudioPlayer();
        await player.stop();
        await player.play(AssetSource('images/sounds/button_click.mp3'));
      } catch (error) {
        debugPrint('Button sound error: $error');
      }
    }
  }

  static Future<void> playMergeHaptic(
    SettingsService settings,
    int combo,
  ) async {
    if (!settings.vibrationEnabled) {
      return;
    }

    if (combo >= 3) {
      await HapticFeedback.heavyImpact();
    } else if (combo == 2) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.lightImpact();
    }
  }
}
