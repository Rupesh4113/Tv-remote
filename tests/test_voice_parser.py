"""
Voice Command Intent Parsing Logic & Tests
"""

import re
from typing import Dict, Any


def parse_voice_command(text: str) -> Dict[str, Any]:
    """
    Parses natural language speech text into structured remote control intents.
    """
    cleaned = text.strip().lower()

    # Power
    if re.search(r"\b(turn on|power on|switch on|start)\b", cleaned):
        device = "STB" if "box" in cleaned or "tata" in cleaned or "airtel" in cleaned or "dish" in cleaned else "TV"
        return {"intent": "POWER_ON", "target": device, "command": "POWER"}
    if re.search(r"\b(turn off|power off|switch off|shut down)\b", cleaned):
        device = "STB" if "box" in cleaned or "tata" in cleaned or "airtel" in cleaned or "dish" in cleaned else "TV"
        return {"intent": "POWER_OFF", "target": device, "command": "POWER"}

    # Mute / Unmute
    if re.search(r"\b(mute|unmute|silence)\b", cleaned):
        return {"intent": "MUTE", "target": "TV", "command": "MUTE"}

    # Volume
    vol_up_match = re.search(r"\b(increase volume|volume up|turn up volume|louder)\b(\s+by\s+(\d+))?", cleaned)
    if vol_up_match:
        step = int(vol_up_match.group(3)) if vol_up_match.group(3) else 1
        return {"intent": "VOLUME_UP", "target": "TV", "command": "VOLUME_UP", "steps": step}

    vol_down_match = re.search(r"\b(decrease volume|volume down|turn down volume|quieter)\b(\s+by\s+(\d+))?", cleaned)
    if vol_down_match:
        step = int(vol_down_match.group(3)) if vol_down_match.group(3) else 1
        return {"intent": "VOLUME_DOWN", "target": "TV", "command": "VOLUME_DOWN", "steps": step}

    # Channel
    channel_match = re.search(r"\b(channel|change to channel|go to channel)\s+(\d+)\b", cleaned)
    if channel_match:
        return {"intent": "SET_CHANNEL", "target": "STB", "command": "SET_CHANNEL", "channel": int(channel_match.group(2))}

    if re.search(r"\b(next channel|channel up)\b", cleaned):
        return {"intent": "CHANNEL_UP", "target": "STB", "command": "CHANNEL_UP"}
    if re.search(r"\b(previous channel|channel down)\b", cleaned):
        return {"intent": "CHANNEL_DOWN", "target": "STB", "command": "CHANNEL_DOWN"}

    # App shortcuts
    for app in ["netflix", "youtube", "prime video", "hotstar", "zee5", "sony liv"]:
        if app in cleaned:
            return {"intent": "LAUNCH_APP", "target": "TV", "command": app.upper().replace(" ", "_"), "app": app}

    return {"intent": "UNKNOWN", "raw_query": text}


def test_voice_parser_power():
    res = parse_voice_command("Turn on the living room TV")
    assert res["intent"] == "POWER_ON"
    assert res["target"] == "TV"

    res_stb = parse_voice_command("Turn on Tata Play set top box")
    assert res_stb["intent"] == "POWER_ON"
    assert res_stb["target"] == "STB"


def test_voice_parser_volume():
    res = parse_voice_command("volume up by 5")
    assert res["intent"] == "VOLUME_UP"
    assert res["steps"] == 5

    res_mute = parse_voice_command("Mute TV")
    assert res_mute["intent"] == "MUTE"


def test_voice_parser_channels():
    res = parse_voice_command("change to channel 205")
    assert res["intent"] == "SET_CHANNEL"
    assert res["channel"] == 205
    assert res["target"] == "STB"


def test_voice_parser_apps():
    res = parse_voice_command("Open Netflix")
    assert res["intent"] == "LAUNCH_APP"
    assert res["command"] == "NETFLIX"
