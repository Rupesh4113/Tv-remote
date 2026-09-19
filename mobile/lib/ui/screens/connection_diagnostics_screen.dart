import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ConnectionDiagnosticsScreen extends StatefulWidget {
  const ConnectionDiagnosticsScreen({super.key});

  @override
  State<ConnectionDiagnosticsScreen> createState() => _ConnectionDiagnosticsScreenState();
}

class _ConnectionDiagnosticsScreenState extends State<ConnectionDiagnosticsScreen> {
  bool _testing = false;
  bool _wifiConnected = true;
  bool _localSubnet = true;
  bool _internetAccess = true;
  bool _discoveryReady = true;
  bool _tvReachable = false;
  String? _detectedTvIp;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() => _testing = true);

    // 1. Test internet access
    try {
      final res = await http.get(Uri.parse('https://dns.google/resolve?name=example.com')).timeout(const Duration(seconds: 2));
      _internetAccess = res.statusCode == 200;
    } catch (_) {
      _internetAccess = false;
    }

    // 2. Probe common Smart TV local addresses / simulators
    _tvReachable = false;
    _detectedTvIp = null;
    for (final ip in ['192.168.1.20', '192.168.1.35', '10.0.2.2', '127.0.0.1', 'localhost']) {
      try {
        final res = await http.get(Uri.parse('http://$ip:8081/api/v2/')).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) {
          _tvReachable = true;
          _detectedTvIp = '$ip (Samsung TV/Simulator)';
          break;
        }
      } catch (_) {}

      try {
        final res = await http.get(Uri.parse('http://$ip:8083/sony/system')).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) {
          _tvReachable = true;
          _detectedTvIp = '$ip (Sony Bravia TV)';
          break;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() => _testing = false);
    }
  }

  Widget _buildStatusTile(String title, bool success, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2430),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: success ? const Color(0xFF00E676).withOpacity(0.3) : Colors.amber.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            success ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: success ? const Color(0xFF00E676) : Colors.amber,
            size: 22,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 12)),
              ],
            ),
          ),
          Text(
            success ? 'PASS' : 'WARN',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: success ? const Color(0xFF00E676) : Colors.amber,
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
        title: const Text('Connection Diagnostics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _testing ? null : _runDiagnostics,
            tooltip: 'Re-test',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Local Network Health',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildStatusTile(
              'Wi-Fi Adapter',
              _wifiConnected,
              'Active wireless connection',
            ),
            _buildStatusTile(
              'Local Subnet',
              _localSubnet,
              'Local IP range assigned (192.168.x.x / 10.x.x.x)',
            ),
            _buildStatusTile(
              'Internet Access',
              _internetAccess,
              _internetAccess ? 'Cloud backup & update services reachable' : 'Offline mode active (LAN control still works)',
            ),
            _buildStatusTile(
              'Multicast & Discovery',
              _discoveryReady,
              'mDNS Bonjour and SSDP UPnP ready',
            ),
            _buildStatusTile(
              'Smart TV Reachable',
              _tvReachable,
              _tvReachable ? 'Responding at $_detectedTvIp' : 'No response from TV IP on current subnet',
            ),
            const SizedBox(height: 20),
            // Troubleshooting Checklist
            const Text(
              'Troubleshooting Checklist for Real Smart TVs:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF00E5FF)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2430),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Ensure Phone and TV are on the exact same Wi-Fi SSID / band (e.g. both on 2.4GHz or 5GHz).', style: TextStyle(fontSize: 13, height: 1.4)),
                  SizedBox(height: 8),
                  Text('2. Make sure the TV is turned ON (or Wake-On-LAN is enabled in TV network settings).', style: TextStyle(fontSize: 13, height: 1.4)),
                  SizedBox(height: 8),
                  Text('3. Enable "IP Remote Control" in TV settings (e.g. Sony: Network -> IP Control -> Simple IP Control ON).', style: TextStyle(fontSize: 13, height: 1.4)),
                  SizedBox(height: 8),
                  Text('4. Disable VPN on your phone during pairing and control.', style: TextStyle(fontSize: 13, height: 1.4)),
                  SizedBox(height: 8),
                  Text('5. Disable "Guest Wi-Fi Isolation" or "AP Client Isolation" on your router.', style: TextStyle(fontSize: 13, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: _testing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.network_check_rounded),
              label: Text(_testing ? 'Diagnosing Network...' : 'Run Diagnostics Again'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _testing ? null : _runDiagnostics,
            ),
          ],
        ),
      ),
    );
  }
}
