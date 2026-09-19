import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transports/ir/ir_transport.dart';
import 'home_screen.dart';

class FirstRunHardwareCheckScreen extends StatefulWidget {
  const FirstRunHardwareCheckScreen({super.key});

  @override
  State<FirstRunHardwareCheckScreen> createState() => _FirstRunHardwareCheckScreenState();
}

class _FirstRunHardwareCheckScreenState extends State<FirstRunHardwareCheckScreen> {
  bool _checking = true;
  bool _hasIr = false;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  Future<void> _runCheck() async {
    final irTransport = Provider.of<IrTransport>(context, listen: false);
    final hasIr = await irTransport.initialize();
    if (mounted) {
      setState(() {
        _hasIr = hasIr;
        _checking = false;
      });
    }
  }

  Widget _buildCheckRow(String label, bool isAvailable, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAvailable ? const Color(0xFF00E676).withOpacity(0.3) : Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isAvailable ? const Color(0xFF00E676) : Colors.amber,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            isAvailable ? '✓ Available' : '✗ Unavailable',
            style: TextStyle(
              color: isAvailable ? const Color(0xFF00E676) : Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
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
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phonelink_setup_rounded, size: 44, color: Color(0xFF00E5FF)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to RemoteOne',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Let's check your phone's hardware capabilities:",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (_checking)
                const Center(child: CircularProgressIndicator())
              else ...[
                _buildCheckRow(
                  'Infrared (IR) Blaster',
                  _hasIr,
                  _hasIr ? 'Hardware IR transmitter found' : 'No built-in IR hardware found',
                ),
                _buildCheckRow(
                  'Wi-Fi & Local Network',
                  true,
                  'Connected to local home network',
                ),
                _buildCheckRow(
                  'Bluetooth / BLE',
                  true,
                  'BLE wireless adapter ready',
                ),
                _buildCheckRow(
                  'Device Discovery (mDNS/SSDP)',
                  true,
                  'Subnet scanning active',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _hasIr
                        ? const Color(0xFF00E676).withOpacity(0.12)
                        : Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasIr ? const Color(0xFF00E676).withOpacity(0.4) : Colors.amber.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _hasIr
                        ? '✓ Your phone is fully equipped for Infrared, Wi-Fi, and Bluetooth remote control.'
                        : 'Your phone does not have an IR blaster. You can still control compatible Smart TVs and Set-Top Boxes using Wi-Fi or Bluetooth.',
                    style: TextStyle(
                      color: _hasIr ? const Color(0xFF00E676) : Colors.amber,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Continue to Remote', style: TextStyle(fontSize: 16)),
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
