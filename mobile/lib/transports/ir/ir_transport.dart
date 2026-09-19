import 'package:flutter/services.dart';
import '../../data/models/command_model.dart';
import '../../data/models/device_model.dart';
import '../base_transport.dart';
import 'protocol_encoders.dart';

class IrTransport implements BaseTransport {
  static const MethodChannel _channel = MethodChannel('org.remoteone.app/ir');

  bool _hasEmitter = false;
  bool _initialized = false;

  @override
  TransportType get type => TransportType.ir;

  @override
  bool get isConnected => _hasEmitter;

  bool get hasEmitter => _hasEmitter;

  @override
  Future<bool> initialize() async {
    if (_initialized) return _hasEmitter;
    try {
      final result = await _channel.invokeMethod<bool>('hasIrEmitter');
      _hasEmitter = result ?? false;
    } catch (_) {
      // Platform does not support IR or method channel unavailable (e.g. iOS or emulator)
      _hasEmitter = false;
    }
    _initialized = true;
    return _hasEmitter;
  }

  @override
  Future<bool> connect(DeviceModel device) async {
    await initialize();
    return _hasEmitter;
  }

  @override
  Future<bool> sendCommand(DeviceModel device, RemoteCommand command) async {
    if (!_hasEmitter) {
      return false;
    }

    try {
      int carrier = 38000;
      List<int> pattern = [];

      if (command.irPattern != null && command.irPattern!.isNotEmpty) {
        pattern = command.irPattern!;
      } else if (command.irHex != null) {
        final encoded = IrProtocolEncoders.encode('NEC', command.irHex!);
        carrier = encoded.carrierFrequencyHz;
        pattern = encoded.pattern;
      } else {
        return false;
      }

      final success = await _channel.invokeMethod<bool>('transmit', {
        'frequency': carrier,
        'pattern': pattern,
      });
      return success ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    // IR is connectionless
  }
}
