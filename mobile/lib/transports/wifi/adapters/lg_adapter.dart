import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/models/command_model.dart';
import '../../../data/models/device_model.dart';

class LgAdapter {
  WebSocketChannel? _channel;
  bool _connected = false;
  int _reqId = 1;

  bool get isConnected => _connected;

  Future<bool> connect(DeviceModel device) async {
    final ip = device.ipAddress;
    if (ip == null) return false;
    final port = device.port ?? 3000;
    final clientKey = device.authKey ?? '';

    try {
      final wsUrl = 'ws://$ip:$port/';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _connected = true;

      // Send registration handshake
      final handshake = {
        'type': 'register',
        'id': 'reg_${_reqId++}',
        'payload': {
          'forcePairing': false,
          'pairingType': 'PROMPT',
          'client-key': clientKey,
          'manifest': {
            'manifestVersion': 1,
            'appVersion': '1.0.0',
            'signed': {
              'created': '20260101',
              'appId': 'org.remoteone.app',
              'vendorId': 'org.remoteone',
              'localizedAppNames': {'': 'RemoteOne'},
              'permissions': [
                'CONTROL_INPUT_TEXT',
                'CONTROL_MOUSE_AND_KEYBOARD',
                'READ_INSTALLED_APPS',
              ],
            },
          },
        },
      };

      _channel!.sink.add(jsonEncode(handshake));
      return true;
    } catch (_) {
      _connected = false;
      return false;
    }
  }

  Future<bool> sendCommand(RemoteCommand command) async {
    if (_channel == null) return false;

    final uri = command.wifiPayload?['uri'] ?? 'ssap://system/turnOff';
    final payload = command.wifiPayload?['payload'] ?? {};

    final msg = {
      'type': 'request',
      'id': 'cmd_${_reqId++}',
      'uri': uri,
      'payload': payload,
    };

    try {
      _channel!.sink.add(jsonEncode(msg));
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
