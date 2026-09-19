import 'package:flutter/material.dart';
import '../../core/haptics.dart';

class DPadWidget extends StatelessWidget {
  final VoidCallback onUp;
  final VoidCallback onDown;
  final VoidCallback onLeft;
  final VoidCallback onRight;
  final VoidCallback onOk;
  final double size;

  const DPadWidget({
    super.key,
    required this.onUp,
    required this.onDown,
    required this.onLeft,
    required this.onRight,
    required this.onOk,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final outerBg = isDark ? const Color(0xFF1B202A) : const Color(0xFFE2E7ED);
    final centerBg = isDark ? const Color(0xFF28303F) : const Color(0xFFCFD6DF);
    final iconColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: outerBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
            offset: const Offset(4, 6),
            blurRadius: 10,
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              offset: const Offset(-2, -2),
              blurRadius: 4,
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // UP
          Positioned(
            top: 6,
            child: IconButton(
              iconSize: 32,
              icon: Icon(Icons.keyboard_arrow_up, color: iconColor),
              onPressed: () {
                HapticHelper.buttonPress();
                onUp();
              },
            ),
          ),
          // DOWN
          Positioned(
            bottom: 6,
            child: IconButton(
              iconSize: 32,
              icon: Icon(Icons.keyboard_arrow_down, color: iconColor),
              onPressed: () {
                HapticHelper.buttonPress();
                onDown();
              },
            ),
          ),
          // LEFT
          Positioned(
            left: 6,
            child: IconButton(
              iconSize: 32,
              icon: Icon(Icons.keyboard_arrow_left, color: iconColor),
              onPressed: () {
                HapticHelper.buttonPress();
                onLeft();
              },
            ),
          ),
          // RIGHT
          Positioned(
            right: 6,
            child: IconButton(
              iconSize: 32,
              icon: Icon(Icons.keyboard_arrow_right, color: iconColor),
              onPressed: () {
                HapticHelper.buttonPress();
                onRight();
              },
            ),
          ),
          // OK / CENTER
          Container(
            width: size * 0.38,
            height: size * 0.38,
            decoration: BoxDecoration(
              color: centerBg,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                shape: const CircleBorder(),
                onTap: () {
                  HapticHelper.rockerPress();
                  onOk();
                },
                child: Center(
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
