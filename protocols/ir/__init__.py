"""
IR Protocol Registry & Dispatcher
"""

from typing import List, Tuple
from .nec import encode_nec
from .rc5 import encode_rc5
from .rc6 import encode_rc6
from .sony_sirc import encode_sony_sirc
from .samsung_ir import encode_samsung


def encode_ir_command(protocol: str, hex_code_str: str, customer_code: str = None) -> Tuple[int, List[int]]:
    """
    Given a protocol name (e.g. 'NEC', 'SONY_SIRC', 'SAMSUNG', 'RC5') and hex string
    (e.g. '0xE0E040BF'), encodes into (carrier_hz, [pulse, space, pulse, space, ...]).
    """
    protocol_upper = (protocol or "NEC").upper()
    code_val = int(hex_code_str, 16) if isinstance(hex_code_str, str) and hex_code_str.startswith("0x") else int(str(hex_code_str), 16)

    if protocol_upper == "NEC":
        return encode_nec(code_val, 32)
    elif protocol_upper == "SAMSUNG":
        return encode_samsung(code_val)
    elif protocol_upper == "SONY_SIRC":
        # Usually 12-bit: lower 7 bits command, upper 5 bits address
        cmd = code_val & 0x7F
        addr = (code_val >> 7) & 0x1F
        return encode_sony_sirc(cmd, addr, 12)
    elif protocol_upper == "RC5":
        addr = (code_val >> 6) & 0x1F
        cmd = code_val & 0x3F
        return encode_rc5(addr, cmd)
    elif protocol_upper == "RC6":
        addr = (code_val >> 8) & 0xFF
        cmd = code_val & 0xFF
        return encode_rc6(0, addr, cmd)
    else:
        # Fallback to standard 32-bit NEC
        return encode_nec(code_val, 32)
