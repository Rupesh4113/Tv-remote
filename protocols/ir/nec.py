"""
NEC IR Protocol Encoder
Carrier: 38 kHz (Period ~26.3 µs)
Format:
- Leader: 9000 µs pulse + 4500 µs space
- Bit 0: 560 µs pulse + 560 µs space
- Bit 1: 560 µs pulse + 1690 µs space
- Stop: 560 µs pulse
"""

from typing import List, Tuple

CARRIER_FREQUENCY_HZ = 38000
LEAD_PULSE = 9000
LEAD_SPACE = 4500
BIT_PULSE = 560
BIT_0_SPACE = 560
BIT_1_SPACE = 1690
STOP_PULSE = 560


def encode_nec(hex_code: int, bit_count: int = 32) -> Tuple[int, List[int]]:
    """
    Encode an integer hex code into alternating pulse/space durations (µs)
    suitable for Android ConsumerIrManager.transmit(carrier, pattern).
    """
    pattern: List[int] = [LEAD_PULSE, LEAD_SPACE]

    # NEC transmits LSB first per byte or entire word
    for i in range(bit_count - 1, -1, -1):
        bit = (hex_code >> i) & 1
        pattern.append(BIT_PULSE)
        if bit == 1:
            pattern.append(BIT_1_SPACE)
        else:
            pattern.append(BIT_0_SPACE)

    pattern.append(STOP_PULSE)
    return CARRIER_FREQUENCY_HZ, pattern


def decode_nec(pattern: List[int], tolerance: float = 0.25) -> int:
    """
    Decode alternating pulse/space durations back to an integer code.
    Useful for IR learning mode verification.
    """
    if len(pattern) < 67:
        raise ValueError(f"Pattern too short for 32-bit NEC (length={len(pattern)})")

    # Check lead pulse
    if not (LEAD_PULSE * (1 - tolerance) <= pattern[0] <= LEAD_PULSE * (1 + tolerance)):
        raise ValueError(f"Invalid lead pulse: {pattern[0]}µs")

    code = 0
    # Bit pulses start at index 2 (pulse), index 3 (space)
    idx = 2
    bits_read = 0
    while idx + 1 < len(pattern) and bits_read < 32:
        space = pattern[idx + 1]
        if abs(space - BIT_1_SPACE) < abs(space - BIT_0_SPACE):
            code = (code << 1) | 1
        else:
            code = (code << 1) | 0
        bits_read += 1
        idx += 2

    return code
