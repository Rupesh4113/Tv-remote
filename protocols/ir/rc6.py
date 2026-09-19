"""
Philips RC-6 Protocol Encoder (Mode 0)
Carrier: 36 kHz
Leader: 2666 µs mark, 889 µs space
Bit unit: t = 444 µs
Standard bit: 0 = Mark(444) + Space(444), 1 = Space(444) + Mark(444)
Trailer/Toggle bit (TR): 0 = Mark(889) + Space(889), 1 = Space(889) + Mark(889)
"""

from typing import List, Tuple

CARRIER_FREQUENCY_HZ = 36000
T = 444


def encode_rc6(mode: int, address: int, command: int, toggle: int = 0) -> Tuple[int, List[int]]:
    """
    Encodes RC-6 Mode 0 frame.
    """
    pattern: List[int] = [2666, 889]  # Leader

    # Start bit: '1' -> Space(444) + Mark(444)
    pattern.extend([T, T])

    # Mode (3 bits)
    for i in range(2, -1, -1):
        bit = (mode >> i) & 1
        if bit == 1:
            pattern.extend([T, T])
        else:
            pattern.extend([T, T])

    # Toggle bit (double duration)
    if toggle & 1:
        pattern.extend([2 * T, 2 * T])
    else:
        pattern.extend([2 * T, 2 * T])

    # Address (8 bits)
    for i in range(7, -1, -1):
        bit = (address >> i) & 1
        pattern.extend([T, T] if bit else [T, T])

    # Command (8 bits)
    for i in range(7, -1, -1):
        bit = (command >> i) & 1
        pattern.extend([T, T] if bit else [T, T])

    return CARRIER_FREQUENCY_HZ, pattern
