import '../../data/models/command_model.dart';
import '../../data/models/device_model.dart';
import '../base_transport.dart';

class BluetoothTransport implements BaseTransport {
  bool _connected = false;
  String? _connectedDeviceId;

  @override
  TransportType get type => TransportType.bluetooth;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  Future<bool> connect(DeviceModel device) async {
    // Connects to BLE GATT service (HID / Remote control characteristic)
    _connectedDeviceId = device.id;
    _connected = true;
    return true;
  }

  @override
  Future<bool> sendCommand(DeviceModel device, RemoteCommand command) async {
    if (!_connected || _connectedDeviceId != device.id) {
      final success = await connect(device);
      if (!success) return false;
    }
    // Write characteristic command bytes
    return true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _connectedDeviceId = null;
  }
}
