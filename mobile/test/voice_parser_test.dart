import 'package:flutter_test/flutter_test.dart';
import 'package:remoteone/services/remote_controller.dart';
import 'package:remoteone/services/voice_command_service.dart';
import 'package:remoteone/transports/bluetooth/bluetooth_transport.dart';
import 'package:remoteone/transports/ir/ir_transport.dart';
import 'package:remoteone/transports/wifi/wifi_transport.dart';

void main() {
  group('VoiceCommandService Tests', () {
    late VoiceCommandService voiceService;

    setUp(() {
      final controller = RemoteController(
        irTransport: IrTransport(),
        wifiTransport: WiFiTransport(),
        bleTransport: BluetoothTransport(),
      );
      voiceService = VoiceCommandService(remoteController: controller);
    });

    test('Power intents for TV and Set-Top Box', () {
      final tv = voiceService.parseCommand('turn on the TV');
      expect(tv.intent, equals('POWER_ON'));
      expect(tv.targetDeviceType, equals('TV'));

      final stb = voiceService.parseCommand('turn on Tata Play set top box');
      expect(stb.intent, equals('POWER_ON'));
      expect(stb.targetDeviceType, equals('STB'));
    });

    test('Volume step increments', () {
      final vol = voiceService.parseCommand('volume up by 4');
      expect(vol.intent, equals('VOLUME_UP'));
      expect(vol.value, equals(4));
    });

    test('Channel selection', () {
      final ch = voiceService.parseCommand('change to channel 205');
      expect(ch.intent, equals('SET_CHANNEL'));
      expect(ch.value, equals(205));
    });

    test('Streaming app launch', () {
      final netflix = voiceService.parseCommand('open netflix');
      expect(netflix.intent, equals('LAUNCH_APP'));
      expect(netflix.commandKey, equals('NETFLIX'));
    });
  });
}
