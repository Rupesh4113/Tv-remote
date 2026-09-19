"""
Philips RC-5 Protocol Encoder
Carrier: 36 kHz
Bi-phase Manchester encoding with half-bit time = 889 µs (bit period = 1778 µs).
Standard 14-bit frame: 2 start bits, 1 toggle bit, 5 address bits, 6 command bits.
"""

from typing import List, Tuple

CARRIER_FREQUENCY_HZ = 36000
HALF_BIT = 889


def encode_rc5(address: int, command: int, toggle: int = 0) -> Tuple[int, List[int]]:
    """
    Encodes RC5 frame into alternating mark/space timings in microseconds.
    """
    # 14 bits: S1(1), S2(1), Toggle(1), Address(5), Command(6)
    bits = [1, 1, toggle & 1]
    for i in range(4, -1, -1):
        bits.append((address >> i) & 1)
    for i in range(5, -1, -1):
        bits.append((command >> i) & 1)

    # Manchester encoding:
    # 0 = Mark for HALF_BIT then Space for HALF_BIT
    # 1 = Space for HALF_BIT then Mark for HALF_BIT
    # We construct a sequence of levels (1=Mark, 0=Space), then compress into pulses
    levels: List[int] = []
    for b in bits:
        if b == 1:
            levels.extend([0, 1])  # space then mark
        else:
            levels.extend([1, 0])  # mark then space

    # Convert levels list into run-length encoded durations
    durations: List[int] = []
    current_level = 1  # Standard IR transmission starts with a Mark
    current_dur = 0

    # RC-5 first half bit of start bit 1 is a Space, so transmission starts at the second half bit (Mark)
    trimmed_levels = levels[1:]  # Start at the first Mark
    for lvl in trimmed_levels:
        if lvl == current_level:
            current_dur += HALF_BIT
        else:
            durations.append(current_dur)
            current_dur = HALF_BIT
            current_level = lvl
    if current_dur > 0:
        durations.append(current_dur)

    return CARRIER_FREQUENCY_HZ, durations
