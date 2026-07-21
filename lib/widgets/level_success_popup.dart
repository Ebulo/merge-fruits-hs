import 'package:flutter/material.dart';

class LevelSuccessPopup extends StatelessWidget {
  const LevelSuccessPopup({
    super.key,
    required this.level,
    required this.score,
    required this.onNextLevel,
    required this.onHome,
  });

  final int level;
  final int score;
  final VoidCallback onNextLevel;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.70),
        child: SafeArea(
          child: Center(
            child: SizedBox(
              // =========================================================
              // SMALL POPUP SIZE
              // =========================================================
              width: screenSize.width > 430 ? 330 : screenSize.width * 0.78,

              child: AspectRatio(
                aspectRatio: 0.72,

                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final popupWidth = constraints.maxWidth;
                    final popupHeight = constraints.maxHeight;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // =================================================
                        // FULL CONGRATS POPUP PNG
                        // =================================================
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/Congrats.png',
                            fit: BoxFit.contain,

                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Congrats.png not found',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // =================================================
                        // DYNAMIC LEVEL NUMBER
                        //
                        // Level 1 = 1
                        // Level 2 = 2
                        // Level 3 = 3
                        // =================================================
                        Positioned(
                          top: popupHeight * 0.42,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _LevelNumber(
                              level: level,
                              fontSize: popupWidth * 0.25,
                            ),
                          ),
                        ),

                        // =================================================
                        // CONTINUE BUTTON CLICK AREA
                        //
                        // Continue button Congrats.png ke andar hai
                        // =================================================
                        Positioned(
                          left: popupWidth * 0.15,
                          right: popupWidth * 0.15,
                          bottom: popupHeight * 0.085,
                          height: popupHeight * 0.17,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onNextLevel,
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// DYNAMIC LEVEL NUMBER
// ==========================================================================

class _LevelNumber extends StatelessWidget {
  const _LevelNumber({required this.level, required this.fontSize});

  final int level;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ================================================================
        // DARK BLUE OUTLINE
        // ================================================================
        Text(
          '$level',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            height: 1,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFF003D73),
          ),
        ),

        // ================================================================
        // CREAM LEVEL NUMBER
        // ================================================================
        Text(
          '$level',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFFFF5D8),
            fontSize: fontSize,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
