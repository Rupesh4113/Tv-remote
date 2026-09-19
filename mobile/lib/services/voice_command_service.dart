import 'package:flutter/foundation.dart';
import '../data/models/command_model.dart';
import '../data/models/device_model.dart';
import 'remote_controller.dart';

class VoiceCommandResult {
  final String query;
  final String intent;
  final String targetDeviceType;
  final String commandKey;
  final int? value;
  final bool success;
  final String responseMessage;

  VoiceCommandResult({
    required this.query,
    required this.intent,
    required this.targetDeviceType,
    required this.commandKey,
    this.value,
    required this.success,
    required this.responseMessage,
  });
}

class VoiceCommandService extends ChangeNotifier {
  final RemoteController remoteController;

  bool _isListening = false;
  VoiceCommandResult? _lastResult;

  VoiceCommandService({required this.remoteController});

  bool get isListening => _isListening;
  VoiceCommandResult? get lastResult => _lastResult;

  VoiceCommandResult parseCommand(String text) {
    final lower = text.trim().toLowerCase();

    // Power
    if (lower.contains('turn on') || lower.contains('power on') || lower.contains('switch on')) {
      final isStb = lower.contains('box') || lower.contains('tata') || lower.contains('airtel') || lower.contains('dish');
      return VoiceCommandResult(
        query: text,
        intent: 'POWER_ON',
        targetDeviceType: isStb ? 'STB' : 'TV',
        commandKey: 'POWER',
        success: true,
        responseMessage: 'Turning on ${isStb ? 'Set-Top Box' : 'TV'}',
      );
    }

    if (lower.contains('turn off') || lower.contains('power off') || lower.contains('shut down')) {
      final isStb = lower.contains('box') || lower.contains('tata') || lower.contains('airtel') || lower.contains('dish');
      return VoiceCommandResult(
        query: text,
        intent: 'POWER_OFF',
        targetDeviceType: isStb ? 'STB' : 'TV',
        commandKey: 'POWER',
        success: true,
        responseMessage: 'Turning off ${isStb ? 'Set-Top Box' : 'TV'}',
      );
    }

    // Mute
    if (lower.contains('mute') || lower.contains('unmute') || lower.contains('silence')) {
      return VoiceCommandResult(
        query: text,
        intent: 'MUTE',
        targetDeviceType: 'TV',
        commandKey: 'MUTE',
        success: true,
        responseMessage: 'Muting TV',
      );
    }

    // Volume Up / Down
    if (lower.contains('increase volume') || lower.contains('volume up') || lower.contains('louder')) {
      final match = RegExp(r'by\s+(\d+)').firstMatch(lower);
      final steps = match != null ? int.tryParse(match.group(1)!) ?? 1 : 1;
      return VoiceCommandResult(
        query: text,
        intent: 'VOLUME_UP',
        targetDeviceType: 'TV',
        commandKey: 'VOLUME_UP',
        value: steps,
        success: true,
        responseMessage: 'Increasing volume by $steps',
      );
    }

    if (lower.contains('decrease volume') || lower.contains('volume down') || lower.contains('quieter')) {
      final match = RegExp(r'by\s+(\d+)').firstMatch(lower);
      final steps = match != null ? int.tryParse(match.group(1)!) ?? 1 : 1;
      return VoiceCommandResult(
        query: text,
        intent: 'VOLUME_DOWN',
        targetDeviceType: 'TV',
        commandKey: 'VOLUME_DOWN',
        value: steps,
        success: true,
        responseMessage: 'Decreasing volume by $steps',
      );
    }

    // Channels
    final chMatch = RegExp(r'(?:channel|change to channel|go to channel)\s+(\d+)').firstMatch(lower);
    if (chMatch != null) {
      final chNum = int.tryParse(chMatch.group(1)!) ?? 100;
      return VoiceCommandResult(
        query: text,
        intent: 'SET_CHANNEL',
        targetDeviceType: 'STB',
        commandKey: 'SET_CHANNEL',
        value: chNum,
        success: true,
        responseMessage: 'Tuning to channel $chNum on Set-Top Box',
      );
    }

    if (lower.contains('next channel') || lower.contains('channel up')) {
      return VoiceCommandResult(
        query: text,
        intent: 'CHANNEL_UP',
        targetDeviceType: 'STB',
        commandKey: 'CHANNEL_UP',
        success: true,
        responseMessage: 'Changing to next channel',
      );
    }

    // App shortcuts
    for (final app in ['netflix', 'youtube', 'prime video', 'hotstar', 'sony liv']) {
      if (lower.contains(app)) {
        return VoiceCommandResult(
          query: text,
          intent: 'LAUNCH_APP',
          targetDeviceType: 'TV',
          commandKey: app.toUpperCase().replaceAll(' ', '_'),
          success: true,
          responseMessage: 'Launching ${app.toUpperCase()}',
        );
      }
    }

    return VoiceCommandResult(
      query: text,
      intent: 'UNKNOWN',
      targetDeviceType: 'TV',
      commandKey: 'NONE',
      success: false,
      responseMessage: "Command not recognized: '$text'",
    );
  }

  Future<VoiceCommandResult> executeVoiceQuery(String query, List<DeviceModel> devices) async {
    final parsed = parseCommand(query);
    _lastResult = parsed;
    notifyListeners();

    if (parsed.success && parsed.commandKey != 'NONE') {
      final targetDev = devices.firstWhere(
        (d) => (parsed.targetDeviceType == 'STB' && d.category == DeviceCategory.setTopBox) ||
               (parsed.targetDeviceType == 'TV' && d.category == DeviceCategory.tv),
        orElse: () => devices.isNotEmpty ? devices.first : DeviceModel(
          id: 'mock',
          name: 'Device',
          brand: 'Generic',
          category: DeviceCategory.tv,
          profileId: 'tv-generic-ir',
          activeTransport: TransportType.ir,
        ),
      );

      if (parsed.intent == 'SET_CHANNEL' && parsed.value != null) {
        // Send each digit sequentially
        final digits = parsed.value.toString();
        for (final digit in digits.split('')) {
          await remoteController.executeCommand(
            targetDev,
            RemoteCommand(key: 'NUM_$digit', label: digit),
          );
          await Future.delayed(const Duration(milliseconds: 150));
        }
      } else if ((parsed.intent == 'VOLUME_UP' || parsed.intent == 'VOLUME_DOWN') && (parsed.value ?? 1) > 1) {
        for (int i = 0; i < (parsed.value ?? 1); i++) {
          await remoteController.executeCommand(
            targetDev,
            RemoteCommand(key: parsed.commandKey, label: parsed.commandKey),
          );
          await Future.delayed(const Duration(milliseconds: 100));
        }
      } else {
        await remoteController.executeCommand(
          targetDev,
          RemoteCommand(key: parsed.commandKey, label: parsed.commandKey),
        );
      }
    }

    return parsed;
  }
}
