"""
Sony SIRC Protocol Encoder
Carrier: 40 kHz
Lead: 2400 µs pulse, 600 µs space
Bit 0: 600 µs pulse, 600 µs space
Bit 1: 1200 µs pulse, 600 µs space
Standard formats: 12-bit (7-bit command + 5-bit address), 15-bit, 20-bit (LSB first).
"""

from typing import List, Tuple

CARRIER_FREQUENCY_HZ = 40000
LEAD_PULSE = 2400
SPACE = 600
BIT_0_PULSE = 600
BIT_1_PULSE = 1200


def encode_sony_sirc(command: int, address: int, bits: int = 12) -> Tuple[int, List[int]]:
    """
    Encodes Sony SIRC into mark/space timings in microseconds.
    """
    pattern: List[int] = [LEAD_PULSE, SPACE]

    # Transmit command (7 bits, LSB first)
    for i in range(7):
        bit = (command >> i) & 1
        pulse = BIT_1_PULSE if bit == 1 else BIT_0_PULSE
        pattern.extend([pulse, SPACE])

    # Transmit address (5 bits for 12-bit, 8 bits for 15-bit)
    addr_bits = bits - 7
    for i in range(addr_bits):
        bit = (address >> i) & 1
        pulse = BIT_1_PULSE if bit == 1 else BIT_0_PULSE
        pattern.extend([pulse, SPACE])

    return CARRIER_FREQUENCY_HZ, pattern
