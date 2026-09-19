#!/usr/bin/env python3
"""
RemoteOne Command-Line Diagnostic & Testing Utility
Allows testing IR encoders, querying device profiles, sending simulated commands,
and launching mock devices directly from the command line.
"""

import argparse
import asyncio
import json
import sys
from pathlib import Path

# Add project root to sys.path
ROOT_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT_DIR))

from protocols.ir import encode_ir_command
from backend.services.profile_service import ProfileService
from backend.simulator.runner import start_all_simulators


def cmd_list_profiles(args):
    service = ProfileService()
    profiles = service.list_profiles(
        category=args.category,
        brand=args.brand,
        transport=args.transport
    )
    print(f"\nFound {len(profiles)} profiles:")
    print("-" * 75)
    print(f"{'ID':<26} {'BRAND':<14} {'CATEGORY':<14} {'TRANSPORTS'}")
    print("-" * 75)
    for p in profiles:
        transports = ", ".join(p.supported_transports)
        print(f"{p.id:<26} {p.brand:<14} {p.category:<14} {transports}")
    print("-" * 75)


def cmd_test_ir(args):
    carrier, pattern = encode_ir_command(args.protocol, args.hex_code)
    print(f"\nIR Encoding Result:")
    print(f"  Protocol:          {args.protocol.upper()}")
    print(f"  Input Hex Code:    {args.hex_code}")
    print(f"  Carrier Frequency: {carrier} Hz")
    print(f"  Pulse Count:       {len(pattern)} durations (µs)")
    print(f"  First 8 Pulses:    {pattern[:8]}")
    print(f"  Status:            READY FOR ConsumerIrManager.transmit()")


def cmd_simulate(args):
    print("\nStarting RemoteOne Mock Smart TV & Set-Top Box Simulators...")
    try:
        asyncio.run(start_all_simulators())
    except KeyboardInterrupt:
        print("\nSimulators stopped.")


def main():
    parser = argparse.ArgumentParser(
        description="RemoteOne CLI - Diagnostic & Testing Utility",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # List profiles
    list_p = subparsers.add_parser("list-profiles", help="List device profiles")
    list_p.add_argument("--category", choices=["TV", "SET_TOP_BOX"], help="Filter category")
    list_p.add_argument("--brand", help="Filter brand name")
    list_p.add_argument("--transport", choices=["IR", "WIFI", "BLUETOOTH"], help="Filter transport")

    # Test IR
    ir_p = subparsers.add_parser("test-ir", help="Encode an IR code into hardware pulse timings")
    ir_p.add_argument("--protocol", default="NEC", choices=["NEC", "SAMSUNG", "SONY_SIRC", "RC5"], help="Protocol")
    ir_p.add_argument("--hex-code", required=True, help="Hex code (e.g. 0x00BF02FD or 0xE0E040BF)")

    # Run simulator
    sim_p = subparsers.add_parser("simulate", help="Launch mock smart TVs and STBs suite")

    args = parser.parse_args()
    if args.command == "list-profiles":
        cmd_list_profiles(args)
    elif args.command == "test-ir":
        cmd_test_ir(args)
    elif args.command == "simulate":
        cmd_simulate(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
