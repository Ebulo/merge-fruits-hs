import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/fruit_merge_controller.dart';
import '../models/fruit.dart';

class FruitBoard extends StatefulWidget {
  const FruitBoard({super.key, required this.controller});

  final FruitMergeController controller;

  @override
  State<FruitBoard> createState() => _FruitBoardState();
}

class _FruitBoardState extends State<FruitBoard> {
  ui.Image? gamePadImage;

  final List<ui.Image?> fruitImages = List<ui.Image?>.filled(9, null);

  static const List<String> fruitImagePaths = [
    'assets/images/fruit1.png',
    'assets/images/fruit2.png',
    'assets/images/fruit3.png',
    'assets/images/fruit4.png',
    'assets/images/fruit5.png',
    'assets/images/fruit6.png',
    'assets/images/fruit7.png',
    'assets/images/fruit8.png',
    'assets/images/fruit9.png',
  ];

  @override
  void initState() {
    super.initState();

    _loadImages();
  }

  Future<void> _loadImages() async {
    await Future.wait([_loadGamePadImage(), _loadFruitImages()]);

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _loadGamePadImage() async {
    try {
      final data = await rootBundle.load('assets/images/game pad.png');

      final bytes = data.buffer.asUint8List();

      final codec = await ui.instantiateImageCodec(bytes);

      final frame = await codec.getNextFrame();

      gamePadImage = frame.image;
    } catch (error) {
      debugPrint('Game Pad Image Error: $error');
    }
  }

  Future<void> _loadFruitImages() async {
    for (int i = 0; i < fruitImagePaths.length; i++) {
      try {
        final data = await rootBundle.load(fruitImagePaths[i]);

        final bytes = data.buffer.asUint8List();

        final codec = await ui.instantiateImageCodec(bytes);

        final frame = await codec.getNextFrame();

        fruitImages[i] = frame.image;
      } catch (error) {
        debugPrint('Fruit ${i + 1} Image Error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        widget.controller.setArena(
          size,
          playableArea: _FruitPainter.playableArea(size),
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,

          onPanStart: (details) {
            widget.controller.moveHeld(details.localPosition.dx);
          },

          onPanUpdate: (details) {
            widget.controller.moveHeld(details.localPosition.dx);
          },

          onPanEnd: (_) {
            widget.controller.drop();
          },

          onTapUp: (details) {
            widget.controller.moveHeld(details.localPosition.dx);

            widget.controller.drop();
          },

          child: RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _FruitPainter(
                game: widget.controller,
                gamePadImage: gamePadImage,
                fruitImages: fruitImages,
              ),
            ),
          ),
        );
      },
    );
  }
}

// =================================================================
// PAINTER
// =================================================================

class _FruitPainter extends CustomPainter {
  const _FruitPainter({
    required this.game,
    required this.gamePadImage,
    required this.fruitImages,
  });

  final FruitMergeController game;

  final ui.Image? gamePadImage;

  final List<ui.Image?> fruitImages;

  static const List<Color> fallbackColors = [
    Color(0xFFA96DE8),
    Color(0xFF349DEB),
    Color(0xFFF02D59),
    Color(0xFFFFD526),
    Color(0xFFFF751B),
    Color(0xFF20CA00),
    Color(0xFFFF7B83),
    Color(0xFFAD5518),
    Color(0xFFE9004B),
  ];

  // These coordinates match the inner black area of game pad.png. The image
  // is scaled with the board, so deriving the bounds from it keeps the visual
  // tray and the collision walls aligned on every screen size.
  static const double _imageWidth = 1207;
  static const double _imageHeight = 1770;
  static const double _innerLeft = 92;
  static const double _innerRight = 1112;
  static const double _innerBottom = 1208;

  static Rect trayRect(Size size) {
    return Rect.fromLTWH(
      0,
      FruitMergeController.dangerLine,
      size.width,
      size.height - FruitMergeController.dangerLine,
    );
  }

  static Rect playableArea(Size size) {
    final tray = trayRect(size);

    return Rect.fromLTRB(
      tray.left + tray.width * (_innerLeft / _imageWidth),
      tray.top,
      tray.left + tray.width * (_innerRight / _imageWidth),
      tray.top + tray.height * (_innerBottom / _imageHeight),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final board = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(5),
    );

    canvas.save();

    canvas.clipRRect(board);

    _drawBackground(canvas, size);

    _drawDangerLine(canvas, size);

    if (game.heldFruit != null) {
      _drawTrajectory(canvas, size);
    }

    for (final fruit in game.fruits) {
      _drawFruit(canvas, fruit);
    }

    _drawMergeParticles(canvas);

    if (game.comboText.isNotEmpty && game.comboLife > 0) {
      _drawCombo(canvas);
    }

    canvas.restore();
  }

