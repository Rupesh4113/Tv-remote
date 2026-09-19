import 'package:flutter/material.dart';
import '../../core/haptics.dart';

enum RemoteButtonShape { circle, rounded, pill }

class RemoteButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double size;
  final RemoteButtonShape shape;
  final bool isDestructive;

  const RemoteButton({
    super.key,
    this.icon,
    this.label,
    required this.onPressed,
    this.color,
    this.textColor,
    this.size = 54,
    this.shape = RemoteButtonShape.circle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = color ?? (isDestructive
        ? const Color(0xFFD32F2F)
        : (isDark ? const Color(0xFF242A36) : const Color(0xFFE0E5EC)));

    final fg = textColor ?? (isDestructive ? Colors.white : (isDark ? Colors.white : Colors.black87));

    BorderRadius borderRadius;
    switch (shape) {
      case RemoteButtonShape.circle:
        borderRadius = BorderRadius.circular(size / 2);
        break;
      case RemoteButtonShape.pill:
        borderRadius = BorderRadius.circular(24);
        break;
      case RemoteButtonShape.rounded:
      default:
        borderRadius = BorderRadius.circular(14);
        break;
    }

    return Container(
      width: shape == RemoteButtonShape.pill ? size * 1.5 : size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            offset: const Offset(2, 3),
            blurRadius: 5,
          ),
          if (isDark)
            BoxShadow(
              color: Colors.white.withOpacity(0.04),
              offset: const Offset(-1, -1),
              blurRadius: 2,
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () {
            HapticHelper.buttonPress();
            onPressed();
          },
          child: Center(
            child: icon != null
                ? Icon(icon, color: fg, size: size * 0.45)
                : Text(
                    label ?? '',
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.28,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}
