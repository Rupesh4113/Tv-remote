import 'package:flutter/material.dart';
import '../../core/constants.dart';
import 'add_device_wizard.dart';
import 'home_screen.dart';
import 'first_run_hardware_check.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _buildTechBadge(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Icon Header
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings_remote_rounded,
                    size: 48,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Universal Remote',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Control your TV and Set-Top Box from your phone.',
                style: TextStyle(fontSize: 15, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Supported Technologies
              _buildTechBadge(
                Icons.settings_input_antenna,
                'Infrared (IR)',
                'For phones equipped with a built-in IR blaster',
              ),
              const SizedBox(height: 12),
              _buildTechBadge(
                Icons.wifi_rounded,
                'Wi-Fi & LAN',
                'Smart TVs, Samsung Tizen, LG webOS, Android TV',
              ),
              const SizedBox(height: 12),
              _buildTechBadge(
                Icons.bluetooth_rounded,
                'Bluetooth / BLE',
                'Fast, low-latency wireless control',
              ),
              const Spacer(),
              // Action Buttons
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Device'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDeviceWizard()),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.radar_rounded),
                label: const Text('Discover Devices'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF00E5FF)),
                  foregroundColor: const Color(0xFF00E5FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddDeviceWizard(initialStep: 1),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                icon: const Icon(Icons.hardware_rounded, size: 18),
                label: const Text('Check Phone Hardware & IR Blaster'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.white24),
                  foregroundColor: Colors.white70,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FirstRunHardwareCheckScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                child: const Text('Open My Remotes', style: TextStyle(color: Colors.white70)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
