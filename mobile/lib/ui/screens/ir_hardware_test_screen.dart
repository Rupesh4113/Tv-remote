import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/haptics.dart';
import '../../data/models/command_model.dart';
import '../../data/models/device_model.dart';
import '../../services/remote_controller.dart';
import '../../transports/ir/ir_transport.dart';
import '../../transports/ir/protocol_encoders.dart';

class IrHardwareTestScreen extends StatefulWidget {
  const IrHardwareTestScreen({super.key});

  @override
  State<IrHardwareTestScreen> createState() => _IrHardwareTestScreenState();
}

class _IrHardwareTestScreenState extends State<IrHardwareTestScreen> {
  String _selectedBrand = 'Samsung';
  String _selectedProtocol = 'NEC';
  int _selectedFrequency = 38000;
  String? _transmissionStatus;
  String? _deviceResponseStatus;
  String _lastCommandSent = '';

  final Map<String, Map<String, String>> _sampleCodes = {
    'Samsung': {
      'POWER': '0xE0E040BF',
      'VOL+': '0xE0E0E01F',
      'VOL-': '0xE0E0D02F',
      'CH+': '0xE0E048B7',
      'CH-': '0xE0E008F7',
      'MUTE': '0xE0E0F00F',
    },
    'Sony': {
      'POWER': '0xA90',
      'VOL+': '0x490',
      'VOL-': '0xC90',
      'CH+': '0x090',
      'CH-': '0x890',
      'MUTE': '0x290',
    },
    'LG': {
      'POWER': '0x20DF10EF',
      'VOL+': '0x20DF40BF',
      'VOL-': '0x20DFC03F',
      'CH+': '0x20DF00FF',
      'CH-': '0x20DF807F',
      'MUTE': '0x20DF906F',
    },
    'Tata Play': {
      'POWER': '0x00BF02FD',
      'VOL+': '0x00BF0EF1',
      'VOL-': '0x00BF12ED',
      'CH+': '0x00BF18E7',
      'CH-': '0x00BF1CE3',
      'MUTE': '0x00BF10EF',
    },
    'Xiaomi': {
      'POWER': '0x0AF510EF',
      'VOL+': '0x0AF520DF',
      'VOL-': '0x0AF530CF',
      'CH+': '0x0AF550AF',
      'CH-': '0x0AF5609F',
      'MUTE': '0x0AF540BF',
    },
    'Generic': {
      'POWER': '0x00FFA25D',
      'VOL+': '0x00FF629D',
      'VOL-': '0x00FFA857',
      'CH+': '0x00FF02FD',
      'CH-': '0x00FF9867',
      'MUTE': '0x00FFE21D',
    }
  };

  void _transmitTest(String cmdLabel) async {
    final irTransport = Provider.of<IrTransport>(context, listen: false);
    final controller = Provider.of<RemoteController>(context, listen: false);

    final codes = _sampleCodes[_selectedBrand] ?? _sampleCodes['Generic']!;
    final hex = codes[cmdLabel] ?? '0x00FFA25D';

    setState(() {
      _lastCommandSent = cmdLabel;
      _transmissionStatus = 'Transmitting $cmdLabel at ${_selectedFrequency}Hz ($hex)...';
      _deviceResponseStatus = null;
    });

    final testDevice = DeviceModel(
      id: 'test_dev',
      name: '$_selectedBrand Test',
      brand: _selectedBrand,
      category: DeviceCategory.tv,
      profileId: 'test-profile',
      activeTransport: TransportType.ir,
    );

    final success = await controller.executeCommand(
      testDevice,
      RemoteCommand(key: cmdLabel, label: cmdLabel, irHex: hex),
    );

    setState(() {
      if (success) {
        _transmissionStatus = '✓ Signal sent ($cmdLabel)';
      } else if (!irTransport.hasEmitter) {
        _transmissionStatus = '✗ Failed: Phone hardware has no IR transmitter';
      } else {
        _transmissionStatus = '✗ Failed: IR hardware error';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final irTransport = Provider.of<IrTransport>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IR Hardware Test Mode'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Hardware Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: irTransport.hasEmitter
                    ? const Color(0xFF00E676).withOpacity(0.12)
                    : Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: irTransport.hasEmitter ? const Color(0xFF00E676) : Colors.amber,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    irTransport.hasEmitter ? Icons.check_circle : Icons.warning_rounded,
                    color: irTransport.hasEmitter ? const Color(0xFF00E676) : Colors.amber,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      irTransport.hasEmitter
                          ? 'Phone IR Blaster: Active and Ready'
                          : 'Phone IR Blaster: Not Available on this device',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: irTransport.hasEmitter ? const Color(0xFF00E676) : Colors.amber,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Select Device Brand
            const Text('Device Brand', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBrand,
              dropdownColor: const Color(0xFF1E2430),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E2430),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _sampleCodes.keys.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedBrand = val!;
                  if (_selectedBrand == 'Sony') {
                    _selectedProtocol = 'SONY_SIRC';
                    _selectedFrequency = 40000;
                  } else if (_selectedBrand == 'Samsung') {
                    _selectedProtocol = 'SAMSUNG';
                    _selectedFrequency = 38000;
                  } else {
                    _selectedProtocol = 'NEC';
                    _selectedFrequency = 38000;
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            // Protocol & Frequency
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Protocol', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedProtocol,
                        dropdownColor: const Color(0xFF1E2430),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1E2430),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['NEC', 'SAMSUNG', 'SONY_SIRC', 'RC5']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedProtocol = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: _selectedFrequency,
                        dropdownColor: const Color(0xFF1E2430),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF1E2430),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [36000, 38000, 40000, 56000]
                            .map((f) => DropdownMenuItem(value: f, child: Text('${f} Hz')))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedFrequency = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Test Commands
            const Text('Test Commands', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['POWER', 'VOL+', 'VOL-', 'CH+', 'CH-', 'MUTE'].map((cmd) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cmd == 'POWER' ? Colors.redAccent : const Color(0xFF1E2430),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: Text(cmd, style: const TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => _transmitTest(cmd),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            // Transmission Status
            if (_transmissionStatus != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2430),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Transmission Result:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      _transmissionStatus!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _transmissionStatus!.startsWith('✓') ? const Color(0xFF00E676) : Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Feedback: Did the device respond?
              const Text('Device Response (Physical Confirmation):', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.black),
                      label: const Text('Device Responded'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        HapticHelper.rockerPress();
                        setState(() {
                          _deviceResponseStatus = 'CONFIRMED: $_selectedBrand responded to $_lastCommandSent!';
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Did Not Respond'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        setState(() {
                          _deviceResponseStatus = 'NOT RESPONDING: Try another protocol or brand profile.';
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
            if (_deviceResponseStatus != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _deviceResponseStatus!.startsWith('CONFIRMED')
                      ? const Color(0xFF00E676).withOpacity(0.15)
                      : Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _deviceResponseStatus!.startsWith('CONFIRMED')
                        ? const Color(0xFF00E676)
                        : Colors.orange,
                  ),
                ),
                child: Text(
                  _deviceResponseStatus!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _deviceResponseStatus!.startsWith('CONFIRMED')
                        ? const Color(0xFF00E676)
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
