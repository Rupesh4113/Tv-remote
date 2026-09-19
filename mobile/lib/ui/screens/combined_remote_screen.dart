import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/combined_remote_service.dart';
import '../widgets/color_buttons_row.dart';
import '../widgets/dpad_widget.dart';
import '../widgets/numpad_sheet.dart';
import '../widgets/remote_button.dart';
import '../widgets/rocker_widget.dart';

class CombinedRemoteScreen extends StatelessWidget {
  const CombinedRemoteScreen({super.key});

  void _showNumpad(BuildContext context, CombinedRemoteService combined) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => NumpadSheet(
        onNumberPressed: (num) => combined.sendCommand('NUM_$num', label: '$num'),
        onBack: () => combined.sendCommand('BACK'),
        onEnter: () => combined.sendCommand('DPAD_OK'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final combined = Provider.of<CombinedRemoteService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Dual Device Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B202B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tv, color: Color(0xFF00E5FF), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          combined.tvDevice?.name ?? 'TV (Living Room)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.satellite_alt_rounded, color: Color(0xFFFF9100), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          combined.stbDevice?.name ?? 'Tata Play STB',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'COMBINED',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Dual Power Row: TV Power | Input | STB Power
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.power_settings_new,
                label: 'TV Power',
                isDestructive: true,
                onPressed: () => combined.sendCommand('POWER_TV'),
              ),
              RemoteButton(
                icon: Icons.input_rounded,
                label: 'Source',
                onPressed: () => combined.sendCommand('SOURCE'),
              ),
              RemoteButton(
                icon: Icons.power_settings_new,
                label: 'STB Power',
                color: const Color(0xFFFF9100),
                textColor: Colors.black,
                onPressed: () => combined.sendCommand('POWER_STB'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Interactive Color Buttons for STB
          ColorButtonsRow(
            onRed: () => combined.sendCommand('COLOR_RED'),
            onGreen: () => combined.sendCommand('COLOR_GREEN'),
            onYellow: () => combined.sendCommand('COLOR_YELLOW'),
            onBlue: () => combined.sendCommand('COLOR_BLUE'),
          ),
          const SizedBox(height: 20),
          // Dual Rockers: VOL -> TV, CH -> STB
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // TV Volume
              RockerWidget(
                title: 'VOL (TV)',
                onPlus: () => combined.sendCommand('VOLUME_UP'),
                onMinus: () => combined.sendCommand('VOLUME_DOWN'),
              ),
              Column(
                children: [
                  RemoteButton(
                    icon: Icons.volume_off_rounded,
                    size: 46,
                    onPressed: () => combined.sendCommand('MUTE'),
                  ),
                  const SizedBox(height: 10),
                  RemoteButton(
                    icon: Icons.dialpad_rounded,
                    size: 46,
                    onPressed: () => _showNumpad(context, combined),
                  ),
                  const SizedBox(height: 10),
                  RemoteButton(
                    icon: Icons.menu_book_rounded,
                    size: 46,
                    onPressed: () => combined.sendCommand('GUIDE'),
                  ),
                ],
              ),
              // STB Channel
              RockerWidget(
                title: 'CH (STB)',
                onPlus: () => combined.sendCommand('CHANNEL_UP'),
                onMinus: () => combined.sendCommand('CHANNEL_DOWN'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // 5-Way D-Pad Navigation for STB
          DPadWidget(
            size: 200,
            onUp: () => combined.sendCommand('DPAD_UP'),
            onDown: () => combined.sendCommand('DPAD_DOWN'),
            onLeft: () => combined.sendCommand('DPAD_LEFT'),
            onRight: () => combined.sendCommand('DPAD_RIGHT'),
            onOk: () => combined.sendCommand('DPAD_OK'),
          ),
          const SizedBox(height: 18),
          // Bottom Navigation Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.menu_rounded,
                label: 'Menu',
                onPressed: () => combined.sendCommand('MENU'),
              ),
              RemoteButton(
                icon: Icons.home_rounded,
                label: 'Home',
                onPressed: () => combined.sendCommand('HOME'),
              ),
              RemoteButton(
                icon: Icons.arrow_back_rounded,
                label: 'Back',
                onPressed: () => combined.sendCommand('BACK'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
