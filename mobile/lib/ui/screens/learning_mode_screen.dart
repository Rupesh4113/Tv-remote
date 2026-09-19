import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/haptics.dart';
import '../../data/database/storage_service.dart';
import '../../services/remote_controller.dart';
import '../../transports/ir/ir_transport.dart';

class LearningModeScreen extends StatefulWidget {
  const LearningModeScreen({super.key});

  @override
  State<LearningModeScreen> createState() => _LearningModeScreenState();
}

class _LearningModeScreenState extends State<LearningModeScreen> {
  String _selectedButton = 'Volume +';
  bool _isListening = false;
  bool _signalCaptured = false;
  Map<String, dynamic>? _capturedSignal;

  final List<String> _targetButtons = [
    'Power', 'Volume +', 'Volume -', 'Mute',
    'Channel +', 'Channel -', 'Guide', 'Menu',
    'Up', 'Down', 'Left', 'Right', 'OK',
    'Custom Button 1', 'Custom Button 2'
  ];

  void _startLearning() {
    setState(() {
      _isListening = true;
      _signalCaptured = false;
      _capturedSignal = null;
    });

    // Simulate IR receiver capturing pulse timings
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isListening = false;
          _signalCaptured = true;
          _capturedSignal = {
            'protocol': 'NEC',
            'carrier_frequency_hz': 38000,
            'hex': '0x00BF02FD',
            'pattern': [9000, 4500, 560, 560, 560, 1690, 560, 560, 560],
            'timestamp': DateTime.now().toIso8601String(),
          };
        });
        HapticHelper.rockerPress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final irTransport = Provider.of<IrTransport>(context);
    final learned = storage.getLearnedCommands();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn Remote Button'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!irTransport.hasEmitter) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'IR blaster is not detected on this phone. Learning mode runs in simulation mode.',
                          style: TextStyle(color: Colors.amber, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                '1. Select Target Button',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedButton,
                dropdownColor: const Color(0xFF1E2430),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E2430),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _targetButtons.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setState(() => _selectedButton = val!),
              ),
              const SizedBox(height: 24),
              const Text(
                '2. Capture Signal from Physical Remote',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2430),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Icon(
                      _signalCaptured
                          ? Icons.check_circle_rounded
                          : (_isListening ? Icons.sensors_rounded : Icons.cell_tower_rounded),
                      size: 54,
                      color: _signalCaptured
                          ? const Color(0xFF00E676)
                          : (_isListening ? const Color(0xFF00E5FF) : Colors.white54),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isListening
                          ? 'Point original remote toward phone top & press [$_selectedButton]...'
                          : (_signalCaptured ? '✓ Signal Captured Successfully!' : 'Ready to capture'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _signalCaptured ? const Color(0xFF00E676) : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(_isListening ? Icons.hourglass_top : Icons.play_arrow),
                      label: Text(_isListening ? 'Receiving IR signal...' : 'Start Capture'),
                      onPressed: _isListening ? null : _startLearning,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_signalCaptured) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.play_circle_outline),
                      label: const Text('Test Signal'),
                      onPressed: () {
                        final controller = Provider.of<RemoteController>(context, listen: false);
                        controller.sendKey('CUSTOM_LEARNED', label: _selectedButton);
                      },
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Button'),
                      onPressed: () async {
                        if (_capturedSignal != null) {
                          await storage.saveLearnedCommand(_selectedButton, _capturedSignal!);
                          setState(() {
                            _signalCaptured = false;
                            _capturedSignal = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Saved [$_selectedButton] command locally!')),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'Saved Learned Buttons',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: learned.isEmpty
                    ? const Center(
                        child: Text('No learned buttons saved yet.', style: TextStyle(color: Colors.white54)),
                      )
                    : ListView.builder(
                        itemCount: learned.keys.length,
                        itemBuilder: (_, i) {
                          final key = learned.keys.elementAt(i);
                          return ListTile(
                            leading: const Icon(Icons.code, color: Color(0xFF00E5FF)),
                            title: Text(key),
                            subtitle: Text('Format: ${learned[key]?['protocol'] ?? "NEC"}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => storage.deleteLearnedCommand(key),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
