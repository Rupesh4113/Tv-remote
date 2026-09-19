import '../data/models/command_model.dart';
import '../data/models/device_model.dart';

abstract class BaseTransport {
  TransportType get type;
  bool get isConnected;

  Future<bool> initialize();
  Future<bool> connect(DeviceModel device);
  Future<bool> sendCommand(DeviceModel device, RemoteCommand command);
  Future<void> disconnect();
}
