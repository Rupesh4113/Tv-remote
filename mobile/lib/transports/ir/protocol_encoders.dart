/// IR Protocol Encoders in Dart
/// Returns carrier frequency in Hz and pulse/space pattern in microseconds for ConsumerIrManager.

class IrPattern {
  final int carrierFrequencyHz;
  final List<int> pattern;

  const IrPattern(this.carrierFrequencyHz, this.pattern);
}

class IrProtocolEncoders {
  // NEC 32-bit
  static IrPattern encodeNec(int hexCode, {int bitCount = 32}) {
    const int leadPulse = 9000;
    const int leadSpace = 4500;
    const int bitPulse = 560;
    const int bit0Space = 560;
    const int bit1Space = 1690;
    const int stopPulse = 560;

    final List<int> pattern = [leadPulse, leadSpace];

    for (int i = bitCount - 1; i >= 0; i--) {
      final bit = (hexCode >> i) & 1;
      pattern.add(bitPulse);
      pattern.add(bit == 1 ? bit1Space : bit0Space);
    }
    pattern.add(stopPulse);
    return IrPattern(38000, pattern);
  }

  // Samsung 32-bit
  static IrPattern encodeSamsung(int hexCode) {
    const int leadPulse = 4500;
    const int leadSpace = 4500;
    const int bitPulse = 560;
    const int bit0Space = 560;
    const int bit1Space = 1690;
    const int stopPulse = 560;

    final List<int> pattern = [leadPulse, leadSpace];

    for (int i = 31; i >= 0; i--) {
      final bit = (hexCode >> i) & 1;
      pattern.add(bitPulse);
      pattern.add(bit == 1 ? bit1Space : bit0Space);
    }
    pattern.add(stopPulse);
    return IrPattern(38000, pattern);
  }

  // Sony SIRC (12-bit / 15-bit)
  static IrPattern encodeSonySirc(int command, int address, {int bits = 12}) {
    const int leadPulse = 2400;
    const int space = 600;
    const int bit0Pulse = 600;
    const int bit1Pulse = 1200;

    final List<int> pattern = [leadPulse, space];

    // Command (7 bits, LSB first)
    for (int i = 0; i < 7; i++) {
      final bit = (command >> i) & 1;
      pattern.add(bit == 1 ? bit1Pulse : bit0Pulse);
      pattern.add(space);
    }

    // Address (5 or 8 bits, LSB first)
    final addrBits = bits - 7;
    for (int i = 0; i < addrBits; i++) {
      final bit = (address >> i) & 1;
      pattern.add(bit == 1 ? bit1Pulse : bit0Pulse);
      pattern.add(space);
    }

    return IrPattern(40000, pattern);
  }

  // Philips RC-5
  static IrPattern encodeRc5(int address, int command, {int toggle = 0}) {
    const int halfBit = 889;
    final bits = [1, 1, toggle & 1];
    for (int i = 4; i >= 0; i--) {
      bits.add((address >> i) & 1);
    }
    for (int i = 5; i >= 0; i--) {
      bits.add((command >> i) & 1);
    }

    final levels = <int>[];
    for (final b in bits) {
      if (b == 1) {
        levels.addAll([0, 1]);
      } else {
        levels.addAll([1, 0]);
      }
    }

    final durations = <int>[];
    int currentLevel = 1;
    int currentDur = 0;

    for (final lvl in levels.skip(1)) {
      if (lvl == currentLevel) {
        currentDur += halfBit;
      } else {
        durations.add(currentDur);
        currentDur = halfBit;
        currentLevel = lvl;
      }
    }
    if (currentDur > 0) durations.add(currentDur);

    return IrPattern(36000, durations);
  }

  // Dispatcher
  static IrPattern encode(String protocol, String hexCodeStr) {
    final cleanHex = hexCodeStr.startsWith('0x') ? hexCodeStr.substring(2) : hexCodeStr;
    final codeVal = int.tryParse(cleanHex, radix: 16) ?? 0;

    switch (protocol.toUpperCase()) {
      case 'SAMSUNG':
        return encodeSamsung(codeVal);
      case 'SONY_SIRC':
        final cmd = codeVal & 0x7F;
        final addr = (codeVal >> 7) & 0x1F;
        return encodeSonySirc(cmd, addr, bits: 12);
      case 'RC5':
        final addr = (codeVal >> 6) & 0x1F;
        final cmd = codeVal & 0x3F;
        return encodeRc5(addr, cmd);
      case 'NEC':
      default:
        return encodeNec(codeVal, bitCount: 32);
    }
  }
}
