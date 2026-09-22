"""
Comprehensive AI Command Test Suite
Contains over 100 natural-language test cases verifying that natural-language user inputs
correctly resolve to validated structured AICommand objects with proper IntentEnum and ActionEnum.
"""

import pytest
from backend.ai.providers import LocalIntentEngine
from backend.ai.schemas import IntentEnum, ActionEnum
from backend.devices.mock_devices import MockTV


@pytest.fixture
def parser():
    return LocalIntentEngine()


@pytest.fixture
def mock_tv():
    return MockTV()


# Define test cases: (user_prompt, expected_intent, expected_action)
TEST_CASES_100 = [
    # --- POWER INTENTS (1-10) ---
    ("Turn on the TV", IntentEnum.POWER, ActionEnum.ON),
    ("Switch on the living room television", IntentEnum.POWER, ActionEnum.ON),
    ("Power on the TV", IntentEnum.POWER, ActionEnum.ON),
    ("Start TV", IntentEnum.POWER, ActionEnum.ON),
    ("Turn off TV", IntentEnum.POWER, ActionEnum.OFF),
    ("Switch off the TV", IntentEnum.POWER, ActionEnum.OFF),
    ("Power off television", IntentEnum.POWER, ActionEnum.OFF),
    ("Shut down TV", IntentEnum.POWER, ActionEnum.OFF),
    ("Turn off the screen", IntentEnum.POWER, ActionEnum.OFF),
    ("Toggle power", IntentEnum.POWER, ActionEnum.TOGGLE),

    # --- VOLUME INTENTS: SET (11-20) ---
    ("Set volume to 25", IntentEnum.VOLUME, ActionEnum.SET),
    ("Set volume to 50", IntentEnum.VOLUME, ActionEnum.SET),
    ("Set sound to 15", IntentEnum.VOLUME, ActionEnum.SET),
    ("Volume 30", IntentEnum.VOLUME, ActionEnum.SET),
    ("Set vol 10", IntentEnum.VOLUME, ActionEnum.SET),
    ("Volume to 20", IntentEnum.VOLUME, ActionEnum.SET),
    ("Sound at 40", IntentEnum.VOLUME, ActionEnum.SET),
    ("Set volume at 12", IntentEnum.VOLUME, ActionEnum.SET),
    ("Volume 0", IntentEnum.VOLUME, ActionEnum.SET),
    ("Set volume to 100", IntentEnum.VOLUME, ActionEnum.SET),

    # --- VOLUME INTENTS: UP & LOUDER (21-30) ---
    ("Increase volume", IntentEnum.VOLUME, ActionEnum.UP),
    ("Make it louder", IntentEnum.VOLUME, ActionEnum.UP),
    ("Turn up volume", IntentEnum.VOLUME, ActionEnum.UP),
    ("Raise volume", IntentEnum.VOLUME, ActionEnum.UP),
    ("Turn up the sound", IntentEnum.VOLUME, ActionEnum.UP),
    ("Increase sound", IntentEnum.VOLUME, ActionEnum.UP),
    ("Volume up", IntentEnum.VOLUME, ActionEnum.UP),
    ("Louder", IntentEnum.VOLUME, ActionEnum.UP),
    ("Increase volume by 5", IntentEnum.VOLUME, ActionEnum.UP),
    ("Raise volume by 10", IntentEnum.VOLUME, ActionEnum.UP),

    # --- VOLUME INTENTS: DOWN & QUIETER (31-40) ---
    ("Decrease volume", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Make it quieter", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Lower volume", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Turn down volume", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Quieter", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Lower the sound", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Reduce volume", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Volume down", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Decrease volume by 5", IntentEnum.VOLUME, ActionEnum.DOWN),
    ("Lower volume by 10", IntentEnum.VOLUME, ActionEnum.DOWN),

    # --- MUTE INTENTS (41-48) ---
    ("Mute the TV", IntentEnum.MUTE, ActionEnum.MUTE),
    ("Mute", IntentEnum.MUTE, ActionEnum.MUTE),
    ("Silence the TV", IntentEnum.MUTE, ActionEnum.MUTE),
    ("Cut sound", IntentEnum.MUTE, ActionEnum.MUTE),
    ("Unmute the TV", IntentEnum.MUTE, ActionEnum.UNMUTE),
    ("Unmute", IntentEnum.MUTE, ActionEnum.UNMUTE),
    ("Restore sound", IntentEnum.MUTE, ActionEnum.UNMUTE),
    ("Sound back", IntentEnum.MUTE, ActionEnum.UNMUTE),

    # --- CHANNEL INTENTS: NUMBERED (49-56) ---
    ("Change channel to 405", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Tune to 101", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Go to channel 201", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Channel 509", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Tune to channel 130", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Change to 471", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Go to channel 714", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Tune to 610", IntentEnum.CHANNEL, ActionEnum.CHANGE),

    # --- CHANNEL INTENTS: INDIAN CHANNEL NAMES (57-68) ---
    ("Watch Star Sports", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Go to Star Sports 1 HD", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Tune to Sony Ten", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Watch Sony Ten 1", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Watch Aaj Tak", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Tune to NDTV", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Watch Colors", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Watch Zee TV", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Watch Discovery", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Tune to Nat Geo", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Go to Cartoon Network", IntentEnum.CHANNEL, ActionEnum.CHANGE),
    ("Watch DD Sports", IntentEnum.CHANNEL, ActionEnum.CHANGE),

    # --- CHANNEL INTENTS: NAVIGATION & LAST (69-74) ---
    ("Channel up", IntentEnum.CHANNEL, ActionEnum.UP),
    ("Next channel", IntentEnum.CHANNEL, ActionEnum.UP),
    ("Channel down", IntentEnum.CHANNEL, ActionEnum.DOWN),
    ("Previous channel", IntentEnum.CHANNEL, ActionEnum.DOWN),
    ("Last channel", IntentEnum.CHANNEL, ActionEnum.SWITCH),
    ("Back to previous channel", IntentEnum.CHANNEL, ActionEnum.SWITCH),

    # --- APPLICATION INTENTS (75-84) ---
    ("Open YouTube", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Launch Netflix", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Start Prime Video", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Open Hotstar", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Launch Disney Hotstar", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Open Spotify", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Launch Jio Cinema", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Open Zee5", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Launch Sony Liv", IntentEnum.APPLICATION, ActionEnum.OPEN),
    ("Open Apple TV", IntentEnum.APPLICATION, ActionEnum.OPEN),

    # --- INPUT / SOURCE INTENTS (85-90) ---
    ("Switch to HDMI 1", IntentEnum.INPUT, ActionEnum.CHANGE),
    ("Change input to HDMI 2", IntentEnum.INPUT, ActionEnum.CHANGE),
    ("Switch to HDMI 3", IntentEnum.INPUT, ActionEnum.CHANGE),
    ("Go to AV", IntentEnum.INPUT, ActionEnum.CHANGE),
    ("Change to HDMI 4", IntentEnum.INPUT, ActionEnum.CHANGE),
    ("Source to HDMI 1", IntentEnum.INPUT, ActionEnum.CHANGE),

    # --- NAVIGATION INTENTS (91-98) ---
    ("Go home", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),
    ("Home screen", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),
    ("Go back", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),
    ("Press OK", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),
    ("Select", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),
    ("Up", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),
    ("Down", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),
    ("Left", IntentEnum.NAVIGATION, ActionEnum.NAVIGATE),

    # --- SMART SCENES (99-106) ---
    ("Start movie mode", IntentEnum.SCENE, ActionEnum.EXECUTE),
    ("Watch movie", IntentEnum.SCENE, ActionEnum.EXECUTE),
    ("Start cricket mode", IntentEnum.SCENE, ActionEnum.EXECUTE),
    ("Watch cricket", IntentEnum.SCENE, ActionEnum.EXECUTE),
    ("Good night", IntentEnum.SCENE, ActionEnum.EXECUTE),
    ("Turn everything off", IntentEnum.SCENE, ActionEnum.EXECUTE),
    ("Start game mode", IntentEnum.SCENE, ActionEnum.EXECUTE),
    ("Gaming mode", IntentEnum.SCENE, ActionEnum.EXECUTE),

    # --- DISCOVERY, STATUS & DIAGNOSTICS (107-114) ---
    ("What devices are connected?", IntentEnum.DEVICE_DISCOVERY, ActionEnum.QUERY),
    ("List devices", IntentEnum.DEVICE_DISCOVERY, ActionEnum.QUERY),
    ("Discover devices", IntentEnum.DEVICE_DISCOVERY, ActionEnum.DISCOVER),
    ("Scan network", IntentEnum.DEVICE_DISCOVERY, ActionEnum.DISCOVER),
    ("Is my TV online?", IntentEnum.STATUS, ActionEnum.QUERY),
    ("Why isn't my TV responding?", IntentEnum.STATUS, ActionEnum.QUERY),
    ("My TV is not responding", IntentEnum.STATUS, ActionEnum.QUERY),
    ("Check connection", IntentEnum.STATUS, ActionEnum.QUERY),

    # --- PLAYBACK & MENU INTENTS (115-120) ---
    ("Play", IntentEnum.PLAYBACK, ActionEnum.PLAY),
    ("Pause", IntentEnum.PLAYBACK, ActionEnum.PAUSE),
    ("Stop", IntentEnum.PLAYBACK, ActionEnum.STOP),
    ("Fast forward", IntentEnum.PLAYBACK, ActionEnum.FORWARD),
    ("Rewind", IntentEnum.PLAYBACK, ActionEnum.REWIND),
    ("Open menu", IntentEnum.MENU, ActionEnum.OPEN),
]


@pytest.mark.parametrize("prompt, expected_intent, expected_action", TEST_CASES_100)
def test_nlp_test_suite_100_cases(parser, mock_tv, prompt, expected_intent, expected_action):
    """Verify that every natural language prompt parses to the exact expected Intent and Action."""
    seq = parser.parse_command(prompt, mock_tv)
    assert len(seq.commands) >= 1, f"No commands parsed for '{prompt}'"
    cmd = seq.commands[0]
    assert cmd.intent == expected_intent, f"Wrong intent for '{prompt}': got {cmd.intent}, expected {expected_intent}"
    assert cmd.action == expected_action, f"Wrong action for '{prompt}': got {cmd.action}, expected {expected_action}"


def test_compound_multi_step_commands(parser, mock_tv):
    """Verify sequential execution parsing for compound prompts."""
    # "Turn on the TV and set volume to 25"
    seq = parser.parse_command("Turn on the TV and set volume to 25", mock_tv)
    assert seq.is_multi_step is True
    assert len(seq.commands) == 2
    assert seq.commands[0].intent == IntentEnum.POWER
    assert seq.commands[1].intent == IntentEnum.VOLUME
    assert seq.commands[1].value == 25

    # "Open YouTube and set volume to 20"
    seq2 = parser.parse_command("Open YouTube and set volume to 20", mock_tv)
    assert len(seq2.commands) == 2
    assert seq2.commands[0].intent == IntentEnum.APPLICATION
    assert seq2.commands[0].application == "YouTube"
    assert seq2.commands[1].intent == IntentEnum.VOLUME
    assert seq2.commands[1].value == 20


def test_unsupported_appliance_rejection(parser, mock_tv):
    """Verify friendly detection of unsupported home appliances."""
    seq = parser.parse_command("Turn on the washing machine", mock_tv)
    assert len(seq.commands) == 1
    assert "washing machine" in seq.commands[0].explanation.lower()
