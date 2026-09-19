import 'package:flutter/foundation.dart';
import '../core/diagnostic_logger.dart';
import '../core/haptics.dart';
import '../data/models/command_model.dart';
import '../data/models/device_model.dart';
import '../transports/base_transport.dart';
import '../transports/bluetooth/bluetooth_transport.dart';
import '../transports/ir/ir_transport.dart';
import '../transports/wifi/wifi_transport.dart';

class RemoteController extends ChangeNotifier {
  final IrTransport irTransport;
  final WiFiTransport wifiTransport;
  final BluetoothTransport bleTransport;

  DeviceModel? _activeDevice;
  bool _isTransmitting = false;
  String? _lastError;
  String? _lastSentKey;

  RemoteController({
    required this.irTransport,
    required this.wifiTransport,
    required this.bleTransport,
  });

  DeviceModel? get activeDevice => _activeDevice;
  bool get isTransmitting => _isTransmitting;
  String? get lastError => _lastError;
  String? get lastSentKey => _lastSentKey;

  void setActiveDevice(DeviceModel? device) {
    _activeDevice = device;
    _lastError = null;
    notifyListeners();
  }

  BaseTransport _getTransportForDevice(DeviceModel device) {
    switch (device.activeTransport) {
      case TransportType.wifi:
        return wifiTransport;
      case TransportType.bluetooth:
        return bleTransport;
      case TransportType.ir:
      default:
        return irTransport;
    }
  }

  Future<bool> sendKey(String key, {String? label, String? irHex, Map<String, dynamic>? wifiPayload}) async {
    if (_activeDevice == null) {
      _lastError = 'No active device selected';
      notifyListeners();
      return false;
    }

    final command = RemoteCommand(
      key: key,
      label: label ?? key,
      irHex: irHex,
      wifiPayload: wifiPayload,
    );

    return await executeCommand(_activeDevice!, command);
  }

  Future<bool> executeCommand(DeviceModel device, RemoteCommand command) async {
    _isTransmitting = true;
    _lastSentKey = command.key;
    _lastError = null;
    notifyListeners();

    // Trigger haptic feedback
    if (command.key == 'POWER') {
      HapticHelper.powerPress();
    } else if (command.key.contains('VOLUME') || command.key.contains('CHANNEL')) {
      HapticHelper.rockerPress();
    } else {
      HapticHelper.buttonPress();
    }

    bool success = false;
    final transport = _getTransportForDevice(device);

    try {
      success = await transport.sendCommand(device, command);

      if (!success && device.activeTransport == TransportType.ir && !irTransport.hasEmitter) {
        _lastError = 'IR is not available on this phone. Try Wi-Fi or Bluetooth.';
        HapticHelper.errorVibrate();
      } else if (!success) {
        _lastError = 'Failed to transmit to ${device.name}. Check connection.';
      }
    } catch (e) {
      _lastError = 'Error sending command: $e';
      success = false;
    } finally {
      _isTransmitting = false;
      DiagnosticLogger.instance.log(
        device: device.name,
        transport: device.activeTransport.name.toUpperCase(),
        protocol: device.activeTransport == TransportType.ir ? 'NEC/RAW' : 'IP/GATT',
        frequency: device.activeTransport == TransportType.ir ? 38000 : 0,
        command: command.key,
        status: success ? 'SUCCESS' : 'FAILED',
        detail: _lastError,
      );
      notifyListeners();
    }

    return success;
  }
}
