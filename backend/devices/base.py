"""
Universal Remote Device Abstraction
Defines the unified RemoteDevice interface, capabilities, and device states.
"""

from abc import ABC, abstractmethod
from enum import Enum
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field
import time


class DeviceType(str, Enum):
    SMART_TV = "smart_tv"
    TV = "tv"
    SET_TOP_BOX = "set_top_box"
    SOUNDBAR = "soundbar"
    STREAMING_DEVICE = "streaming_device"


class ConnectionStatus(str, Enum):
    CONNECTED = "connected"
    DISCONNECTED = "disconnected"
    CONNECTING = "connecting"
    UNAVAILABLE = "unavailable"


class DeviceCapability(str, Enum):
    POWER = "power"
    VOLUME = "volume"
    MUTE = "mute"
    CHANNEL = "channel"
    NAVIGATION = "navigation"
    INPUT = "input"
    APPS = "apps"
    PLAYBACK = "playback"
    COLOR_KEYS = "color_keys"
    NUMPAD = "numpad"
    MENU = "menu"
    GUIDE = "guide"
    INFO = "info"
    HOME = "home"
    BACK = "back"


class DeviceState(BaseModel):
    """Normalized live state for any connected device."""
    power: bool = False
    volume: int = 20
    muted: bool = False
    input: str = "HDMI 1"
    channel: str = "101"
    application: Optional[str] = None
    state_available: bool = True
    last_updated: float = Field(default_factory=time.time)

    def to_display_dict(self) -> Dict[str, Any]:
        if not self.state_available:
            return {"status": "State unavailable (IR / One-way connection)"}
        return {
            "power": "ON" if self.power else "OFF",
            "volume": self.volume,
            "muted": "Muted" if self.muted else "Unmuted",
            "input": self.input,
            "channel": self.channel,
            "application": self.application or "None"
        }


class RemoteDevice(ABC):
    """
    Abstract Universal Remote Device.
    All manufacturer adapters (Samsung, LG, Sony, Tata Play, Mock) implement this interface.
    The UI and AI engine communicate solely through RemoteDevice.
    """

    def __init__(
        self,
        device_id: str,
        name: str,
        brand: str,
        model: str,
        device_type: DeviceType,
        protocols: List[str],
        capabilities: List[DeviceCapability],
        room: str = "Living Room",
        ip_address: Optional[str] = None
    ):
        self.device_id = device_id
        self.name = name
        self.brand = brand
        self.model = model
        self.device_type = device_type
        self.protocols = protocols
        self.capabilities = capabilities
        self.room = room
        self.ip_address = ip_address
        self.status = ConnectionStatus.DISCONNECTED
        self.state = DeviceState()

    @abstractmethod
    async def connect(self) -> bool:
        """Connect to device."""
        pass

    @abstractmethod
    async def disconnect(self) -> None:
        """Disconnect from device."""
        pass

    @abstractmethod
    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Execute a remote command (e.g. POWER, VOLUME_UP, SET_CHANNEL, OPEN_APP)."""
        pass

    def get_state(self) -> DeviceState:
        """Return the current known state of the device."""
        return self.state

    def supports(self, capability: DeviceCapability) -> bool:
        """Check if device supports a given capability."""
        return capability in self.capabilities

    def to_dict(self) -> Dict[str, Any]:
        return {
            "device_id": self.device_id,
            "name": self.name,
            "brand": self.brand,
            "model": self.model,
            "device_type": self.device_type.value,
            "protocols": self.protocols,
            "capabilities": [c.value for c in self.capabilities],
            "room": self.room,
            "ip_address": self.ip_address,
            "status": self.status.value,
            "state": self.state.model_dump()
        }
