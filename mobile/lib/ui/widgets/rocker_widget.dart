import 'package:flutter/material.dart';
import '../../core/haptics.dart';

class RockerWidget extends StatelessWidget {
  final String title;
  final VoidCallback onPlus;
  final VoidCallback onMinus;
  final IconData? centerIcon;

  const RockerWidget({
    super.key,
    required this.title,
    required this.onPlus,
    required this.onMinus,
    this.centerIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF222834) : const Color(0xFFE4E9F0);
    final textColor = isDark ? Colors.white70 : Colors.black87;

    return Container(
      width: 68,
      height: 148,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            offset: const Offset(3, 4),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Plus
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
              onTap: () {
                HapticHelper.rockerPress();
                onPlus();
              },
              child: const Center(
                child: Icon(Icons.add, size: 28),
              ),
            ),
          ),
          // Title / Center label
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: centerIcon != null
                ? Icon(centerIcon, size: 18, color: textColor.withOpacity(0.6))
                : Text(
                    title,
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
          // Minus
          Expanded(
            child: InkWell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(34)),
              onTap: () {
                HapticHelper.rockerPress();
                onMinus();
              },
              child: const Center(
                child: Icon(Icons.remove, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
