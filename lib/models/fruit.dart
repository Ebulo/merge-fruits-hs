import 'dart:ui';

class Fruit {
  Fruit({
    required this.id,
    required this.level,
    required this.position,
    this.velocity = Offset.zero,
    this.held = false,
    this.scale = 1.0,
    this.age = 0.0,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    this.squash = 0.0,
    this.popLife = 0.0,
    this.isMerging = false,
    this.mergeTarget = Offset.zero,
    this.mergeProgress = 0.0,
  });

  final int id;

  int level;

  Offset position;

  Offset velocity;

  bool held;

  double scale;

  double age;

  double rotation;

  double rotationSpeed;

  double squash;

  double popLife;

  bool isMerging;

  Offset mergeTarget;

  double mergeProgress;
}

class ComboEffect {
  ComboEffect({
    required this.position,
    required this.multiplier,
    this.life = 1.0,
  });

  Offset position;

  final int multiplier;

  double life;
}

class MergeParticle {
  MergeParticle({
    required this.position,
    required this.velocity,
    required this.level,
    this.life = 1.0,
    this.size = 5.0,
  });

  Offset position;

  Offset velocity;

  final int level;

  double life;

  double size;
}

class PendingMerge {
  PendingMerge({
    required this.first,
    required this.second,
    required this.position,
    required this.newLevel,
    required this.velocity,
  });

  final Fruit first;

  final Fruit second;

  final Offset position;

  final int newLevel;

  final Offset velocity;

  double progress = 0.0;
}