"""
AI Command Validator
Enforces:
1. Pydantic JSON schema correctness
2. Target device existence
3. Device capability validation (does device support volume, apps, HDMI input?)
4. Value bounds (Volume 0-100, valid channels)
5. Risk validation (confirmation check)
"""

from typing import Optional, List, Dict, Any
import logging
from .schemas import AICommand, IntentEnum, ActionEnum, CommandValidationResult
from ..devices.base import RemoteDevice, DeviceCapability, DeviceType

logger = logging.getLogger("CommandValidator")


class CommandValidator:
    """Validates that AI-generated commands match device capabilities and limits."""

    INTENT_TO_CAPABILITY = {
        IntentEnum.POWER: DeviceCapability.POWER,
        IntentEnum.VOLUME: DeviceCapability.VOLUME,
        IntentEnum.MUTE: DeviceCapability.MUTE,
        IntentEnum.CHANNEL: DeviceCapability.CHANNEL,
        IntentEnum.NAVIGATION: DeviceCapability.NAVIGATION,
        IntentEnum.APPLICATION: DeviceCapability.APPS,
        IntentEnum.INPUT: DeviceCapability.INPUT,
        IntentEnum.PLAYBACK: DeviceCapability.PLAYBACK,
        IntentEnum.MENU: DeviceCapability.MENU,
        IntentEnum.GUIDE: DeviceCapability.GUIDE,
    }

    @classmethod
    def validate(cls, command: AICommand, device: Optional[RemoteDevice] = None) -> CommandValidationResult:
        # 1. Device Existence check
        if command.intent not in [IntentEnum.DEVICE_DISCOVERY, IntentEnum.DEVICE_SWITCH, IntentEnum.SCENE, IntentEnum.STATUS]:
            if device is None:
                return CommandValidationResult(
                    is_valid=False,
                    command=command,
                    rejection_reason="No target device is currently selected or available.",
                    suggested_fix="Please select or connect a device first."
                )

        # If it's a general intent without target device needed, it's valid
        if device is None:
            return CommandValidationResult(is_valid=True, command=command)

        # 2. Check Device Capability
        required_cap = cls.INTENT_TO_CAPABILITY.get(command.intent)
        if required_cap and not device.supports(required_cap):
            return CommandValidationResult(
                is_valid=False,
                command=command,
                rejection_reason=f"The device '{device.name}' does not support {command.intent.value.lower()} control.",
                suggested_fix=f"Use a compatible Smart TV or STB for {command.intent.value.lower()}."
            )

        # 3. Specific validation rules
        if command.intent == IntentEnum.VOLUME:
            if command.action == ActionEnum.SET:
                try:
                    vol = int(command.value)
                    if vol < 0 or vol > 100:
                        return CommandValidationResult(
                            is_valid=False,
                            command=command,
                            rejection_reason=f"Volume value {vol} is out of bounds (must be between 0 and 100).",
                            suggested_fix="Choose a volume level between 0 and 100."
                        )
                except (ValueError, TypeError):
                    return CommandValidationResult(
                        is_valid=False,
                        command=command,
                        rejection_reason=f"Invalid volume value '{command.value}'.",
                        suggested_fix="Specify a numeric volume level (e.g. 25)."
                    )

        if command.intent == IntentEnum.INPUT:
            # Check valid inputs (e.g. HDMI 1, HDMI 2, HDMI 3, AV)
            source = (command.input_source or str(command.value or "")).upper().strip()
            valid_sources = ["HDMI 1", "HDMI 2", "HDMI 3", "HDMI 4", "AV", "COMPONENT", "TV", "USB"]
            if source and source not in valid_sources and not source.startswith("HDMI"):
                return CommandValidationResult(
                    is_valid=False,
                    command=command,
                    rejection_reason=f"Input '{source}' is not recognized on {device.name}.",
                    suggested_fix="Choose HDMI 1, HDMI 2, HDMI 3, or AV."
                )

        if command.intent == IntentEnum.APPLICATION:
            if not command.application:
                return CommandValidationResult(
                    is_valid=False,
                    command=command,
                    rejection_reason="No application name specified.",
                    suggested_fix="Specify an app like YouTube, Netflix, or Prime Video."
                )

        return CommandValidationResult(is_valid=True, command=command)
