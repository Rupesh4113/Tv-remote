import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/remote_controller.dart';
import '../widgets/color_buttons_row.dart';
import '../widgets/dpad_widget.dart';
import '../widgets/numpad_sheet.dart';
import '../widgets/remote_button.dart';
import '../widgets/rocker_widget.dart';

class StbRemoteScreen extends StatelessWidget {
  const StbRemoteScreen({super.key});

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
          // STB Provider Banner
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
                    const Icon(Icons.satellite_alt_rounded, color: Color(0xFFFF9100), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      activeDevice?.name ?? 'Tata Play STB',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9100).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    (activeDevice?.activeTransport.name ?? 'IR').toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFFF9100),
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
              ),
              child: Text(
                controller.lastError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 18),
          // Power & Numpad Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.menu_book_rounded,
                label: 'Guide',
                onPressed: () => controller.sendKey('GUIDE'),
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
          const SizedBox(height: 18),
          // Interactive Indian DTH Color Buttons (Red / Green / Yellow / Blue)
          ColorButtonsRow(
            onRed: () => controller.sendKey('COLOR_RED'),
            onGreen: () => controller.sendKey('COLOR_GREEN'),
            onYellow: () => controller.sendKey('COLOR_YELLOW'),
            onBlue: () => controller.sendKey('COLOR_BLUE'),
          ),
          const SizedBox(height: 20),
          // Rockers & Utility Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RockerWidget(
                title: 'VOL',
                onPlus: () => controller.sendKey('VOLUME_UP'),
                onMinus: () => controller.sendKey('VOLUME_DOWN'),
              ),
              Column(
                children: [
                  RemoteButton(
                    icon: Icons.info_outline_rounded,
                    size: 46,
                    label: 'Info',
                    onPressed: () => controller.sendKey('INFO'),
                  ),
                  const SizedBox(height: 10),
                  RemoteButton(
                    icon: Icons.star_border_rounded,
                    size: 46,
                    label: 'Fav',
                    onPressed: () => controller.sendKey('FAVORITE'),
                  ),
                  const SizedBox(height: 10),
                  RemoteButton(
                    icon: Icons.fiber_manual_record_rounded,
                    size: 46,
                    color: Colors.red.shade900,
                    label: 'Rec',
                    onPressed: () => controller.sendKey('RECORD'),
                  ),
                ],
              ),
              RockerWidget(
                title: 'CH',
                onPlus: () => controller.sendKey('CHANNEL_UP'),
                onMinus: () => controller.sendKey('CHANNEL_DOWN'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // D-Pad Navigation
          DPadWidget(
            size: 210,
            onUp: () => controller.sendKey('DPAD_UP'),
            onDown: () => controller.sendKey('DPAD_DOWN'),
            onLeft: () => controller.sendKey('DPAD_LEFT'),
            onRight: () => controller.sendKey('DPAD_RIGHT'),
            onOk: () => controller.sendKey('DPAD_OK'),
          ),
          const SizedBox(height: 18),
          // Exit, Menu, Back Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.exit_to_app_rounded,
                label: 'Exit',
                onPressed: () => controller.sendKey('EXIT'),
              ),
              RemoteButton(
                icon: Icons.menu_rounded,
                label: 'Menu',
                onPressed: () => controller.sendKey('MENU'),
              ),
              RemoteButton(
                icon: Icons.arrow_back_rounded,
                label: 'Back',
                onPressed: () => controller.sendKey('BACK'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Media Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RemoteButton(
                icon: Icons.replay_10_rounded,
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
                icon: Icons.forward_10_rounded,
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
