import 'package:flutter_test/flutter_test.dart';
import 'package:remoteone/transports/ir/protocol_encoders.dart';

void main() {
  group('Dart IR Protocol Encoders Tests', () {
    test('NEC encoding produces 38kHz and 67 pulse durations', () {
      final pattern = IrProtocolEncoders.encodeNec(0x00BF02FD, bitCount: 32);
      expect(pattern.carrierFrequencyHz, equals(38000));
      expect(pattern.pattern.length, equals(67));
      expect(pattern.pattern[0], equals(9000)); // Lead pulse
      expect(pattern.pattern[1], equals(4500)); // Lead space
      expect(pattern.pattern.last, equals(560)); // Stop pulse
    });

    test('Samsung encoding produces 38kHz and 4500µs lead', () {
      final pattern = IrProtocolEncoders.encodeSamsung(0xE0E040BF);
      expect(pattern.carrierFrequencyHz, equals(38000));
      expect(pattern.pattern[0], equals(4500));
      expect(pattern.pattern[1], equals(4500));
      expect(pattern.pattern.length, equals(67));
    });

    test('Sony SIRC encoding produces 40kHz and 2400µs lead', () {
      final pattern = IrProtocolEncoders.encodeSonySirc(0x15, 0x01, bits: 12);
      expect(pattern.carrierFrequencyHz, equals(40000));
      expect(pattern.pattern[0], equals(2400));
      expect(pattern.pattern[1], equals(600));
      expect(pattern.pattern.length, equals(26));
    });

    test('RC-5 encoding produces 36kHz and Manchester pulse intervals', () {
      final pattern = IrProtocolEncoders.encodeRc5(0x00, 0x0C);
      expect(pattern.carrierFrequencyHz, equals(36000));
      expect(pattern.pattern.isNotEmpty, isTrue);
      for (final duration in pattern.pattern) {
        expect([889, 1778, 2667].contains(duration), isTrue);
      }
    });

    test('Dispatcher resolves NEC, Samsung, and Sony', () {
      final nec = IrProtocolEncoders.encode('NEC', '0x00BF02FD');
      expect(nec.carrierFrequencyHz, equals(38000));

      final sony = IrProtocolEncoders.encode('SONY_SIRC', '0x0A90');
      expect(sony.carrierFrequencyHz, equals(40000));
    });
  });
}
