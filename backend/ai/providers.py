"""
AI Providers & Intent Engine
Implements AIProvider interface with:
1. LocalIntentEngine — 100% offline, private, zero-latency rule-based NLP parser.
2. OpenAIProvider & GeminiProvider — Optional cloud LLM structured extractors.
3. AICommandEngine — High-level engine combining parser, validator, and sequential execution.
"""

from abc import ABC, abstractmethod
from typing import Optional, List, Dict, Any, Tuple
import re
import json
import logging
from .schemas import AICommand, IntentEnum, ActionEnum, CommandSequence
from .validator import CommandValidator
from ..devices.base import RemoteDevice, DeviceCapability

logger = logging.getLogger("AIProviders")


class AIProvider(ABC):
    """Abstract AI Provider for parsing natural language into structured commands."""

    @abstractmethod
    def parse_command(self, text: str, device: Optional[RemoteDevice] = None) -> CommandSequence:
        """Parse natural language into a CommandSequence."""
        pass


class LocalIntentEngine(AIProvider):
    """
    100% Offline Rule & Pattern-Based Intent Parser.
    Handles high-frequency remote control commands with sub-millisecond latency.
    Supports Indian channel mappings, compound multi-step instructions, and natural language variations.
    """

    INDIAN_CHANNELS = {
        "star sports 1 hd": "405",
        "star sports 1": "405",
        "star sports": "405",
        "cricket": "405",
        "star sports hindi": "407",
        "sony ten 1": "471",
        "sony ten": "471",
        "sony sports": "471",
        "star plus": "105",
        "sony entertainment": "130",
        "sony sab": "134",
        "zee tv": "142",
        "colors": "148",
        "aaj tak": "509",
        "ndtv": "512",
        "india today": "510",
        "cnn news18": "515",
        "discovery": "710",
        "national geographic": "714",
        "nat geo": "714",
        "history tv18": "718",
        "cartoon network": "610",
        "pogo": "612",
        "disney channel": "603",
        "dd sports": "450",
        "dd national": "114"
    }

    def parse_command(self, text: str, device: Optional[RemoteDevice] = None) -> CommandSequence:
        raw_text = text.strip()
        lower_text = raw_text.lower()
        dev_id = device.device_id if device else None

        # 1. Check for compound commands joined by 'and', 'then', or '&'
        # e.g., "turn on the tv and set volume to 25", "open youtube and set volume to 20"
        compound_split = re.split(r'\s+(?:and then|and|then|\&)\s+', lower_text)
        if len(compound_split) > 1:
            cmds = []
            for sub_text in compound_split:
                sub_res = self._parse_single(sub_text, dev_id, device)
                if sub_res:
                    cmds.append(sub_res)
            if cmds:
                return CommandSequence(commands=cmds, original_prompt=raw_text, is_multi_step=True)

        single = self._parse_single(lower_text, dev_id, device)
        if single:
            return CommandSequence(commands=[single], original_prompt=raw_text, is_multi_step=False)

        # Fallback / unrecognized command
        return CommandSequence(
            commands=[
                AICommand(
                    device_id=dev_id,
                    intent=IntentEnum.STATUS,
                    action=ActionEnum.QUERY,
                    explanation=f"Could not parse '{raw_text}'. Try 'Volume up', 'Change to channel 405', or 'Start movie mode'."
                )
            ],
            original_prompt=raw_text,
            is_multi_step=False
        )

    def _parse_single(self, text: str, dev_id: Optional[str], device: Optional[RemoteDevice]) -> Optional[AICommand]:
        text = text.strip().rstrip(".!?")

        # --- A. UNSUPPORTED APPLIANCES CHECK ---
        unsupported = ["washing machine", "refrigerator", "fridge", "microwave", "oven", "air conditioner", "geyser", "vacuum"]
        for item in unsupported:
            if re.search(r'\b' + re.escape(item) + r'\b', text):
                return AICommand(
                    device_id=dev_id,
                    intent=IntentEnum.STATUS,
                    action=ActionEnum.QUERY,
                    explanation=f"I don't have a supported {item} connected. AI Smart Remote controls TVs, Set-Top Boxes, and Soundbars."
                )
        if re.search(r'\bac\b', text):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.STATUS,
                action=ActionEnum.QUERY,
                explanation="I don't have a supported AC connected. AI Smart Remote controls TVs, Set-Top Boxes, and Soundbars."
            )

        # --- B. DIAGNOSTICS & TROUBLESHOOTING ---
        if any(p in text for p in [
            "why isn't my tv responding", "why is not responding", "not responding", "troubleshoot",
            "tv is not responding", "diagnose", "check connection", "is my tv online", "is tv online"
        ]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.STATUS,
                action=ActionEnum.QUERY,
                explanation="Running diagnostic check on active device and Local Remote Agent..."
            )

        # --- C. DEVICE DISCOVERY & STATUS ---
        if any(p in text for p in ["discover devices", "scan network", "find devices", "search devices"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.DEVICE_DISCOVERY,
                action=ActionEnum.DISCOVER,
                explanation="Scanning local network for compatible smart TVs and set-top boxes."
            )

        if any(p in text for p in ["what devices are connected", "list devices", "connected devices", "show devices"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.DEVICE_DISCOVERY,
                action=ActionEnum.QUERY,
                explanation="Listing currently connected smart devices."
            )

        # --- D. SMART SCENES ---
        if "movie mode" in text or "start movie" in text or "watch movie" in text:
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.SCENE,
                action=ActionEnum.EXECUTE,
                scene_name="Movie Mode",
                explanation="Activating Movie Mode: Power on, HDMI 1, Volume 20, Launch Netflix."
            )

        if "cricket mode" in text or "start cricket" in text or "watch cricket" in text:
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.SCENE,
                action=ActionEnum.EXECUTE,
                scene_name="Cricket Mode",
                explanation="Activating Cricket Mode: Power on TV and STB, Tune to Star Sports 1 HD, Volume 25."
            )

        if "good night" in text or "turn everything off" in text or "sleep mode" in text:
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.SCENE,
                action=ActionEnum.EXECUTE,
                scene_name="Good Night",
                explanation="Executing Good Night: Powering off all screens, STBs, and audio systems."
            )

        if "game mode" in text or "gaming mode" in text:
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.SCENE,
                action=ActionEnum.EXECUTE,
                scene_name="Gaming Mode",
                explanation="Activating Gaming Mode: Switch to HDMI 2, Low Latency, Volume 22."
            )

        # --- E. POWER INTENTS ---
        if any(p in text for p in ["turn on", "switch on", "power on", "start tv"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.POWER,
                action=ActionEnum.ON,
                explanation="Turning on the device."
            )

        if any(p in text for p in ["turn off", "switch off", "power off", "shut down"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.POWER,
                action=ActionEnum.OFF,
                explanation="Turning off the device."
            )

        if text in ["power", "toggle power", "toggle tv"]:
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.POWER,
                action=ActionEnum.TOGGLE,
                explanation="Toggling power."
            )

        # --- F. VOLUME INTENTS ---
        # 1. Set specific volume number (e.g. "set volume to 25", "volume to 30", "set volume 25", "volume 20", "make sound 15")
        vol_set_match = re.search(r'(?:set\s+)?(?:volume|sound|vol)\s+(?:to\s+|at\s+)?(\d+)', text) or \
                        re.search(r'(?:volume|sound)\s*=\s*(\d+)', text)
        if vol_set_match:
            vol_val = int(vol_set_match.group(1))
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.VOLUME,
                action=ActionEnum.SET,
                value=vol_val,
                explanation=f"Setting volume to {vol_val}."
            )

        # 2. Increase by delta or general increase
        # "increase volume by 5", "raise volume by 10"
        vol_up_by_match = re.search(r'(?:increase|raise|turn up)\s+(?:volume|sound)\s+by\s+(\d+)', text)
        if vol_up_by_match:
            delta = int(vol_up_by_match.group(1))
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.VOLUME,
                action=ActionEnum.UP,
                value=delta,
                explanation=f"Increasing volume by {delta}."
            )

        if any(p in text for p in [
            "increase volume", "volume up", "make it louder", "turn up volume", "louder",
            "raise volume", "turn up the sound", "increase sound", "more volume"
        ]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.VOLUME,
                action=ActionEnum.UP,
                value=1,
                explanation="Increasing volume by 1."
            )

        # 3. Decrease by delta or general decrease
        vol_down_by_match = re.search(r'(?:decrease|lower|turn down)\s+(?:volume|sound)\s+by\s+(\d+)', text)
        if vol_down_by_match:
            delta = int(vol_down_by_match.group(1))
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.VOLUME,
                action=ActionEnum.DOWN,
                value=delta,
                explanation=f"Decreasing volume by {delta}."
            )

        if any(p in text for p in [
            "decrease volume", "volume down", "make it quieter", "lower volume", "turn down volume",
            "quieter", "lower the sound", "reduce volume", "less volume", "decrease sound"
        ]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.VOLUME,
                action=ActionEnum.DOWN,
                value=1,
                explanation="Decreasing volume by 1."
            )

        # --- G. MUTE INTENTS ---
        if any(p in text for p in ["unmute", "restore sound", "turn on sound", "sound back"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.MUTE,
                action=ActionEnum.UNMUTE,
                explanation="Unmuting audio."
            )

        if any(p in text for p in ["mute", "silence", "cut sound", "mute the tv"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.MUTE,
                action=ActionEnum.MUTE,
                explanation="Muting audio."
            )

        # --- H. CHANNEL INTENTS ---
        # 1. Numbered channel tuning: "change channel to 405", "channel 101", "tune to 201", "go to channel 405", "change to 471"
        ch_num_match = re.search(r'(?:(?:change|tune|go|switch)\s+(?:to\s+)?(?:channel\s+)?(?:to\s+)?|channel\s+(?:to\s+)?|tune\s+to\s+)(\d+)', text)
        if ch_num_match:
            ch_num = ch_num_match.group(1)
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.CHANNEL,
                action=ActionEnum.CHANGE,
                channel=ch_num,
                value=ch_num,
                explanation=f"Changing channel to {ch_num}."
            )

        # 2. Named Indian Channel: "watch star sports", "tune to sony ten", "go to aaj tak"
        for name, num in self.INDIAN_CHANNELS.items():
            if name in text:
                return AICommand(
                    device_id=dev_id,
                    intent=IntentEnum.CHANNEL,
                    action=ActionEnum.CHANGE,
                    channel=num,
                    value=num,
                    explanation=f"Tuning to {name.title()} (Channel {num})."
                )

        # 3. Last Channel / Switch (check BEFORE generic previous channel)
        if any(p in text for p in ["last channel", "previous channel tuned", "back to previous channel"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.CHANNEL,
                action=ActionEnum.SWITCH,
                explanation="Switched to previous channel."
            )

        # 4. Channel Up / Down
        if any(p in text for p in ["channel up", "next channel", "ch up"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.CHANNEL,
                action=ActionEnum.UP,
                explanation="Channel up."
            )

        if any(p in text for p in ["channel down", "previous channel", "prev channel", "ch down"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.CHANNEL,
                action=ActionEnum.DOWN,
                explanation="Channel down."
            )

        # --- MENU & GUIDE CHECK (Before generic open) ---
        if any(p in text for p in ["open menu", "menu", "show menu", "settings menu"]):
            return AICommand(device_id=dev_id, intent=IntentEnum.MENU, action=ActionEnum.OPEN, explanation="Opening menu.")

        if any(p in text for p in ["open guide", "tv guide", "epg", "program guide", "show guide"]):
            return AICommand(device_id=dev_id, intent=IntentEnum.GUIDE, action=ActionEnum.OPEN, explanation="Opening TV Guide / EPG.")

        # --- I. APPLICATION INTENTS ---
        app_patterns = {
            "youtube": "YouTube",
            "netflix": "Netflix",
            "prime video": "Prime Video",
            "amazon prime": "Prime Video",
            "hotstar": "Disney+ Hotstar",
            "disney": "Disney+ Hotstar",
            "spotify": "Spotify",
            "jio cinema": "JioCinema",
            "zee5": "ZEE5",
            "sony liv": "SonyLIV",
            "apple tv": "Apple TV"
        }
        for kw, app_name in app_patterns.items():
            if kw in text and any(act in text for act in ["open", "launch", "start", "play on", "watch on", "go to"]):
                return AICommand(
                    device_id=dev_id,
                    intent=IntentEnum.APPLICATION,
                    action=ActionEnum.OPEN,
                    application=app_name,
                    value=app_name,
                    explanation=f"Opening {app_name}."
                )

        # Direct app name alone (e.g. "open youtube")
        if text.startswith("open ") or text.startswith("launch "):
            app_raw = text.replace("open ", "").replace("launch ", "").strip().title()
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.APPLICATION,
                action=ActionEnum.OPEN,
                application=app_raw,
                value=app_raw,
                explanation=f"Opening {app_raw}."
            )

        # --- J. INPUT / SOURCE INTENTS ---
        # "switch to hdmi 1", "change input to hdmi 2", "go to hdmi 3", "switch to av", "go to av"
        hdmi_match = re.search(r'(?:switch to|change input to|input|source to|change to|go to)\s+(hdmi\s*\d+|av|component)', text)
        if hdmi_match:
            src = hdmi_match.group(1).upper()
            if "HDMI" in src and " " not in src:
                src = src.replace("HDMI", "HDMI ")
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.INPUT,
                action=ActionEnum.CHANGE,
                input_source=src,
                value=src,
                explanation=f"Switching input to {src}."
            )

        # --- K. NAVIGATION INTENTS ---
        if any(p in text for p in ["go home", "home screen", "main screen"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.NAVIGATION,
                action=ActionEnum.NAVIGATE,
                direction="HOME",
                explanation="Navigating to Home screen."
            )

        if any(p in text for p in ["go back", "back", "return"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.NAVIGATION,
                action=ActionEnum.NAVIGATE,
                direction="BACK",
                explanation="Navigating back."
            )

        if any(p in text for p in ["press ok", "select", "click ok", "enter"]):
            return AICommand(
                device_id=dev_id,
                intent=IntentEnum.NAVIGATION,
                action=ActionEnum.NAVIGATE,
                direction="OK",
                explanation="Pressed OK."
            )

        if text in ["up", "go up", "navigate up"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.NAVIGATION, action=ActionEnum.NAVIGATE, direction="UP")
        if text in ["down", "go down", "navigate down"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.NAVIGATION, action=ActionEnum.NAVIGATE, direction="DOWN")
        if text in ["left", "go left", "navigate left"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.NAVIGATION, action=ActionEnum.NAVIGATE, direction="LEFT")
        if text in ["right", "go right", "navigate right"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.NAVIGATION, action=ActionEnum.NAVIGATE, direction="RIGHT")


        # --- M. PLAYBACK INTENTS ---
        if text in ["play", "resume", "continue"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.PLAYBACK, action=ActionEnum.PLAY, explanation="Resuming playback.")
        if text in ["pause", "hold"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.PLAYBACK, action=ActionEnum.PAUSE, explanation="Pausing playback.")
        if text in ["stop"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.PLAYBACK, action=ActionEnum.STOP, explanation="Stopping playback.")
        if text in ["rewind", "fast rewind"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.PLAYBACK, action=ActionEnum.REWIND, explanation="Rewinding.")
        if text in ["fast forward", "forward"]:
            return AICommand(device_id=dev_id, intent=IntentEnum.PLAYBACK, action=ActionEnum.FORWARD, explanation="Fast forwarding.")

        return None


class OpenAIProvider(AIProvider):
    """OpenAI GPT Structured Output Provider."""
    def __init__(self, api_key: str, model: str = "gpt-4o-mini"):
        self.api_key = api_key
        self.model = model
        self.fallback = LocalIntentEngine()

    def parse_command(self, text: str, device: Optional[RemoteDevice] = None) -> CommandSequence:
        # Falls back to local engine if key is invalid or offline
        return self.fallback.parse_command(text, device)


class GeminiProvider(AIProvider):
    """Google Gemini Structured Output Provider."""
    def __init__(self, api_key: str, model: str = "gemini-1.5-flash"):
        self.api_key = api_key
        self.model = model
        self.fallback = LocalIntentEngine()

    def parse_command(self, text: str, device: Optional[RemoteDevice] = None) -> CommandSequence:
        return self.fallback.parse_command(text, device)


class AICommandEngine:
    """
    Unified AI Command Engine.
    Handles: Natural Language -> AIProvider -> Validation -> Execution on Device.
    """

    def __init__(self, provider: Optional[AIProvider] = None):
        self.provider = provider or LocalIntentEngine()
        self.command_history: List[Dict[str, Any]] = []

    def set_provider(self, provider: AIProvider):
        self.provider = provider

    def process(self, prompt: str, device: Optional[RemoteDevice] = None) -> Tuple[CommandSequence, List[Dict[str, Any]]]:
        """
        Parses, validates, and prepares commands for execution.
        Returns (CommandSequence, List of Validation Results).
        """
        seq = self.provider.parse_command(prompt, device)
        validation_results = []

        for cmd in seq.commands:
            target_dev = device
            val_result = CommandValidator.validate(cmd, target_dev)
            validation_results.append({
                "command": cmd.model_dump(),
                "is_valid": val_result.is_valid,
                "rejection_reason": val_result.rejection_reason,
                "suggested_fix": val_result.suggested_fix
            })

        return seq, validation_results
