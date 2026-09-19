import 'package:http/http.dart' as http;
import '../../../data/models/command_model.dart';
import '../../../data/models/device_model.dart';

class SonyAdapter {
  bool _connected = false;

  bool get isConnected => _connected;

  Future<bool> connect(DeviceModel device) async {
    final ip = device.ipAddress;
    if (ip == null) return false;
    _connected = true;
    return true;
  }

  Future<bool> sendCommand(DeviceModel device, RemoteCommand command) async {
    final ip = device.ipAddress;
    if (ip == null) return false;
    final port = device.port ?? 80;
    final psk = device.authKey ?? '0000';
    final irccCode = command.wifiPayload?['ircc_code'] ?? 'AAAAAQAAAAEAAAAVAw==';

    final envelope = '''<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1">
      <IRCCCode>$irccCode</IRCCCode>
    </u:X_SendIRCC>
  </s:Body>
</s:Envelope>''';

    try {
      final url = Uri.parse('http://$ip:$port/sony/ircc');
      final response = await http.post(
        url,
        headers: {
          'X-Auth-PSK': psk,
          'Content-Type': 'text/xml; charset=UTF-8',
          'SOAPACTION': '"urn:schemas-sony-com:service:IRCC:1#X_SendIRCC"',
        },
        body: envelope,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    _connected = false;
  }
}
