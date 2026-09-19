# Infrared (IR) and Network Protocol Reference

## 1. NEC IR Protocol
- **Modulation**: Pulse distance modulation on 38 kHz carrier.
- **Lead Mark**: 9000 µs (9 ms)
- **Lead Space**: 4500 µs (4.5 ms)
- **Bit 0**: 560 µs Mark + 560 µs Space (Total 1120 µs)
- **Bit 1**: 560 µs Mark + 1690 µs Space (Total 2250 µs)
- **Stop**: 560 µs Mark
- **Repeat Frame**: 9000 µs Mark + 2250 µs Space + 560 µs Mark

## 2. Samsung 32-bit IR Protocol
- **Modulation**: Pulse distance on 38 kHz carrier.
- **Lead Mark**: 4500 µs
- **Lead Space**: 4500 µs
- **Bits**: Same bit pulse and space timings as NEC (560/560 for 0, 560/1690 for 1).

## 3. Sony SIRC (Sony Infrared Remote Control)
- **Modulation**: Pulse width modulation on 40 kHz carrier.
- **Lead Mark**: 2400 µs
- **Space**: Fixed 600 µs space between marks.
- **Bit 0**: 600 µs Mark
- **Bit 1**: 1200 µs Mark
- **Frame Sizes**: 12-bit (7-bit command + 5-bit address), 15-bit, 20-bit. Transmitted LSB first.

## 4. Philips RC-5 Protocol
- **Modulation**: Bi-phase (Manchester) modulation on 36 kHz carrier.
- **Half-bit duration**: 889 µs (Bit period = 1778 µs).
- **Bit 0**: Mark for 889 µs, then Space for 889 µs.
- **Bit 1**: Space for 889 µs, then Mark for 889 µs.
- **Frame**: 2 start bits, 1 toggle bit (flips on each press), 5 address bits, 6 command bits.

## 5. Wi-Fi Control Protocols
- **Samsung Tizen**: WebSocket on port 8002 (TLS) or 8001 (Cleartext). Authenticated via handshake token.
- **LG webOS**: SSAP WebSocket on port 3000. Registration prompt generates client-key.
- **Sony IRCC-IP**: HTTP POST to `/sony/ircc` with Pre-Shared Key header (`X-Auth-PSK`).
- **Android TV Remote v2**: Mutual TLS on port 6466/6467 with PIN pairing.
