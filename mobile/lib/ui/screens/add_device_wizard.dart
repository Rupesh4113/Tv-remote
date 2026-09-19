import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../data/database/storage_service.dart';
import '../../data/models/device_model.dart';
import '../../services/remote_controller.dart';
import '../../transports/discovery/device_discovery_service.dart';
import '../../transports/ir/ir_transport.dart';

class AddDeviceWizard extends StatefulWidget {
  final int initialStep;
  const AddDeviceWizard({super.key, this.initialStep = 0});

  @override
  State<AddDeviceWizard> createState() => _AddDeviceWizardState();
}

class _AddDeviceWizardState extends State<AddDeviceWizard> {
  int _currentStep = 0;
  String _selectedDeviceType = 'TV';
  TransportType _selectedTransport = TransportType.wifi;
  String _selectedBrand = 'Samsung';
  String _searchQuery = '';
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(text: 'Living Room TV');

  bool _hasIrHardware = false;
  bool _isCheckingHardware = true;
  bool _isScanning = false;
  List<DiscoveredDevice> _discoveredDevices = [];
  int _currentCandidateIndex = 1;
  int _totalCandidates = 5;
  bool _deviceConfirmed = false;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _checkHardwareAndScan();
  }

  Future<void> _checkHardwareAndScan() async {
    final irTransport = Provider.of<IrTransport>(context, listen: false);
    final hasIr = await irTransport.initialize();

    setState(() {
      _hasIrHardware = hasIr;
      _isCheckingHardware = false;
      if (!hasIr && _selectedTransport == TransportType.ir) {
        _selectedTransport = TransportType.wifi;
      }
    });

    if (widget.initialStep == 1) {
      _runDiscovery();
    }
  }

  Future<void> _runDiscovery() async {
    setState(() => _isScanning = true);
    final irTransport = Provider.of<IrTransport>(context, listen: false);
    final discoveryService = DeviceDiscoveryService(irTransport);
    final list = await discoveryService.discoverAll();
    setState(() {
      _discoveredDevices = list;
      _isScanning = false;
    });
  }

  Widget _buildStep1DeviceType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Device Type',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose the device you want to control:',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: AppConstants.deviceTypes.map((type) {
              final isSelected = _selectedDeviceType == type;
              IconData icon = Icons.tv;
              if (type == 'Set-Top Box') icon = Icons.satellite_alt_rounded;
              if (type == 'Soundbar') icon = Icons.speaker_rounded;
              if (type == 'Streaming Device') icon = Icons.stream_rounded;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedDeviceType = type;
                    _nameController.text = 'My $type';
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00E5FF).withOpacity(0.15)
                        : const Color(0xFF1E2430),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF00E5FF) : Colors.white12,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 40, color: isSelected ? const Color(0xFF00E5FF) : Colors.white70),
                      const SizedBox(height: 12),
                      Text(
                        type,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF00E5FF) : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Connection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Connection Mode',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hardware availability on this device:',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        // IR Option
        Card(
          child: ListTile(
            enabled: _hasIrHardware,
            leading: Icon(
              Icons.settings_input_antenna,
              color: _hasIrHardware ? const Color(0xFF00E5FF) : Colors.white30,
            ),
            title: const Text('Infrared (IR)'),
            subtitle: Text(
              _hasIrHardware
                  ? 'Hardware IR blaster detected on this phone'
                  : 'IR is not available on this phone. Try Wi-Fi or Bluetooth.',
              style: TextStyle(
                color: _hasIrHardware ? Colors.white60 : Colors.amberAccent,
                fontSize: 12,
              ),
            ),
            trailing: Radio<TransportType>(
              value: TransportType.ir,
              groupValue: _selectedTransport,
              onChanged: _hasIrHardware ? (v) => setState(() => _selectedTransport = v!) : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Wi-Fi Option
        Card(
          child: ListTile(
            leading: const Icon(Icons.wifi_rounded, color: Color(0xFF00E5FF)),
            title: const Text('Wi-Fi / LAN'),
            subtitle: const Text('Smart TVs connected to same local network', style: TextStyle(fontSize: 12)),
            trailing: Radio<TransportType>(
              value: TransportType.wifi,
              groupValue: _selectedTransport,
              onChanged: (v) => setState(() => _selectedTransport = v!),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Bluetooth Option
        Card(
          child: ListTile(
            leading: const Icon(Icons.bluetooth_rounded, color: Color(0xFF00E5FF)),
            title: const Text('Bluetooth / BLE'),
            subtitle: const Text('Wireless connection for compatible remotes', style: TextStyle(fontSize: 12)),
            trailing: Radio<TransportType>(
              value: TransportType.bluetooth,
              groupValue: _selectedTransport,
              onChanged: (v) => setState(() => _selectedTransport = v!),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Discover LAN devices
        Center(
          child: ElevatedButton.icon(
            icon: _isScanning
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.radar_rounded),
            label: Text(_isScanning ? 'Scanning Network...' : 'Scan Local Network'),
            onPressed: _isScanning ? null : _runDiscovery,
          ),
        ),
        const SizedBox(height: 14),
        if (_discoveredDevices.isNotEmpty) ...[
          const Text('Available Devices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _discoveredDevices.length,
              itemBuilder: (_, i) {
                final d = _discoveredDevices[i];
                return ListTile(
                  title: Text(d.name),
                  subtitle: Text('${d.transport.name.toUpperCase()} • ${d.ipAddress ?? "Local"}'),
                  trailing: ElevatedButton(
                    child: const Text('Connect'),
                    onPressed: () {
                      setState(() {
                        _selectedBrand = d.brand;
                        _selectedTransport = d.transport;
                        _nameController.text = d.name;
                        _currentStep = 3; // Go straight to test & pair
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ] else
          const Spacer(),
      ],
    );
  }

  Widget _buildStep3Brand() {
    final list = _selectedDeviceType == 'Set-Top Box'
        ? AppConstants.stbProviders
        : AppConstants.tvBrands;

    final filtered = list
        .where((b) => b.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select ${_selectedDeviceType == 'Set-Top Box' ? 'Provider' : 'Brand'}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search brand (e.g. Tata Play, Sony, Samsung, Vu)',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFF1E2430),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (val) => setState(() => _searchQuery = val),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final brand = filtered[i];
              final isSelected = _selectedBrand == brand;
              return ListTile(
                title: Text(brand, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Color(0xFF00E5FF)) : null,
                onTap: () {
                  setState(() {
                    _selectedBrand = brand;
                    _nameController.text = '$_selectedBrand $_selectedDeviceType';
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStep4PairAndTest() {
    final requiresPin = _selectedTransport == TransportType.wifi &&
        (_selectedBrand == 'LG' || _selectedBrand == 'Sony' || _selectedBrand == 'Xiaomi');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pair & Verify Device',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Device Name'),
                  ),
                  const SizedBox(height: 8),
                  Text('Brand: $_selectedBrand', style: const TextStyle(color: Colors.white70)),
                  Text('Type: $_selectedDeviceType', style: const TextStyle(color: Colors.white70)),
                  Text('Connection: ${_selectedTransport.name.toUpperCase()}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (requiresPin) ...[
            const Text(
              'Enter PIN displayed on TV:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 1234',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_selectedTransport == TransportType.ir) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2430),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'IR Code Set $_currentCandidateIndex of $_totalCandidates',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00E5FF)),
                      ),
                      Text(
                        _deviceConfirmed ? '✓ Confirmed' : 'Testing...',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _deviceConfirmed ? const Color(0xFF00E676) : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Point the top of your phone toward the TV/STB and press TEST POWER:',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('TEST POWER BUTTON'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final controller = Provider.of<RemoteController>(context, listen: false);
                        controller.sendKey('POWER');
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Did the device respond (turn ON/OFF)?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.navigate_next),
                          label: const Text('NO (Try Next)'),
                          onPressed: () {
                            setState(() {
                              if (_currentCandidateIndex < _totalCandidates) {
                                _currentCandidateIndex++;
                              } else {
                                _currentCandidateIndex = 1;
                              }
                              _deviceConfirmed = false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check, color: Colors.black),
                          label: const Text('YES (Works)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            setState(() {
                              _deviceConfirmed = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            const Text(
              'Test Remote Buttons:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('Power'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    final controller = Provider.of<RemoteController>(context, listen: false);
                    controller.sendKey('POWER');
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Vol +'),
                  onPressed: () {
                    final controller = Provider.of<RemoteController>(context, listen: false);
                    controller.sendKey('VOLUME_UP');
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_upward),
                  label: const Text('Ch +'),
                  onPressed: () {
                    final controller = Provider.of<RemoteController>(context, listen: false);
                    controller.sendKey('CHANNEL_UP');
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Save & Open Remote', style: TextStyle(fontSize: 16)),
              onPressed: () async {
                final storage = Provider.of<StorageService>(context, listen: false);
                final controller = Provider.of<RemoteController>(context, listen: false);

                final device = DeviceModel(
                  id: 'dev_${DateTime.now().millisecondsSinceEpoch}',
                  name: _nameController.text.trim(),
                  brand: _selectedBrand,
                  category: _selectedDeviceType == 'Set-Top Box'
                      ? DeviceCategory.setTopBox
                      : DeviceCategory.tv,
                  profileId: _selectedBrand.toLowerCase().contains('tata')
                      ? 'stb-tata-play'
                      : (_selectedBrand.toLowerCase().contains('samsung')
                          ? 'tv-samsung-smart'
                          : 'tv-generic-ir'),
                  activeTransport: _selectedTransport,
                  authKey: _pinController.text.trim(),
                  ipAddress: '192.168.1.20',
                );

                await storage.saveDevice(device);
                await storage.setDefaultDeviceId(device.id);
                controller.setActiveDevice(device);

                if (mounted) {
                  Navigator.pop(context);
                }
              },
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
        title: const Text('Add Device'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              // Progress indicators
              Row(
                children: List.generate(4, (index) {
                  final isDone = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF00E5FF) : Colors.white12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: [
                  _buildStep1DeviceType(),
                  _buildStep2Connection(),
                  _buildStep3Brand(),
                  _buildStep4PairAndTest(),
                ][_currentStep],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    TextButton(
                      child: const Text('Back'),
                      onPressed: () => setState(() => _currentStep--),
                    )
                  else
                    const SizedBox.shrink(),
                  if (_currentStep < 3)
                    ElevatedButton(
                      child: const Text('Next'),
                      onPressed: () => setState(() => _currentStep++),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
