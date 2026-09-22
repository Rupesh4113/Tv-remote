"""
Device Manager & Registry
Provides a unified registry to manage, query, switch, and dispatch commands to RemoteDevices.
"""

from typing import Dict, List, Optional, Any
import logging
from .base import RemoteDevice, DeviceCapability, DeviceType, ConnectionStatus
from .mock_devices import MockTV, MockSetTopBox, MockStreamingDevice
from .tv_adapters import (
    SamsungTVAdapter, LGTVAdapter, SonyTVAdapter,
    AndroidTVAdapter, GoogleTVAdapter, GenericIRTVAdapter
)
from .stb_adapters import (
    TataPlayAdapter, AirtelDTHAdapter, DishTVAdapter,
    VideoconD2HAdapter, GenericIRSTBAdapter
)

logger = logging.getLogger("DeviceManager")


class DeviceManager:
    """Singleton-friendly Device Manager for AI Smart Remote."""

    def __init__(self):
        self.devices: Dict[str, RemoteDevice] = {}
        self.active_device_id: Optional[str] = None
        self._init_default_demo_devices()

    def _init_default_demo_devices(self):
        """Pre-populate demo devices so the application works out-of-the-box."""
        demo_tv = MockTV(device_id="demo_samsung_tv", name="Living Room TV (Samsung)", room="Living Room")
        demo_stb = MockSetTopBox(device_id="demo_tataplay_stb", name="Tata Play HD STB", room="Living Room")
        demo_android = MockStreamingDevice(device_id="demo_bedroom_tv", name="Bedroom Android TV", room="Bedroom")

        self.register_device(demo_tv)
        self.register_device(demo_stb)
        self.register_device(demo_android)
        self.active_device_id = demo_tv.device_id

    def register_device(self, device: RemoteDevice):
        self.devices[device.device_id] = device
        if not self.active_device_id:
            self.active_device_id = device.device_id
        logger.info("Registered device %s (%s)", device.name, device.device_id)

    def remove_device(self, device_id: str) -> bool:
        if device_id in self.devices:
            del self.devices[device_id]
            if self.active_device_id == device_id:
                self.active_device_id = next(iter(self.devices.keys())) if self.devices else None
            return True
        return False

    def get_device(self, device_id: str) -> Optional[RemoteDevice]:
        return self.devices.get(device_id)

    def get_active_device(self) -> Optional[RemoteDevice]:
        if self.active_device_id and self.active_device_id in self.devices:
            return self.devices[self.active_device_id]
        if self.devices:
            self.active_device_id = next(iter(self.devices.keys()))
            return self.devices[self.active_device_id]
        return None

    def set_active_device(self, device_id: str) -> bool:
        if device_id in self.devices:
            self.active_device_id = device_id
            return True
        return False

    def list_devices(self, room: Optional[str] = None) -> List[RemoteDevice]:
        devs = list(self.devices.values())
        if room:
            devs = [d for d in devs if d.room.lower() == room.lower()]
        return devs

    def list_rooms(self) -> List[str]:
        rooms = set(d.room for d in self.devices.values())
        return sorted(list(rooms)) or ["Living Room", "Bedroom"]

    async def execute_command(self, device_id: str, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        device = self.get_device(device_id)
        if not device:
            return {"status": "error", "error": f"Device {device_id} not found."}
        return await device.execute(command, params)
