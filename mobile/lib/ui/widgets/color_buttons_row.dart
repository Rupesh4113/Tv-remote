import 'package:flutter/material.dart';
import '../../core/haptics.dart';

class ColorButtonsRow extends StatelessWidget {
  final VoidCallback onRed;
  final VoidCallback onGreen;
  final VoidCallback onYellow;
  final VoidCallback onBlue;

  const ColorButtonsRow({
    super.key,
    required this.onRed,
    required this.onGreen,
    required this.onYellow,
    required this.onBlue,
  });

  Widget _buildColorDot(Color color, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticHelper.buttonPress();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 52,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildColorDot(const Color(0xFFFF334B), onRed),
        _buildColorDot(const Color(0xFF00E676), onGreen),
        _buildColorDot(const Color(0xFFFFD600), onYellow),
        _buildColorDot(const Color(0xFF2979FF), onBlue),
      ],
    );
  }
}
