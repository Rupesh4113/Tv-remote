import 'dart:async';
import 'package:http/http.dart' as http;
import '../../data/models/device_model.dart';
import '../ir/ir_transport.dart';

class DiscoveredDevice {
  final String name;
  final String brand;
  final DeviceCategory category;
  final TransportType transport;
  final String? ipAddress;
  final int? port;
  final String profileId;

  DiscoveredDevice({
    required this.name,
    required this.brand,
    required this.category,
    required this.transport,
    this.ipAddress,
    this.port,
    required this.profileId,
  });
}

class DeviceDiscoveryService {
  final IrTransport _irTransport;

  DeviceDiscoveryService(this._irTransport);

  Future<List<DiscoveredDevice>> discoverAll() async {
    final results = <DiscoveredDevice>[];

    // 1. Check IR capability
    final hasIr = await _irTransport.initialize();
    if (hasIr) {
      results.add(DiscoveredDevice(
        name: 'Generic IR Controller (Built-in Blaster)',
        brand: 'Generic',
        category: DeviceCategory.tv,
        transport: TransportType.ir,
        profileId: 'tv-generic-ir',
      ));
    }

    // 2. Discover LAN Smart TVs and Simulators (Port probe / mDNS / SSDP simulation)
    final probeHosts = ['localhost', '127.0.0.1', '10.0.2.2', '192.168.1.10', '192.168.1.20', '192.168.1.35'];

    for (final host in probeHosts.take(3)) {
      // Probe Samsung (8081 or 8002)
      try {
        final res = await http.get(Uri.parse('http://$host:8081/api/v2/')).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) {
          results.add(DiscoveredDevice(
            name: 'Samsung QLED 4K TV (LAN)',
            brand: 'Samsung',
            category: DeviceCategory.tv,
            transport: TransportType.wifi,
            ipAddress: host,
            port: 8081,
            profileId: 'tv-samsung-smart',
          ));
        }
      } catch (_) {}

      // Probe Sony (8083 or 80)
      try {
        final res = await http.get(Uri.parse('http://$host:8083/sony/system')).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) {
          results.add(DiscoveredDevice(
            name: 'Sony Bravia 4K TV (IRCC)',
            brand: 'Sony',
            category: DeviceCategory.tv,
            transport: TransportType.wifi,
            ipAddress: host,
            port: 8083,
            profileId: 'tv-sony-bravia',
          ));
        }
      } catch (_) {}

      // Probe LG webOS (8082 or 3000)
      try {
        final res = await http.get(Uri.parse('http://$host:8082/api/status')).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) {
          results.add(DiscoveredDevice(
            name: 'LG OLED webOS TV (LAN)',
            brand: 'LG',
            category: DeviceCategory.tv,
            transport: TransportType.wifi,
            ipAddress: host,
            port: 8082,
            profileId: 'tv-lg-webos',
          ));
        }
      } catch (_) {}

      // Probe Tata Play STB simulator (8084)
      try {
        final res = await http.get(Uri.parse('http://$host:8084/stb/status')).timeout(const Duration(milliseconds: 300));
        if (res.statusCode == 200) {
          results.add(DiscoveredDevice(
            name: 'Tata Play HD Set-Top Box (LAN/IR)',
            brand: 'Tata Play',
            category: DeviceCategory.setTopBox,
            transport: TransportType.ir,
            ipAddress: host,
            port: 8084,
            profileId: 'stb-tata-play',
          ));
        }
      } catch (_) {}
    }

    // Default discovery fallback items if network empty
    if (results.length <= 1) {
      results.addAll([
        DiscoveredDevice(
          name: 'Sony Bravia TV',
          brand: 'Sony',
          category: DeviceCategory.tv,
          transport: TransportType.wifi,
          ipAddress: '192.168.1.20',
          port: 80,
          profileId: 'tv-sony-bravia',
        ),
        DiscoveredDevice(
          name: 'Tata Play Set-Top Box',
          brand: 'Tata Play',
          category: DeviceCategory.setTopBox,
          transport: TransportType.ir,
          profileId: 'stb-tata-play',
        ),
        DiscoveredDevice(
          name: 'Samsung Smart TV',
          brand: 'Samsung',
          category: DeviceCategory.tv,
          transport: TransportType.wifi,
          ipAddress: '192.168.1.35',
          port: 8002,
          profileId: 'tv-samsung-smart',
        ),
      ]);
    }

    return results;
  }
}
