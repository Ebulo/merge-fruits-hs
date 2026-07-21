import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/fruit.dart';
import '../services/settings_service.dart';
import '../services/sound_effects.dart';

enum MergeState { ready, playing, levelComplete, gameOver }

class FruitMergeController extends ChangeNotifier {
  FruitMergeController({
    int startingLevel = 1,
    SettingsService? settingsService,
  }) : settingsService = settingsService ?? SettingsService(),
       currentLevel = startingLevel {
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _tick());
  }

  final SettingsService settingsService;

  late final Timer _timer;

  final Random _random = Random();

  // =============================================================
  // AUDIO PLAYERS
  // =============================================================

  AudioPlayer? _mergeSoundPlayer;

  AudioPlayer? _comboSoundPlayer;

  AudioPlayer? _levelSoundPlayer;

  // =============================================================
  // GAME DATA
  // =============================================================

  final List<Fruit> fruits = [];

  final List<MergeParticle> mergeParticles = [];

  final List<PendingMerge> pendingMerges = [];

  Size arena = Size.zero;

  /// The inside edge of the visible tray. Keeping physics inside this rect
  /// prevents fruits from landing on the decorative frame below the tray.
  Rect playableArea = Rect.zero;

  Fruit? heldFruit;

  MergeState state = MergeState.ready;

  int currentLevel;

  int score = 0;

  int combo = 0;

  int nextLevel = 0;

  int _id = 0;

  double _spawnWait = 0;

  double _dangerSeconds = 0;

  // =============================================================
  // COMBO
  // =============================================================

  String comboText = '';

  Offset comboPosition = Offset.zero;

  double comboLife = 0;

  double comboScale = 1;

  double _comboTimer = 0;

  static const double comboTimeout = 0.90;

  // =============================================================
  // GAME BOARD
  // =============================================================

  static const double dangerLine = 105;

  static const double gameLeft = 34;

  static const double gameRight = 34;

  static const double gameBottom = 105;

  static const double gravity = 1350;

  static const double spawnDelay = 0.32;

  // =============================================================
  // FRUIT SIZES
  // =============================================================

  static const List<double> radii = [
    18,
    24,
    31,
    39,
    49,
    61,
    75,
    90,
    106,
    122,
    138,
  ];

  // =============================================================
  // LEVEL
  // =============================================================

  int get levelTarget {
    return 1000 + ((currentLevel - 1) * 100);
  }

  double get levelProgress {
    if (levelTarget <= 0) {
      return 0;
    }

    return (score / levelTarget).clamp(0.0, 1.0);
  }

  // =============================================================
  // BOARD POSITION
  // =============================================================

  double get leftWall {
    return playableArea == Rect.zero ? gameLeft : playableArea.left;
  }

  double get rightWall {
    return playableArea == Rect.zero
        ? arena.width - gameRight
        : playableArea.right;
  }

  double get bottomFloor {
    return playableArea == Rect.zero
        ? arena.height - gameBottom
        : playableArea.bottom;
  }

  double get gameCenter {
    return leftWall + ((rightWall - leftWall) / 2);
  }

  // =============================================================
  // FRUIT RADIUS
  // =============================================================

  double radius(Fruit fruit) {
    return radii[fruit.level.clamp(0, radii.length - 1)];
  }

  // =============================================================
  // SOUND
  // =============================================================

  Future<void> _playMergeSound(String fileName) async {
    if (!settingsService.soundEnabled) {
      return;
    }

    try {
      final player = _mergeSoundPlayer ??= AudioPlayer();
      await player.stop();

      await player.play(AssetSource('images/sounds/$fileName'));
    } catch (error) {
      debugPrint('Merge Sound Error: $error');
    }
  }

  Future<void> _playComboSound(String fileName) async {
    if (!settingsService.soundEnabled) {
      return;
    }

    try {
      final player = _comboSoundPlayer ??= AudioPlayer();
      await player.stop();

      await player.play(AssetSource('images/sounds/$fileName'));
    } catch (error) {
      debugPrint('Combo Sound Error: $error');
    }
  }

  Future<void> _playLevelSound() async {
    if (!settingsService.soundEnabled) {
      return;
    }

    try {
      final player = _levelSoundPlayer ??= AudioPlayer();
      await player.stop();

      await player.play(AssetSource('images/sounds/level_complete.mp3'));
    } catch (error) {
      debugPrint('Level Sound Error: $error');
    }
  }

  Future<void> playButtonSound() async {
    await SoundEffects.playButtonTap(settingsService);
  }

  // =============================================================
  // SET ARENA
  // =============================================================

  void setArena(Size size, {Rect? playableArea}) {
    if (size.width < 10 || size.height < 10) {
      return;
    }

    final nextPlayableArea = playableArea ?? Rect.zero;

    if (arena == size && this.playableArea == nextPlayableArea) {
      return;
    }

    arena = size;

    this.playableArea = nextPlayableArea;

    if (state == MergeState.ready) {
      startLevel(currentLevel);
    }
  }

  // =============================================================
  // START LEVEL
  // =============================================================

  void startLevel(int level) {
    currentLevel = level;

    fruits.clear();

    mergeParticles.clear();

    pendingMerges.clear();

    heldFruit = null;

    score = 0;

    combo = 0;

    nextLevel = 0;

    _id = 0;

    _spawnWait = 0;

    _dangerSeconds = 0;

    _comboTimer = 0;

    comboText = '';

    comboLife = 0;

    comboScale = 1;

    state = MergeState.playing;

    _spawn();

    notifyListeners();
  }

  // =============================================================
  // RESTART
  // =============================================================

  void restartLevel() {
    startLevel(currentLevel);
  }

  // =============================================================
  // NEXT LEVEL
  // =============================================================

  void nextGameLevel() {
    startLevel(currentLevel + 1);
  }

  // =============================================================
  // MOVE HELD FRUIT
  // =============================================================

  void moveHeld(double x) {
    if (state != MergeState.playing) {
      return;
    }

    if (heldFruit == null) {
      return;
    }

    final fruit = heldFruit!;

    final r = radius(fruit);

    fruit.position = Offset(x.clamp(leftWall + r, rightWall - r), 55);

    notifyListeners();
  }

  // =============================================================
  // DROP
  // =============================================================

  void drop() {
    if (state != MergeState.playing) {
      return;
    }

    if (heldFruit == null) {
      return;
    }

    final fruit = heldFruit!;

    fruit.held = false;

    fruit.velocity = Offset((_random.nextDouble() - 0.5) * 25, 100);

    fruit.rotationSpeed = (_random.nextDouble() - 0.5) * 4.5;

    fruit.squash = 0;

    heldFruit = null;

    _spawnWait = spawnDelay;

    notifyListeners();
  }

  // =============================================================
  // SPAWN
  // =============================================================

  void _spawn() {
    if (arena == Size.zero) {
      return;
    }

    if (state != MergeState.playing) {
      return;
    }

    if (heldFruit != null) {
      return;
    }

    final chance = _random.nextInt(100);

    int level;

    if (chance < 58) {
      level = 0;
    } else if (chance < 87) {
      level = 1;
    } else {
      level = 2;
    }

    nextLevel = level;

    final fruit = Fruit(
      id: _id++,
      level: level,
      position: Offset(gameCenter, 55),
      held: true,
    );

    fruits.add(fruit);

    heldFruit = fruit;
  }

  // =============================================================
  // HAMMER
  // =============================================================

  void useHammer() {
    if (state != MergeState.playing) {
      return;
    }

    Fruit? biggestFruit;

    for (final fruit in fruits) {
      if (fruit.held || fruit.isMerging) {
        continue;
      }

      if (biggestFruit == null || fruit.level > biggestFruit.level) {
        biggestFruit = fruit;
      }
    }

    if (biggestFruit == null) {
      return;
    }

    playButtonSound();

    comboText = 'BOOM!';

    comboPosition = biggestFruit.position;

    comboLife = 0.8;

    comboScale = 1;

    _createMergeParticles(biggestFruit.position, biggestFruit.level, 16);

    fruits.remove(biggestFruit);

    notifyListeners();
  }

  // =============================================================
  // SHUFFLE
  // =============================================================

  void useShuffle() {
    if (state != MergeState.playing) {
      return;
    }

    playButtonSound();

    for (final fruit in fruits) {
      if (fruit.held || fruit.isMerging) {
        continue;
      }

      fruit.velocity = Offset(
        (_random.nextDouble() - 0.5) * 400,
        -350 - (_random.nextDouble() * 250),
      );

      fruit.rotationSpeed = (_random.nextDouble() - 0.5) * 7;
    }

    comboText = 'SHAKE!';

    comboPosition = Offset(
      gameCenter,
      dangerLine + ((bottomFloor - dangerLine) / 2),
    );

    comboLife = 0.8;

    comboScale = 1;

    notifyListeners();
  }

  // =============================================================
  // GAME LOOP
  // =============================================================

  void _tick() {
    if (state != MergeState.playing) {
      return;
    }

    if (arena == Size.zero) {
      return;
    }

    const dt = 0.016;

    _updateCombo(dt);

    _updateParticles(dt);

    _updateSpawn(dt);

    _updatePendingMerges(dt);

    _updateFruits(dt);

    _collide();

    // ===========================================================
    // LEVEL COMPLETE
    // ===========================================================

    if (score >= levelTarget) {
      score = levelTarget;

      state = MergeState.levelComplete;

      _playLevelSound();

      notifyListeners();

      return;
    }

    _checkDanger(dt);

    notifyListeners();
  }

  // =============================================================
  // COMBO UPDATE
  // =============================================================

  void _updateCombo(double dt) {
    if (_comboTimer > 0) {
      _comboTimer -= dt;

      if (_comboTimer <= 0) {
        combo = 0;
      }
    }

    if (comboLife <= 0) {
      return;
    }

    comboLife -= dt * 1.35;

    comboPosition = Offset(comboPosition.dx, comboPosition.dy - (32 * dt));

    final life = comboLife.clamp(0.0, 1.0);

    final progress = 1 - life;

    if (progress < 0.25) {
      comboScale = 0.5 + (progress * 3.2);
    } else {
      comboScale = 1.3 - ((progress - 0.25) * 0.35);
    }

    if (comboLife <= 0) {
      comboText = '';

      comboScale = 1;
    }
  }

  // =============================================================
  // PARTICLES UPDATE
  // =============================================================

  void _updateParticles(double dt) {
    for (final particle in mergeParticles) {
      particle.life -= dt * 1.8;

      particle.velocity = Offset(
        particle.velocity.dx * 0.96,
        particle.velocity.dy + (350 * dt),
      );

      particle.position += particle.velocity * dt;
    }

    mergeParticles.removeWhere((particle) => particle.life <= 0);
  }

  // =============================================================
  // SPAWN UPDATE
  // =============================================================

  void _updateSpawn(double dt) {
    if (heldFruit != null) {
      return;
    }

    _spawnWait -= dt;

    if (_spawnWait <= 0) {
      _spawn();
    }
  }

  // =============================================================
  // PENDING MERGE ANIMATION
  // =============================================================

  void _updatePendingMerges(double dt) {
    if (pendingMerges.isEmpty) {
      return;
    }

    final completed = <PendingMerge>[];

    for (final merge in pendingMerges) {
      merge.progress += dt * 7;

      final progress = merge.progress.clamp(0.0, 1.0);

      final eased = Curves.easeInCubic.transform(progress);

      merge.first.position =
          Offset.lerp(merge.first.position, merge.position, eased) ??
          merge.position;

      merge.second.position =
          Offset.lerp(merge.second.position, merge.position, eased) ??
          merge.position;

      merge.first.scale = 1 - (progress * 0.85);

      merge.second.scale = 1 - (progress * 0.85);

      merge.first.rotation += dt * 5;

      merge.second.rotation -= dt * 5;

      if (merge.progress >= 1) {
        completed.add(merge);
      }
    }

    for (final merge in completed) {
      _finishMerge(merge);

      pendingMerges.remove(merge);
    }
  }

  // =============================================================
  // FINISH MERGE
  // =============================================================

  void _finishMerge(PendingMerge merge) {
    fruits.remove(merge.first);

    fruits.remove(merge.second);

    _createMergeParticles(merge.position, merge.newLevel, 18);

    final mergedFruit = Fruit(
      id: _id++,
      level: merge.newLevel,
      position: merge.position,
      velocity: Offset(merge.velocity.dx * 0.20, -165),
      rotation: (_random.nextDouble() - 0.5) * 0.25,
      rotationSpeed: (_random.nextDouble() - 0.5) * 2,
      popLife: 1.0,
      scale: 1,
    );

    fruits.add(mergedFruit);

    // ===========================================================
    // COMBO
    // ===========================================================

    combo++;

    _comboTimer = comboTimeout;

    unawaited(SoundEffects.playMergeHaptic(settingsService, combo));

    // ===========================================================
    // SOUND
    // ===========================================================

    if (combo == 1) {
      _playMergeSound('fruit_merge.mp3');
    } else if (combo == 2) {
      _playComboSound('combo_2x.mp3');
    } else if (combo == 3) {
      _playComboSound('combo_3x.mp3');
    } else {
      _playComboSound('combo_high.mp3');
    }

    // ===========================================================
    // SCORE
    // ===========================================================

    final multiplier = max(1, combo);

    score += (merge.newLevel + 1) * 10 * multiplier;

    // ===========================================================
    // COMBO TEXT
    // ===========================================================

    if (combo >= 2) {
      comboText = '${combo}x';

      comboPosition = merge.position;

      comboLife = 1;

      comboScale = 0.45;
    }
  }

  // =============================================================
  // FRUIT PHYSICS
  // =============================================================

  void _updateFruits(double dt) {
    for (final fruit in fruits) {
      fruit.age += dt;

      if (fruit.isMerging) {
        continue;
      }

      // =========================================================
      // POP
      // =========================================================

      if (fruit.popLife > 0) {
        fruit.popLife -= dt * 3.2;

        if (fruit.popLife < 0) {
          fruit.popLife = 0;
        }
      }

      // =========================================================
      // SQUASH
      // =========================================================

      if (fruit.squash > 0) {
        fruit.squash -= dt * 4.5;

        if (fruit.squash < 0) {
          fruit.squash = 0;
        }
      }

      if (fruit.held) {
        continue;
      }

      // =========================================================
      // ROTATION
      // =========================================================

      fruit.rotation += fruit.rotationSpeed * dt;

      fruit.rotationSpeed *= 0.995;

      // =========================================================
      // GRAVITY
      // =========================================================

      fruit.velocity = Offset(
        fruit.velocity.dx * 0.992,
        fruit.velocity.dy + (gravity * dt),
      );

      fruit.position += fruit.velocity * dt;

      final r = radius(fruit);

      // =========================================================
      // LEFT WALL
      // =========================================================

      if (fruit.position.dx - r < leftWall) {
        fruit.position = Offset(leftWall + r, fruit.position.dy);

        fruit.velocity = Offset(-fruit.velocity.dx * 0.42, fruit.velocity.dy);

        fruit.rotationSpeed *= -0.7;

        fruit.squash = max(fruit.squash, 0.25);
      }

      // =========================================================
      // RIGHT WALL
      // =========================================================

      if (fruit.position.dx + r > rightWall) {
        fruit.position = Offset(rightWall - r, fruit.position.dy);

        fruit.velocity = Offset(-fruit.velocity.dx * 0.42, fruit.velocity.dy);

        fruit.rotationSpeed *= -0.7;

        fruit.squash = max(fruit.squash, 0.25);
      }

      // =========================================================
      // FLOOR
      // =========================================================

      if (fruit.position.dy + r > bottomFloor) {
        final impactSpeed = fruit.velocity.dy.abs();

        fruit.position = Offset(fruit.position.dx, bottomFloor - r);

        fruit.velocity = Offset(
          fruit.velocity.dx * 0.72,
          -fruit.velocity.dy * 0.24,
        );

        fruit.rotationSpeed *= 0.75;

        if (impactSpeed > 130) {
          fruit.squash = min(1.0, impactSpeed / 850);
        }
      }
    }
  }

  // =============================================================
  // DANGER
  // =============================================================

  void _checkDanger(double dt) {
    final danger = fruits.any(
      (fruit) =>
          !fruit.held &&
          !fruit.isMerging &&
          fruit.position.dy - radius(fruit) < dangerLine,
    );

    if (danger) {
      _dangerSeconds += dt;
    } else {
      _dangerSeconds = max(0, _dangerSeconds - (dt * 2));
    }

    if (_dangerSeconds > 1.6) {
      state = MergeState.gameOver;
    }
  }

  // =============================================================
  // COLLISION
  // =============================================================

  void _collide() {
    for (int i = 0; i < fruits.length; i++) {
      final a = fruits[i];

      if (a.held || a.isMerging) {
        continue;
      }

      for (int j = i + 1; j < fruits.length; j++) {
        final b = fruits[j];

        if (b.held || b.isMerging) {
          continue;
        }

        final minDistance = radius(a) + radius(b);

        final delta = b.position - a.position;

        final distance = delta.distance;

        if (distance >= minDistance || distance == 0) {
          continue;
        }

        final normal = delta / distance;

        final overlap = minDistance - distance;

        // =======================================================
        // SAME FRUIT MERGE
        // =======================================================

        if (a.level == b.level && a.level < radii.length - 1) {
          _startMerge(a, b);

          break;
        }

        // =======================================================
        // NORMAL COLLISION
        // =======================================================

        a.position -= normal * (overlap / 2);

        b.position += normal * (overlap / 2);

        final relativeVelocity = b.velocity - a.velocity;

        final impact =
            (relativeVelocity.dx * normal.dx) +
            (relativeVelocity.dy * normal.dy);

        if (impact < 0) {
          final impulse = normal * (-impact * 0.62);

          a.velocity -= impulse;

          b.velocity += impulse;

          final collisionStrength = min(1.0, impact.abs() / 600);

          if (collisionStrength > 0.15) {
            a.squash = max(a.squash, collisionStrength * 0.55);

            b.squash = max(b.squash, collisionStrength * 0.55);
          }
        }
      }
    }
  }

  // =============================================================
  // START MERGE
  // =============================================================

  void _startMerge(Fruit first, Fruit second) {
    if (first.isMerging || second.isMerging) {
      return;
    }

    final position = (first.position + second.position) / 2;

    final velocity = (first.velocity + second.velocity) / 2;

    first.isMerging = true;

    second.isMerging = true;

    first.mergeTarget = position;

    second.mergeTarget = position;

    first.velocity = Offset.zero;

    second.velocity = Offset.zero;

    pendingMerges.add(
      PendingMerge(
        first: first,
        second: second,
        position: position,
        newLevel: first.level + 1,
        velocity: velocity,
      ),
    );
  }

  // =============================================================
  // CREATE PARTICLES
  // =============================================================

  void _createMergeParticles(Offset position, int level, int count) {
    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * pi * 2;

      final speed = 90 + (_random.nextDouble() * 210);

      mergeParticles.add(
        MergeParticle(
          position: position,
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          level: level,
          life: 0.65 + (_random.nextDouble() * 0.35),
          size: 3 + (_random.nextDouble() * 6),
        ),
      );
    }
  }

  // =============================================================
  // DISPOSE
  // =============================================================

  @override
  void dispose() {
    _timer.cancel();

    _mergeSoundPlayer?.dispose();

    _comboSoundPlayer?.dispose();

    _levelSoundPlayer?.dispose();

    super.dispose();
  }
}
