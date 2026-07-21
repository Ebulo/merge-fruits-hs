import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:prism_paths/controllers/fruit_merge_controller.dart';
import 'package:prism_paths/services/settings_service.dart';

void main() {
  test('game spawns a held fruit after arena is ready', () {
    final game = _createGame();
    game.setArena(const Size(360, 500));
    expect(game.heldFruit, isNotNull);
    game.dispose();
  });
  test('dropping fruit releases it', () {
    final game = _createGame();
    game.setArena(const Size(360, 500));
    game.drop();
    expect(game.heldFruit, isNull);
    expect(game.fruits.first.held, isFalse);
    game.dispose();
  });
}

FruitMergeController _createGame() {
  final settings = SettingsService()..soundEnabled = false;
  return FruitMergeController(settingsService: settings);
}
