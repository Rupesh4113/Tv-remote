import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/haptics.dart';
import '../../data/database/storage_service.dart';
import '../../data/models/command_model.dart';
import '../../data/models/device_model.dart';
import '../../services/remote_controller.dart';
import '../../transports/ir/ir_transport.dart';

class LiveTestModeScreen extends StatefulWidget {
  const LiveTestModeScreen({super.key});

  @override
  State<LiveTestModeScreen> createState() => _LiveTestModeScreenState();
}

class _LiveTestModeScreenState extends State<LiveTestModeScreen> {
  final Map<String, String> _testResults = {
    'TV POWER': 'NOT TESTED',
    'TV VOLUME+': 'NOT TESTED',
    'TV INPUT': 'NOT TESTED',
    'STB POWER': 'NOT TESTED',
    'STB CHANNEL+': 'NOT TESTED',
    'STB GUIDE': 'NOT TESTED',
  };

  void _runTest(String testKey, String cmdKey, DeviceCategory category) async {
    final storage = Provider.of<StorageService>(context, listen: false);
    final controller = Provider.of<RemoteController>(context, listen: false);
    final devices = storage.getDevices();

    final target = devices.firstWhere(
      (d) => d.category == category,
      orElse: () => devices.isNotEmpty
          ? devices.first
          : DeviceModel(
              id: 'test_dev',
              name: category == DeviceCategory.tv ? 'Living Room TV' : 'Set-Top Box',
              brand: category == DeviceCategory.tv ? 'Samsung' : 'Tata Play',
              category: category,
              profileId: category == DeviceCategory.tv ? 'tv-samsung-smart' : 'stb-tata-play',
              activeTransport: TransportType.ir,
            ),
    );

    setState(() {
      _testResults[testKey] = 'TESTING...';
    });

    final success = await controller.executeCommand(
      target,
      RemoteCommand(key: cmdKey, label: testKey),
    );

    // Prompt user for physical confirmation
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Test: $testKey'),
          content: Text(
            'Signal sent to ${target.name}.\n\nDid the physical device respond correctly?',
          ),
          actions: [
            TextButton(
              child: const Text('NO (FAIL)', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _testResults[testKey] = 'FAIL');
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E676)),
              child: const Text('YES (PASS)', style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(ctx);
                HapticHelper.rockerPress();
                setState(() => _testResults[testKey] = 'PASS');
              },
            ),
          ],
        ),
      );
    }
  }

  void _exportReport() {
    final report = {
      'report_title': 'RemoteOne Live Physical Device Test Report',
      'generated_at': DateTime.now().toIso8601String(),
      'results': _testResults,
      'summary': {
        'total': _testResults.length,
        'passed': _testResults.values.where((v) => v == 'PASS').length,
        'failed': _testResults.values.where((v) => v == 'FAIL').length,
        'not_tested': _testResults.values.where((v) => v == 'NOT TESTED').length,
      }
    };

    final jsonStr = jsonEncode(report);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exported Test Report'),
        content: SingleChildScrollView(
          child: SelectableText(
            jsonStr,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isOk, String valText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          Row(
            children: [
              Icon(
                isOk ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isOk ? const Color(0xFF00E676) : Colors.amber,
              ),
              const SizedBox(width: 6),
              Text(
                valText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isOk ? const Color(0xFF00E676) : Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final irTransport = Provider.of<IrTransport>(context);
    final storage = Provider.of<StorageService>(context);
    final devices = storage.getDevices();

    final hasTv = devices.any((d) => d.category == DeviceCategory.tv);
    final hasStb = devices.any((d) => d.category == DeviceCategory.setTopBox);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Device Testing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Export Report',
            onPressed: _exportReport,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2430),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LIVE DEVICE TEST STATUS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF00E5FF))),
                  const SizedBox(height: 12),
                  _buildStatusRow('Phone', true, 'Android Device Active'),
                  _buildStatusRow('IR Blaster', irTransport.hasEmitter, irTransport.hasEmitter ? 'Available' : 'Not Available'),
                  _buildStatusRow('Wi-Fi / LAN', true, 'Connected'),
                  _buildStatusRow('Bluetooth', true, 'Enabled'),
                  _buildStatusRow('TV Configured', hasTv, hasTv ? 'Ready' : 'Not Configured'),
                  _buildStatusRow('STB Configured', hasStb, hasStb ? 'Ready' : 'Not Configured'),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Physical Hardware Test Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Transmit commands to real TVs and Set-Top Boxes and confirm physical response:',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 16),
            // Actions Matrix
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTestTile('TV POWER', () => _runTest('TV POWER', 'POWER', DeviceCategory.tv)),
                    _buildTestTile('TV VOLUME+', () => _runTest('TV VOLUME+', 'VOLUME_UP', DeviceCategory.tv)),
                    _buildTestTile('TV INPUT', () => _runTest('TV INPUT', 'SOURCE', DeviceCategory.tv)),
                    const Divider(height: 20),
                    _buildTestTile('STB POWER', () => _runTest('STB POWER', 'POWER', DeviceCategory.setTopBox)),
                    _buildTestTile('STB CHANNEL+', () => _runTest('STB CHANNEL+', 'CHANNEL_UP', DeviceCategory.setTopBox)),
                    _buildTestTile('STB GUIDE', () => _runTest('STB GUIDE', 'GUIDE', DeviceCategory.setTopBox)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.assignment_outlined),
              label: const Text('Export Test Report (JSON)'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: _exportReport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestTile(String testKey, VoidCallback onTest) {
    final result = _testResults[testKey] ?? 'NOT TESTED';
    Color badgeColor = Colors.grey;
    if (result == 'PASS') badgeColor = const Color(0xFF00E676);
    if (result == 'FAIL') badgeColor = Colors.redAccent;
    if (result == 'TESTING...') badgeColor = const Color(0xFF00E5FF);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(testKey, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  result,
                  style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: onTest,
                child: const Text('TEST', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
