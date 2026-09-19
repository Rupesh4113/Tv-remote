"""
Unit tests for IR Protocol Encoders (NEC, Samsung, Sony SIRC, RC5)
"""

import pytest
from protocols.ir.nec import encode_nec, decode_nec, CARRIER_FREQUENCY_HZ as NEC_FREQ, LEAD_PULSE, LEAD_SPACE
from protocols.ir.samsung_ir import encode_samsung, CARRIER_FREQUENCY_HZ as SAMSUNG_FREQ
from protocols.ir.sony_sirc import encode_sony_sirc, CARRIER_FREQUENCY_HZ as SONY_FREQ
from protocols.ir.rc5 import encode_rc5, CARRIER_FREQUENCY_HZ as RC5_FREQ
from protocols.ir import encode_ir_command


def test_nec_encoding_length_and_frequency():
    carrier, pattern = encode_nec(0x00BF02FD, 32)
    assert carrier == NEC_FREQ == 38000
    assert pattern[0] == LEAD_PULSE == 9000
    assert pattern[1] == LEAD_SPACE == 4500
    # 1 lead pulse + 1 lead space + 32 * 2 (bit pulse + space) + 1 stop pulse = 67 elements
    assert len(pattern) == 67
    assert pattern[-1] == 560


def test_nec_decode_roundtrip():
    original_code = 0x00BF02FD  # Tata Play Power Code
    carrier, pattern = encode_nec(original_code, 32)
    decoded = decode_nec(pattern)
    assert decoded == original_code


def test_samsung_encoding():
    carrier, pattern = encode_samsung(0xE0E040BF)
    assert carrier == SAMSUNG_FREQ == 38000
    assert pattern[0] == 4500
    assert pattern[1] == 4500
    assert len(pattern) == 67


def test_sony_sirc_encoding():
    # Sony Power: 0xA90 (command=0x15, address=0x01)
    carrier, pattern = encode_sony_sirc(command=0x15, address=0x01, bits=12)
    assert carrier == SONY_FREQ == 40000
    assert pattern[0] == 2400
    assert pattern[1] == 600
    # 1 lead pair + 12 bit pairs = 26 durations
    assert len(pattern) == 26


def test_rc5_encoding():
    carrier, pattern = encode_rc5(address=0x00, command=0x0C, toggle=0)
    assert carrier == RC5_FREQ == 36000
    assert len(pattern) > 10
    # All intervals should be multiples of half-bit (889 µs)
    for dur in pattern:
        assert dur in [889, 1778, 2667]


def test_unified_dispatcher():
    carrier, pattern = encode_ir_command("NEC", "0x00BF02FD")
    assert carrier == 38000
    assert len(pattern) == 67

    carrier, pattern = encode_ir_command("SONY_SIRC", "0x0A90")
    assert carrier == 40000

    carrier, pattern = encode_ir_command("SAMSUNG", "0xE0E040BF")
    assert carrier == 38000
