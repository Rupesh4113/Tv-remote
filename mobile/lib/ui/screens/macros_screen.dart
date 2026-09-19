import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/storage_service.dart';
import '../../data/models/macro_model.dart';
import '../../services/macro_runner.dart';

class MacrosScreen extends StatefulWidget {
  const MacrosScreen({super.key});

  @override
  State<MacrosScreen> createState() => _MacrosScreenState();
}

class _MacrosScreenState extends State<MacrosScreen> {
  void _createSampleMacro(StorageService storage) async {
    final sample = MacroModel(
      id: 'macro_watch_tv',
      name: 'Watch TV (Movie Mode)',
      description: 'Powers TV, switches to HDMI 1, turns on Set-Top Box',
      steps: [
        MacroStepModel(
          targetDeviceId: 'tv',
          targetDeviceName: 'Living Room TV',
          commandKey: 'POWER',
          commandLabel: 'Turn TV ON',
          delayMs: 1200,
        ),
        MacroStepModel(
          targetDeviceId: 'tv',
          targetDeviceName: 'Living Room TV',
          commandKey: 'SOURCE',
          commandLabel: 'Set HDMI 1',
          delayMs: 800,
        ),
        MacroStepModel(
          targetDeviceId: 'stb',
          targetDeviceName: 'Tata Play STB',
          commandKey: 'POWER',
          commandLabel: 'Turn Set-Top Box ON',
          delayMs: 500,
        ),
      ],
    );
    await storage.saveMacro(sample);
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final runner = Provider.of<MacroRunner>(context);
    final macros = storage.getMacros();
    final devices = storage.getDevices();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automation Macros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createSampleMacro(storage),
            tooltip: 'Add Macro',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (runner.isRunning) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5FF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF00E5FF)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Step ${runner.currentStepIndex} of ${runner.totalSteps}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              runner.currentStepDescription ?? 'Running macro...',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'Execute Multi-Command Sequences',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 6),
              const Text(
                'Chain multiple remote commands with configurable delays between TV and STB.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: macros.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_fix_high_rounded, size: 48, color: Colors.white38),
                            const SizedBox(height: 12),
                            const Text('No custom macros created yet.'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              child: const Text('Add "Watch TV" Template'),
                              onPressed: () => _createSampleMacro(storage),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: macros.length,
                        itemBuilder: (_, i) {
                          final m = macros[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        m.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                                        onPressed: () => storage.deleteMacro(m.id),
                                      ),
                                    ],
                                  ),
                                  Text(m.description, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: m.steps.map((step) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.play_arrow, size: 14, color: Color(0xFF00E5FF)),
                                            const SizedBox(width: 6),
                                            Text(step.commandLabel, style: const TextStyle(fontSize: 13)),
                                            const Spacer(),
                                            Text('${step.delayMs}ms', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 14),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.play_circle_filled_rounded),
                                      label: const Text('Execute Macro'),
                                      onPressed: runner.isRunning ? null : () => runner.runMacro(m, devices),
                                    ),
                                  ),
                                ],
                              ),
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
