import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/haptics.dart';
import '../../core/diagnostic_logger.dart';
import '../../data/database/storage_service.dart';
import '../../transports/ir/ir_transport.dart';
import 'privacy_screen.dart';
import 'live_test_mode_screen.dart';
import 'ir_hardware_test_screen.dart';
import 'connection_diagnostics_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _hapticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final irTransport = Provider.of<IrTransport>(context);
    final storage = Provider.of<StorageService>(context);
    final devices = storage.getDevices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hardware Diagnostics Section
          const Text('Hardware Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00E5FF))),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                irTransport.hasEmitter ? Icons.check_circle : Icons.warning_amber_rounded,
                color: irTransport.hasEmitter ? const Color(0xFF00E676) : Colors.amber,
              ),
              title: const Text('Infrared Blaster'),
              subtitle: Text(
                irTransport.hasEmitter
                    ? 'Built-in hardware IR emitter detected'
                    : 'Not available on this device (Wi-Fi/BLE will be used)',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Preferences
          const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00E5FF))),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Haptic Vibration Feedback'),
                  subtitle: const Text('Tactile response on remote button presses', style: TextStyle(fontSize: 12)),
                  value: _hapticsEnabled,
                  onChanged: (val) {
                    setState(() {
                      _hapticsEnabled = val;
                      HapticHelper.enabled = val;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Default Active Remote'),
                  subtitle: Text(
                    devices.isNotEmpty ? devices.first.name : 'None (Add a device)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Developer & Diagnostics
          const Text('Developer & Physical Diagnostics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00E5FF))),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.science_outlined, color: Color(0xFF00E5FF)),
                  title: const Text('Live Device Testing Mode'),
                  subtitle: const Text('Real-time command validation with JSON/CSV report export', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LiveTestModeScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_remote_outlined, color: Colors.amber),
                  title: const Text('IR Hardware Diagnostics'),
                  subtitle: const Text('Hardware carrier frequency check and test pulses', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const IrHardwareTestScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.wifi_tethering, color: Color(0xFF00E676)),
                  title: const Text('Wi-Fi Connection Diagnostics'),
                  subtitle: const Text('Port reachability (Samsung 8001/8002, LG 3000/3001, Android TV 6466/6467, Roku 8060)', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ConnectionDiagnosticsScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: Colors.white70),
                  title: const Text('Export Local Diagnostic Logs'),
                  subtitle: const Text('Copy sanitized local event logs for bug reporting', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.copy, size: 16),
                  onTap: () {
                    final logs = DiagnosticLogger.instance.exportAsText();
                    Clipboard.setData(ClipboardData(text: logs));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Diagnostic logs copied to clipboard (passwords and tokens omitted)'),
                        backgroundColor: Color(0xFF1E2430),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Security & Data
          const Text('Security & Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00E5FF))),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip_outlined, color: Color(0xFF00E5FF)),
              title: const Text('Privacy Policy & Local Storage'),
              subtitle: const Text('Zero telemetry, local encryption, data removal', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // About
          const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00E5FF))),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConstants.appName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(AppConstants.appSubtitle, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('Version: 1.0.0 (Open Source)', style: TextStyle(fontSize: 12, color: Colors.white54)),
                  const Text('Target: Indian & Global TVs & Set-Top Boxes', style: TextStyle(fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
