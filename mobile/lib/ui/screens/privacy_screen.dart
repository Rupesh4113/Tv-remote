import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/storage_service.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Local Data?'),
        content: const Text(
          'This will permanently remove all paired devices, authentication tokens, learned IR codes, and custom macros from this phone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete Everything'),
            onPressed: () async {
              final storage = Provider.of<StorageService>(context, listen: false);
              await storage.clearAllData();
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All local data has been permanently cleared.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBullet(IconData icon, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00E5FF), size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
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
      appBar: AppBar(
        title: const Text('Privacy & Local Security'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2430),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildPrivacyBullet(
                      Icons.lock_outline_rounded,
                      'Local-First Architecture',
                      'Your remote control commands are transmitted directly to your TV or Set-Top Box over local hardware (IR, BLE, or LAN). No commands pass through external servers.',
                    ),
                    _buildPrivacyBullet(
                      Icons.wifi_find_rounded,
                      'Local Network Discovery',
                      'Network discovery (mDNS and SSDP) operates strictly within your local home Wi-Fi to locate compatible smart TVs.',
                    ),
                    _buildPrivacyBullet(
                      Icons.vpn_key_rounded,
                      'Zero Credential Uploads',
                      'Authentication PINs, pre-shared keys, and client tokens are stored locally on your device in secure storage.',
                    ),
                    _buildPrivacyBullet(
                      Icons.cloud_off_rounded,
                      'Explicit Cloud Consent',
                      'Cloud backup and profile synchronization are entirely optional and require your explicit consent before transmitting any data.',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete All Local Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _confirmDeleteAll(context),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
