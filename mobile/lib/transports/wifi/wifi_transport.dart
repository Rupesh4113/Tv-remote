import '../../data/models/command_model.dart';
import '../../data/models/device_model.dart';
import '../base_transport.dart';
import 'adapters/android_tv_adapter.dart';
import 'adapters/lg_adapter.dart';
import 'adapters/roku_adapter.dart';
import 'adapters/samsung_adapter.dart';
import 'adapters/sony_adapter.dart';

class WiFiTransport implements BaseTransport {
  final SamsungAdapter _samsung = SamsungAdapter();
  final LgAdapter _lg = LgAdapter();
  final SonyAdapter _sony = SonyAdapter();
  final AndroidTvAdapter _androidTv = AndroidTvAdapter();
  final RokuAdapter _roku = RokuAdapter();
  final GenericHttpAdapter _generic = GenericHttpAdapter();

  bool _connected = false;

  @override
  TransportType get type => TransportType.wifi;

  @override
  bool get isConnected => _connected;

  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  Future<bool> connect(DeviceModel device) async {
    final brand = device.brand.toLowerCase();
    if (brand.contains('samsung')) {
      _connected = await _samsung.connect(device);
    } else if (brand.contains('lg')) {
      _connected = await _lg.connect(device);
    } else if (brand.contains('sony')) {
      _connected = await _sony.connect(device);
    } else if (brand.contains('oneplus') || brand.contains('xiaomi') || brand.contains('tcl')) {
      _connected = await _androidTv.connect(device);
    } else {
      _connected = device.ipAddress != null;
    }
    return _connected;
  }

  @override
  Future<bool> sendCommand(DeviceModel device, RemoteCommand command) async {
    final brand = device.brand.toLowerCase();

    if (brand.contains('samsung')) {
      return await _samsung.sendCommand(command);
    } else if (brand.contains('lg')) {
      return await _lg.sendCommand(command);
    } else if (brand.contains('sony')) {
      return await _sony.sendCommand(device, command);
    } else if (brand.contains('roku')) {
      return await _roku.sendCommand(device, command);
    } else if (brand.contains('oneplus') || brand.contains('xiaomi') || brand.contains('tcl') || brand.contains('vu')) {
      return await _androidTv.sendCommand(device, command);
    } else {
      return await _generic.sendCommand(device, command);
    }
  }

  @override
  Future<void> disconnect() async {
    await _samsung.disconnect();
    await _lg.disconnect();
    await _sony.disconnect();
    await _androidTv.disconnect();
    _connected = false;
  }
}
