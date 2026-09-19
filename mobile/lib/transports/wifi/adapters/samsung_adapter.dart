import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/models/command_model.dart';
import '../../../data/models/device_model.dart';

class SamsungAdapter {
  WebSocketChannel? _channel;
  bool _connected = false;

  bool get isConnected => _connected;

  Future<bool> connect(DeviceModel device) async {
    final ip = device.ipAddress;
    if (ip == null) return false;
    final port = device.port ?? 8002;
    final token = device.authKey;

    try {
      final appNameB64 = base64Encode(utf8.encode('RemoteOne'));
      final tokenParam = token != null ? '&token=$token' : '';
      final wsUrl = port == 8001
          ? 'ws://$ip:$port/api/v2/channels/samsung.remote.control?name=$appNameB64$tokenParam'
          : 'ws://$ip:$port/api/v2/channels/samsung.remote.control?name=$appNameB64$tokenParam';

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _connected = true;

      _channel!.stream.listen(
        (message) {
          // Process token or ACK events
        },
        onError: (err) {
          _connected = false;
        },
        onDone: () {
          _connected = false;
        },
      );
      return true;
    } catch (_) {
      _connected = false;
      return false;
    }
  }

  Future<bool> sendCommand(RemoteCommand command) async {
    if (_channel == null) return false;
    final key = command.wifiPayload?['key'] ?? 'KEY_${command.key}';

    final payload = {
      'method': 'ms.remote.control',
      'params': {
        'Cmd': 'Click',
        'DataOfCmd': key,
        'Option': 'false',
        'TypeOfRemote': 'SendRemoteKey',
      },
    };

    try {
      _channel!.sink.add(jsonEncode(payload));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
    _connected = false;
  }
}
