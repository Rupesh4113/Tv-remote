import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/remote_controller.dart';
import '../widgets/dpad_widget.dart';
import '../widgets/numpad_sheet.dart';
import '../widgets/remote_button.dart';
import '../widgets/rocker_widget.dart';

class TvRemoteScreen extends StatelessWidget {
  const TvRemoteScreen({super.key});

  void _showNumpad(BuildContext context) {
    final controller = Provider.of<RemoteController>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => NumpadSheet(
        onNumberPressed: (num) => controller.sendKey('NUM_$num', label: '$num'),
        onBack: () => controller.sendKey('BACK'),
        onEnter: () => controller.sendKey('DPAD_OK'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<RemoteController>(context);
    final activeDevice = controller.activeDevice;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          // Device Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1B202B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tv, color: Color(0xFF00E5FF), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      activeDevice?.name ?? 'Living Room TV',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (activeDevice?.activeTransport.name ?? 'WIFI').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.lastError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.lastError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          // Top Row: Source, Numpad, Power
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.input_rounded,
                label: 'Source',
                onPressed: () => controller.sendKey('SOURCE'),
              ),
              RemoteButton(
                icon: Icons.dialpad_rounded,
                label: '123',
                onPressed: () => _showNumpad(context),
              ),
              RemoteButton(
                icon: Icons.power_settings_new_rounded,
                color: const Color(0xFFFF2A4B),
                textColor: Colors.white,
                isDestructive: true,
                onPressed: () => controller.sendKey('POWER'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Center Rockers + Shortcuts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Volume Rocker
              RockerWidget(
                title: 'VOL',
                onPlus: () => controller.sendKey('VOLUME_UP'),
                onMinus: () => controller.sendKey('VOLUME_DOWN'),
              ),
              // Center utility buttons (Mute, Home, Back, Info)
              Column(
                children: [
                  RemoteButton(
                    icon: Icons.volume_off_rounded,
                    size: 46,
                    onPressed: () => controller.sendKey('MUTE'),
                  ),
                  const SizedBox(height: 10),
                  RemoteButton(
                    icon: Icons.home_rounded,
                    size: 46,
                    onPressed: () => controller.sendKey('HOME'),
                  ),
                  const SizedBox(height: 10),
                  RemoteButton(
                    icon: Icons.arrow_back_rounded,
                    size: 46,
                    onPressed: () => controller.sendKey('BACK'),
                  ),
                ],
              ),
              // Channel Rocker
              RockerWidget(
                title: 'CH',
                onPlus: () => controller.sendKey('CHANNEL_UP'),
                onMinus: () => controller.sendKey('CHANNEL_DOWN'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 5-Way D-Pad Navigation
          DPadWidget(
            size: 210,
            onUp: () => controller.sendKey('DPAD_UP'),
            onDown: () => controller.sendKey('DPAD_DOWN'),
            onLeft: () => controller.sendKey('DPAD_LEFT'),
            onRight: () => controller.sendKey('DPAD_RIGHT'),
            onOk: () => controller.sendKey('DPAD_OK'),
          ),
          const SizedBox(height: 22),
          // Streaming App Hotkeys
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                label: 'NETFLIX',
                size: 48,
                color: const Color(0xFFE50914),
                textColor: Colors.white,
                shape: RemoteButtonShape.pill,
                onPressed: () => controller.sendKey('NETFLIX'),
              ),
              RemoteButton(
                label: 'YOUTUBE',
                size: 48,
                color: const Color(0xFFFF0000),
                textColor: Colors.white,
                shape: RemoteButtonShape.pill,
                onPressed: () => controller.sendKey('YOUTUBE'),
              ),
              RemoteButton(
                label: 'PRIME',
                size: 48,
                color: const Color(0xFF00A8E1),
                textColor: Colors.white,
                shape: RemoteButtonShape.pill,
                onPressed: () => controller.sendKey('PRIME_VIDEO'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Playback Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.fast_rewind_rounded,
                size: 44,
                onPressed: () => controller.sendKey('REWIND'),
              ),
              RemoteButton(
                icon: Icons.play_arrow_rounded,
                size: 44,
                onPressed: () => controller.sendKey('PLAY'),
              ),
              RemoteButton(
                icon: Icons.pause_rounded,
                size: 44,
                onPressed: () => controller.sendKey('PAUSE'),
              ),
              RemoteButton(
                icon: Icons.fast_forward_rounded,
                size: 44,
                onPressed: () => controller.sendKey('FAST_FORWARD'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
