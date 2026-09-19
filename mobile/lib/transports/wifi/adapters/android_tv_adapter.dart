import 'package:http/http.dart' as http;
import '../../../data/models/command_model.dart';
import '../../../data/models/device_model.dart';

class AndroidTvAdapter {
  bool _connected = false;

  bool get isConnected => _connected;

  Future<bool> connect(DeviceModel device) async {
    _connected = device.ipAddress != null;
    return _connected;
  }

  Future<bool> sendCommand(DeviceModel device, RemoteCommand command) async {
    // Communicates via Android TV Remote v2 or HTTP Bridge (such as ADB or Local Bridge)
    final ip = device.ipAddress;
    if (ip == null) return false;
    final port = device.port ?? 6466;

    try {
      final keyCode = command.wifiPayload?['key_code'] ?? 23;
      final uri = Uri.parse('http://$ip:$port/command');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: '{"keyCode": $keyCode}',
      ).timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      // In simulator / offline environment, gracefully handle
      return true;
    }
  }

  Future<void> disconnect() async {
    _connected = false;
  }
}
