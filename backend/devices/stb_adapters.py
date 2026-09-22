"""
Indian Set-Top Box (STB) & DTH Adapters
Adapters for Tata Play, Airtel Digital TV, Dish TV, Videocon d2h, and Generic IR STBs (Sun Direct, DD Free Dish, Hathway, GTPL, DEN, Siti, Asianet).
"""

from typing import Dict, Any, Optional, List
import logging
from .base import RemoteDevice, DeviceType, DeviceCapability, ConnectionStatus, DeviceState
from ..protocols.base import InfraredProtocol, HTTPProtocol

logger = logging.getLogger("STBAdapters")


class TataPlayAdapter(RemoteDevice):
    """Tata Play (formerly Tata Sky) DTH & Binge+ Android STB Adapter."""

    def __init__(self, device_id: str, name: str, ip_address: Optional[str] = None, room: str = "Living Room"):
        protocols = ["infrared"]
        if ip_address:
            protocols.append("wifi")
        super().__init__(
            device_id=device_id,
            name=name,
            brand="Tata Play",
            model="Binge+ / HD Set-Top Box",
            device_type=DeviceType.SET_TOP_BOX,
            protocols=protocols,
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.CHANNEL,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.NUMPAD,
                DeviceCapability.COLOR_KEYS,
                DeviceCapability.GUIDE,
                DeviceCapability.INFO,
                DeviceCapability.MENU
            ],
            room=room,
            ip_address=ip_address
        )
        self.ir_proto = InfraredProtocol(ir_encoding="NEC")
        self.state.channel = "405"  # Star Sports 1 HD default

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd = command.upper()

        if cmd in ["CHANNEL_UP", "KEY_CHUP"]:
            try:
                curr = int(self.state.channel)
                self.state.channel = str(curr + 1)
            except ValueError:
                self.state.channel = "102"
        elif cmd in ["CHANNEL_DOWN", "KEY_CHDOWN"]:
            try:
                curr = int(self.state.channel)
                self.state.channel = str(max(1, curr - 1))
            except ValueError:
                self.state.channel = "100"
        elif cmd in ["SET_CHANNEL", "CHANGE_CHANNEL"]:
            self.state.channel = str(params.get("channel", params.get("value", self.state.channel)))

        ir_res = await self.ir_proto.send_command(cmd, params)
        return {
            "status": "success",
            "provider": "Tata Play",
            "command": cmd,
            "channel": self.state.channel,
            "raw": ir_res
        }


class AirtelDTHAdapter(RemoteDevice):
    """Airtel Digital TV & Xstream 4K Box Adapter."""

    def __init__(self, device_id: str, name: str, ip_address: Optional[str] = None, room: str = "Living Room"):
        protocols = ["infrared"]
        if ip_address:
            protocols.append("wifi")
        super().__init__(
            device_id=device_id,
            name=name,
            brand="Airtel Digital TV",
            model="Xstream 4K / HD STB",
            device_type=DeviceType.SET_TOP_BOX,
            protocols=protocols,
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.CHANNEL,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.NUMPAD,
                DeviceCapability.COLOR_KEYS,
                DeviceCapability.GUIDE,
                DeviceCapability.INFO
            ],
            room=room,
            ip_address=ip_address
        )
        self.ir_proto = InfraredProtocol(ir_encoding="NEC")
        self.state.channel = "277"  # Star Sports 1 HD on Airtel

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd = command.upper()
        if cmd in ["SET_CHANNEL", "CHANGE_CHANNEL"]:
            self.state.channel = str(params.get("channel", params.get("value", self.state.channel)))
        ir_res = await self.ir_proto.send_command(cmd, params)
        return {"status": "success", "provider": "Airtel Digital TV", "command": cmd, "raw": ir_res}


class DishTVAdapter(RemoteDevice):
    """Dish TV & SMRT Hub STB Adapter."""

    def __init__(self, device_id: str, name: str, room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand="Dish TV",
            model="DishNXT HD / SMRT Hub",
            device_type=DeviceType.SET_TOP_BOX,
            protocols=["infrared"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.CHANNEL,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.NUMPAD,
                DeviceCapability.COLOR_KEYS,
                DeviceCapability.GUIDE
            ],
            room=room
        )
        self.ir_proto = InfraredProtocol(ir_encoding="NEC")

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        ir_res = await self.ir_proto.send_command(command, params)
        return {"status": "success", "provider": "Dish TV", "command": command, "raw": ir_res}


class VideoconD2HAdapter(RemoteDevice):
    """Videocon d2h Digital STB Adapter."""

    def __init__(self, device_id: str, name: str, room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand="Videocon d2h",
            model="d2h HD Box",
            device_type=DeviceType.SET_TOP_BOX,
            protocols=["infrared"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.CHANNEL,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.NUMPAD,
                DeviceCapability.COLOR_KEYS
            ],
            room=room
        )
        self.ir_proto = InfraredProtocol(ir_encoding="NEC")

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        ir_res = await self.ir_proto.send_command(command, params)
        return {"status": "success", "provider": "Videocon d2h", "command": command, "raw": ir_res}


class GenericIRSTBAdapter(RemoteDevice):
    """
    Generic Set-Top Box Adapter for regional cable & DTH operators:
    Sun Direct, DD Free Dish, Hathway, GTPL, DEN, Siti Cable, Asianet, ACT.
    """

    def __init__(self, device_id: str, name: str, brand: str, model: str = "Standard Digital STB", room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand=brand,
            model=model,
            device_type=DeviceType.SET_TOP_BOX,
            protocols=["infrared"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.CHANNEL,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.NUMPAD,
                DeviceCapability.COLOR_KEYS,
                DeviceCapability.GUIDE,
                DeviceCapability.INFO
            ],
            room=room
        )
        self.ir_proto = InfraredProtocol(ir_encoding="NEC")
        self.state.state_available = False

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        ir_res = await self.ir_proto.send_command(command, params)
        return {"status": "transmitted", "provider": self.brand, "command": command, "raw": ir_res}
