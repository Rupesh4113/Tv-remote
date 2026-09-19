import 'package:http/http.dart' as http;
import '../../../data/models/command_model.dart';
import '../../../data/models/device_model.dart';

class RokuAdapter {
  Future<bool> sendCommand(DeviceModel device, RemoteCommand command) async {
    final ip = device.ipAddress;
    if (ip == null) return false;
    final key = command.key;

    try {
      final uri = Uri.parse('http://$ip:8060/keypress/$key');
      final res = await http.post(uri).timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

class GenericHttpAdapter {
  Future<bool> sendCommand(DeviceModel device, RemoteCommand command) async {
    final ip = device.ipAddress;
    if (ip == null) return false;
    final port = device.port ?? 8080;

    try {
      final uri = Uri.parse('http://$ip:$port/command');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: '{"command": "${command.key}"}',
      ).timeout(const Duration(milliseconds: 1500));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
