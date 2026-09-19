import 'package:flutter/material.dart';
import 'remote_button.dart';

class NumpadSheet extends StatelessWidget {
  final Function(int) onNumberPressed;
  final VoidCallback? onBack;
  final VoidCallback? onEnter;

  const NumpadSheet({
    super.key,
    required this.onNumberPressed,
    this.onBack,
    this.onEnter,
  });

  Widget _buildNumBtn(int num) {
    return RemoteButton(
      label: '$num',
      size: 56,
      shape: RemoteButtonShape.circle,
      onPressed: () => onNumberPressed(num),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F29),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Number Pad',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildNumBtn(1), _buildNumBtn(2), _buildNumBtn(3)],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildNumBtn(4), _buildNumBtn(5), _buildNumBtn(6)],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [_buildNumBtn(7), _buildNumBtn(8), _buildNumBtn(9)],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.backspace_outlined,
                size: 56,
                shape: RemoteButtonShape.circle,
                onPressed: onBack ?? () {},
              ),
              _buildNumBtn(0),
              RemoteButton(
                icon: Icons.check,
                size: 56,
                color: const Color(0xFF00E5FF),
                textColor: Colors.black,
                shape: RemoteButtonShape.circle,
                onPressed: onEnter ?? () {},
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
