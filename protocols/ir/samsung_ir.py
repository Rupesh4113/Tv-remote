"""
Samsung 32-bit IR Protocol Encoder
Carrier: 38 kHz
Lead: 4500 µs pulse, 4500 µs space
Bit 0: 560 µs pulse, 560 µs space
Bit 1: 560 µs pulse, 1690 µs space
Stop: 560 µs pulse
Total: 32 bits (Customer code 16-bit, Command 8-bit, ~Command 8-bit)
"""

from typing import List, Tuple

CARRIER_FREQUENCY_HZ = 38000
LEAD_PULSE = 4500
LEAD_SPACE = 4500
BIT_PULSE = 560
BIT_0_SPACE = 560
BIT_1_SPACE = 1690
STOP_PULSE = 560


def encode_samsung(hex_code: int) -> Tuple[int, List[int]]:
    """
    Encodes 32-bit Samsung word into mark/space durations.
    """
    pattern: List[int] = [LEAD_PULSE, LEAD_SPACE]

    for i in range(31, -1, -1):
        bit = (hex_code >> i) & 1
        pattern.append(BIT_PULSE)
        pattern.append(BIT_1_SPACE if bit == 1 else BIT_0_SPACE)

    pattern.append(STOP_PULSE)
    return CARRIER_FREQUENCY_HZ, pattern
