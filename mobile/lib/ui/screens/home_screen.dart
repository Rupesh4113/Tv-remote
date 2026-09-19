import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database/storage_service.dart';
import '../../data/models/device_model.dart';
import '../../services/combined_remote_service.dart';
import '../../services/remote_controller.dart';
import '../../services/voice_command_service.dart';
import 'add_device_wizard.dart';
import 'combined_remote_screen.dart';
import 'learning_mode_screen.dart';
import 'macros_screen.dart';
import 'settings_screen.dart';
import 'stb_remote_screen.dart';
import 'tv_remote_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  final TextEditingController _voiceInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialDevices();
  }

  void _loadInitialDevices() {
    final storage = Provider.of<StorageService>(context, listen: false);
    final controller = Provider.of<RemoteController>(context, listen: false);
    final combined = Provider.of<CombinedRemoteService>(context, listen: false);

    final devices = storage.getDevices();
    if (devices.isEmpty) {
      // Seed default sample devices for Indian TV & STB
      final tv = DeviceModel(
        id: 'sample_tv',
        name: 'Sony Bravia 4K TV',
        brand: 'Sony',
        category: DeviceCategory.tv,
        profileId: 'tv-sony-bravia',
        activeTransport: TransportType.wifi,
        ipAddress: '192.168.1.20',
        port: 80,
      );
      final stb = DeviceModel(
        id: 'sample_stb',
        name: 'Tata Play HD STB',
        brand: 'Tata Play',
        category: DeviceCategory.setTopBox,
        profileId: 'stb-tata-play',
        activeTransport: TransportType.ir,
      );
      storage.saveDevice(tv);
      storage.saveDevice(stb);
      controller.setActiveDevice(tv);
      combined.setDevices(tv: tv, stb: stb);
    } else {
      final tv = devices.firstWhere(
        (d) => d.category == DeviceCategory.tv,
        orElse: () => devices.first,
      );
      final stb = devices.firstWhere(
        (d) => d.category == DeviceCategory.setTopBox,
        orElse: () => devices.last,
      );
      controller.setActiveDevice(tv);
      combined.setDevices(tv: tv, stb: stb);
    }
  }

  void _showVoiceCommandDialog() {
    final voiceService = Provider.of<VoiceCommandService>(context, listen: false);
    final storage = Provider.of<StorageService>(context, listen: false);
    final devices = storage.getDevices();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.mic, color: Color(0xFF00E5FF)),
            SizedBox(width: 10),
            Text('Voice Control'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Speak or type a command:\n• "Turn on TV"\n• "Volume up 5"\n• "Change to channel 205"\n• "Open Netflix"',
              style: TextStyle(fontSize: 13, color: Colors.white70),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _voiceInputController,
              decoration: const InputDecoration(
                hintText: 'e.g. increase volume by 3',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (val) async {
                Navigator.pop(ctx);
                final res = await voiceService.executeVoiceQuery(val, devices);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.responseMessage)),
                  );
                }
                _voiceInputController.clear();
              },
            ),
          ],
        ),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: const Text('Execute'),
            onPressed: () async {
              final val = _voiceInputController.text.trim();
              if (val.isNotEmpty) {
                Navigator.pop(ctx);
                final res = await voiceService.executeVoiceQuery(val, devices);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.responseMessage)),
                  );
                }
                _voiceInputController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesListTab(StorageService storage, RemoteController controller) {
    final devices = storage.getDevices();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Saved Remotes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddDeviceWizard()),
                  ).then((_) => setState(() {}));
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: devices.isEmpty
                ? const Center(child: Text('No devices saved yet.'))
                : ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (_, i) {
                      final d = devices[i];
                      final isActive = controller.activeDevice?.id == d.id;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            d.category == DeviceCategory.setTopBox
                                ? Icons.satellite_alt_rounded
                                : Icons.tv,
                            color: const Color(0xFF00E5FF),
                          ),
                          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${d.brand} • ${d.activeTransport.name.toUpperCase()}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00E676).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () async {
                                  await storage.deleteDevice(d.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            controller.setActiveDevice(d);
                            setState(() {
                              _currentTabIndex = d.category == DeviceCategory.setTopBox ? 1 : 0;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storage = Provider.of<StorageService>(context);
    final controller = Provider.of<RemoteController>(context);

    final tabs = [
      const TvRemoteScreen(),
      const StbRemoteScreen(),
      const CombinedRemoteScreen(),
      _buildDevicesListTab(storage, controller),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentTabIndex == 0
              ? 'TV Remote'
              : (_currentTabIndex == 1
                  ? 'Set-Top Box'
                  : (_currentTabIndex == 2 ? 'Combined Remote' : 'My Devices')),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic, color: Color(0xFF00E5FF)),
            tooltip: 'Voice Control',
            onPressed: _showVoiceCommandDialog,
          ),
          IconButton(
            icon: const Icon(Icons.cell_tower_rounded),
            tooltip: 'Learn IR Button',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LearningModeScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high_rounded),
            tooltip: 'Macros',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MacrosScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: tabs[_currentTabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTabIndex,
        onDestinationSelected: (idx) => setState(() => _currentTabIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tv),
            label: 'TV',
          ),
          NavigationDestination(
            icon: Icon(Icons.satellite_alt_rounded),
            label: 'Set-Top Box',
          ),
          NavigationDestination(
            icon: Icon(Icons.merge_type_rounded),
            label: 'Combined',
          ),
          NavigationDestination(
            icon: Icon(Icons.devices_other_rounded),
            label: 'Devices',
          ),
        ],
      ),
    );
  }
}