  // ===============================================================
  // BACKGROUND
  // ===============================================================

  void _drawBackground(Canvas canvas, Size size) {
    final gameArea = trayRect(size);

    if (gamePadImage != null) {
      canvas.drawImageRect(
        gamePadImage!,
        Rect.fromLTWH(
          0,
          0,
          gamePadImage!.width.toDouble(),
          gamePadImage!.height.toDouble(),
        ),
        gameArea,
        Paint()..filterQuality = FilterQuality.high,
      );
    }
  }

  // ===============================================================
  // DANGER LINE
  // ===============================================================

  void _drawDangerLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFC82E)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    double x = 9;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, FruitMergeController.dangerLine),
        Offset(min(x + 18, size.width), FruitMergeController.dangerLine),
        paint,
      );

      x += 31;
    }
  }

  // ===============================================================
  // TRAJECTORY
  // ===============================================================

  void _drawTrajectory(Canvas canvas, Size size) {
    final x = game.heldFruit!.position.dx;

    double y = FruitMergeController.dangerLine + 18;

    final maxY = min(size.height * 0.42, y + 180);

    double opacity = 0.85;

    while (y < maxY) {
      canvas.drawCircle(
        Offset(x, y),
        5.5,
        Paint()..color = const Color(0xFF349DEB).withValues(alpha: opacity),
      );

      y += 22;

      opacity = max(0.10, opacity - 0.11);
    }
  }

  // ===============================================================
  // FRUIT
  // ===============================================================

  void _drawFruit(Canvas canvas, Fruit fruit) {
    final safeLevel = fruit.level.clamp(0, fruitImages.length - 1);

    final radius = game.radius(fruit);

    double scaleX = fruit.scale;

    double scaleY = fruit.scale;

    // LANDING SQUASH

    if (fruit.squash > 0) {
      final animation = sin(fruit.squash * pi);

      scaleX += animation * 0.12;

      scaleY -= animation * 0.12;
    }

    // NEW FRUIT POP

    if (fruit.popLife > 0) {
      final progress = 1 - fruit.popLife;

      double popScale;

      if (progress < 0.45) {
        popScale = 0.35 + (progress / 0.45) * 1.05;
      } else {
        final bounce = (progress - 0.45) / 0.55;

        popScale = 1.4 - (bounce * 0.4) + sin(bounce * pi * 2) * 0.08;
      }

      scaleX *= popScale;

      scaleY *= popScale;
    }

    // SHADOW

    if (!fruit.isMerging) {
      canvas.drawOval(
        Rect.fromCenter(
          center: fruit.position + Offset(0, radius * 0.75),
          width: radius * 1.5,
          height: radius * 0.35,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.12),
      );
    }

    canvas.save();

    canvas.translate(fruit.position.dx, fruit.position.dy);

    canvas.rotate(fruit.rotation);

    canvas.scale(scaleX, scaleY);

    final image = fruitImages[safeLevel];

    if (image != null) {
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 2.1,
          height: radius * 2.1,
        ),
        Paint()..filterQuality = FilterQuality.high,
      );
    } else {
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()..color = fallbackColors[safeLevel],
      );
    }

    canvas.restore();
  }

  // ===============================================================
  // PARTICLES
  // ===============================================================

  void _drawMergeParticles(Canvas canvas) {
    for (final particle in game.mergeParticles) {
      final safeLevel = particle.level.clamp(0, fallbackColors.length - 1);

      final opacity = particle.life.clamp(0.0, 1.0);

      // OUTER GLOW

      canvas.drawCircle(
        particle.position,
        particle.size * opacity * 2.2,
        Paint()
          ..color = fallbackColors[safeLevel].withValues(alpha: opacity * 0.18),
      );

      // MAIN PARTICLE

      canvas.drawCircle(
        particle.position,
        particle.size * opacity,
        Paint()..color = fallbackColors[safeLevel].withValues(alpha: opacity),
      );
    }
  }

  // ===============================================================
  // COMBO 2X / 3X / 4X
  // ===============================================================

  void _drawCombo(Canvas canvas) {
    final opacity = game.comboLife.clamp(0.0, 1.0);

    canvas.save();

    canvas.translate(game.comboPosition.dx, game.comboPosition.dy);

    canvas.scale(game.comboScale, game.comboScale);

    final strokeText = TextPainter(
      text: TextSpan(
        text: game.comboText,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 7
            ..strokeJoin = StrokeJoin.round
            ..color = Colors.white.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final mainText = TextPainter(
      text: TextSpan(
        text: game.comboText,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFF5A2D).withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(-mainText.width / 2, -mainText.height / 2);

    strokeText.paint(canvas, offset);

    mainText.paint(canvas, offset);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FruitPainter oldDelegate) {
    return true;
  }
}
