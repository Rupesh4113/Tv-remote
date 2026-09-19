import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/database/storage_service.dart';
import '../data/models/command_model.dart';
import '../data/models/device_model.dart';
import '../data/models/macro_model.dart';
import 'remote_controller.dart';

class MacroRunner extends ChangeNotifier {
  final RemoteController remoteController;
  final StorageService storageService;

  bool _isRunning = false;
  String? _currentStepDescription;
  int _currentStepIndex = 0;
  int _totalSteps = 0;

  MacroRunner({
    required this.remoteController,
    required this.storageService,
  });

  bool get isRunning => _isRunning;
  String? get currentStepDescription => _currentStepDescription;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _totalSteps;

  Future<bool> runMacro(MacroModel macro, List<DeviceModel> availableDevices) async {
    if (_isRunning) return false;

    _isRunning = true;
    _totalSteps = macro.steps.length;
    _currentStepIndex = 0;
    notifyListeners();

    try {
      for (int i = 0; i < macro.steps.length; i++) {
        final step = macro.steps[i];
        _currentStepIndex = i + 1;
        _currentStepDescription = 'Executing: ${step.commandLabel} on ${step.targetDeviceName}';
        notifyListeners();

        // Find target device
        final device = availableDevices.firstWhere(
          (d) => d.id == step.targetDeviceId,
          orElse: () => availableDevices.isNotEmpty ? availableDevices.first : DeviceModel(
            id: 'mock',
            name: 'Device',
            brand: 'Generic',
            category: DeviceCategory.tv,
            profileId: 'tv-generic-ir',
            activeTransport: TransportType.ir,
          ),
        );

        final cmd = RemoteCommand(key: step.commandKey, label: step.commandLabel);
        await remoteController.executeCommand(device, cmd);

        if (step.delayMs > 0 && i < macro.steps.length - 1) {
          await Future.delayed(Duration(milliseconds: step.delayMs));
        }
      }
      return true;
    } catch (_) {
      return false;
    } finally {
      _isRunning = false;
      _currentStepDescription = null;
      notifyListeners();
    }
  }
}
