import 'package:flutter/foundation.dart';
import '../data/models/command_model.dart';
import '../data/models/device_model.dart';
import 'remote_controller.dart';

enum TargetDeviceType { tv, stb }

class CombinedRemoteService extends ChangeNotifier {
  final RemoteController remoteController;

  DeviceModel? tvDevice;
  DeviceModel? stbDevice;

  // Key to target routing map
  final Map<String, TargetDeviceType> _commandRouting = {
    'POWER': TargetDeviceType.tv,
    'POWER_TV': TargetDeviceType.tv,
    'POWER_STB': TargetDeviceType.stb,
    'VOLUME_UP': TargetDeviceType.tv,
    'VOLUME_DOWN': TargetDeviceType.tv,
    'MUTE': TargetDeviceType.tv,
    'SOURCE': TargetDeviceType.tv,
    'CHANNEL_UP': TargetDeviceType.stb,
    'CHANNEL_DOWN': TargetDeviceType.stb,
    'GUIDE': TargetDeviceType.stb,
    'MENU': TargetDeviceType.stb,
    'INFO': TargetDeviceType.stb,
    'FAVORITE': TargetDeviceType.stb,
    'DPAD_UP': TargetDeviceType.stb,
    'DPAD_DOWN': TargetDeviceType.stb,
    'DPAD_LEFT': TargetDeviceType.stb,
    'DPAD_RIGHT': TargetDeviceType.stb,
    'DPAD_OK': TargetDeviceType.stb,
    'COLOR_RED': TargetDeviceType.stb,
    'COLOR_GREEN': TargetDeviceType.stb,
    'COLOR_YELLOW': TargetDeviceType.stb,
    'COLOR_BLUE': TargetDeviceType.stb,
    'NUM_0': TargetDeviceType.stb,
    'NUM_1': TargetDeviceType.stb,
    'NUM_2': TargetDeviceType.stb,
    'NUM_3': TargetDeviceType.stb,
    'NUM_4': TargetDeviceType.stb,
    'NUM_5': TargetDeviceType.stb,
    'NUM_6': TargetDeviceType.stb,
    'NUM_7': TargetDeviceType.stb,
    'NUM_8': TargetDeviceType.stb,
    'NUM_9': TargetDeviceType.stb,
  };

  CombinedRemoteService({required this.remoteController});

  void setDevices({DeviceModel? tv, DeviceModel? stb}) {
    tvDevice = tv;
    stbDevice = stb;
    notifyListeners();
  }

  void setRouting(String commandKey, TargetDeviceType target) {
    _commandRouting[commandKey] = target;
    notifyListeners();
  }

  TargetDeviceType getRouting(String commandKey) {
    return _commandRouting[commandKey] ?? TargetDeviceType.tv;
  }

  Future<bool> sendCommand(String key, {String? label}) async {
    final targetType = getRouting(key);
    final targetDevice = targetType == TargetDeviceType.tv ? tvDevice : stbDevice;

    if (targetDevice == null) {
      // Fallback to whichever is available
      final fallback = tvDevice ?? stbDevice;
      if (fallback == null) return false;
      return await remoteController.executeCommand(
        fallback,
        RemoteCommand(key: key, label: label ?? key),
      );
    }

    return await remoteController.executeCommand(
      targetDevice,
      RemoteCommand(key: key, label: label ?? key),
    );
  }
}
