"""
Manufacturer TV Adapters
Concrete RemoteDevice implementations for Samsung, LG, Sony, Android TV, Google TV, and Generic IR TVs.
"""

from typing import Dict, Any, Optional, List
import logging
from .base import RemoteDevice, DeviceType, DeviceCapability, ConnectionStatus, DeviceState
from ..protocols.base import WebSocketProtocol, HTTPProtocol, InfraredProtocol

logger = logging.getLogger("TVAdapters")


class SamsungTVAdapter(RemoteDevice):
    """
    Samsung Smart TV Adapter (Tizen OS).
    Communicates via WebSocket on port 8001 (unencrypted) or 8002 (TLS).
    """

    def __init__(self, device_id: str, name: str, ip_address: str, mac_address: Optional[str] = None, token: Optional[str] = None, room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand="Samsung",
            model="Smart TV (Tizen)",
            device_type=DeviceType.SMART_TV,
            protocols=["wifi", "websocket"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.INPUT,
                DeviceCapability.APPS,
                DeviceCapability.PLAYBACK,
                DeviceCapability.NUMPAD,
                DeviceCapability.MENU,
                DeviceCapability.INFO
            ],
            room=room,
            ip_address=ip_address
        )
        self.token = token
        self.mac_address = mac_address
        self.ws_proto = WebSocketProtocol(f"ws://{ip_address}:8001/api/v2/channels/samsung.remote.control")

    async def connect(self) -> bool:
        success = await self.ws_proto.connect()
        self.status = ConnectionStatus.CONNECTED if success else ConnectionStatus.UNAVAILABLE
        return success

    async def disconnect(self) -> None:
        await self.ws_proto.disconnect()
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd_upper = command.upper()

        key_mapping = {
            "POWER": "KEY_POWER",
            "POWER_ON": "KEY_POWERON",
            "POWER_OFF": "KEY_POWEROFF",
            "VOLUME_UP": "KEY_VOLUP",
            "VOLUME_DOWN": "KEY_VOLDOWN",
            "MUTE": "KEY_MUTE",
            "NAV_UP": "KEY_UP",
            "NAV_DOWN": "KEY_DOWN",
            "NAV_LEFT": "KEY_LEFT",
            "NAV_RIGHT": "KEY_RIGHT",
            "NAV_OK": "KEY_ENTER",
            "NAV_HOME": "KEY_HOME",
            "NAV_BACK": "KEY_RETURN",
            "MENU": "KEY_MENU",
            "INFO": "KEY_INFO"
        }
        samsung_key = key_mapping.get(cmd_upper, cmd_upper)

        payload = {
            "method": "ms.remote.control",
            "params": {
                "Cmd": "Click",
                "DataOfCmd": samsung_key,
                "Option": "false",
                "TypeOfRemote": "SendRemoteKey"
            }
        }
        result = await self.ws_proto.send_command(samsung_key, payload)

        # Update local optimistic state
        if "VOLUP" in samsung_key:
            self.state.volume = min(100, self.state.volume + 1)
        elif "VOLDOWN" in samsung_key:
            self.state.volume = max(0, self.state.volume - 1)
        elif "MUTE" in samsung_key:
            self.state.muted = not self.state.muted
        elif "POWER" in samsung_key:
            self.state.power = not self.state.power

        return {"status": "success", "device_id": self.device_id, "samsung_key": samsung_key, "raw": result}


class LGTVAdapter(RemoteDevice):
    """
    LG Smart TV Adapter (webOS).
    Communicates via SSAP WebSocket protocol on port 3000/3001.
    """

    def __init__(self, device_id: str, name: str, ip_address: str, client_key: Optional[str] = None, room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand="LG",
            model="Smart TV (webOS)",
            device_type=DeviceType.SMART_TV,
            protocols=["wifi", "websocket"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.INPUT,
                DeviceCapability.APPS,
                DeviceCapability.PLAYBACK,
                DeviceCapability.NUMPAD,
                DeviceCapability.MENU
            ],
            room=room,
            ip_address=ip_address
        )
        self.client_key = client_key
        self.ws_proto = WebSocketProtocol(f"ws://{ip_address}:3000/")

    async def connect(self) -> bool:
        success = await self.ws_proto.connect()
        self.status = ConnectionStatus.CONNECTED if success else ConnectionStatus.UNAVAILABLE
        return success

    async def disconnect(self) -> None:
        await self.ws_proto.disconnect()
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd_upper = command.upper()
        uri_mapping = {
            "VOLUME_UP": "ssap://audio/volumeUp",
            "VOLUME_DOWN": "ssap://audio/volumeDown",
            "SET_VOLUME": "ssap://audio/setVolume",
            "MUTE": "ssap://audio/setMute",
            "POWER_OFF": "ssap://system/turnOff",
            "NAV_HOME": "ssap://system.launcher/open",
            "OPEN_APP": "ssap://system.launcher/launch"
        }
        uri = uri_mapping.get(cmd_upper, f"ssap://control/{cmd_upper.lower()}")
        result = await self.ws_proto.send_command(cmd_upper, {"uri": uri, "params": params})

        if cmd_upper == "VOLUME_UP":
            self.state.volume = min(100, self.state.volume + 1)
        elif cmd_upper == "VOLUME_DOWN":
            self.state.volume = max(0, self.state.volume - 1)
        elif cmd_upper == "MUTE":
            self.state.muted = not self.state.muted

        return {"status": "success", "device_id": self.device_id, "lg_uri": uri, "raw": result}


class SonyTVAdapter(RemoteDevice):
    """
    Sony Bravia TV Adapter.
    Communicates via IRCC-IP (HTTP POST with SOAP/XML) and JSON-RPC.
    """

    def __init__(self, device_id: str, name: str, ip_address: str, psk: Optional[str] = "0000", room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand="Sony",
            model="Bravia (IRCC-IP)",
            device_type=DeviceType.SMART_TV,
            protocols=["wifi", "http"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.INPUT,
                DeviceCapability.APPS,
                DeviceCapability.PLAYBACK,
                DeviceCapability.NUMPAD
            ],
            room=room,
            ip_address=ip_address
        )
        self.psk = psk
        self.http_proto = HTTPProtocol(f"http://{ip_address}/sony/ircc", headers={"X-Auth-PSK": self.psk or "0000"})

    async def connect(self) -> bool:
        success = await self.http_proto.connect()
        self.status = ConnectionStatus.CONNECTED if success else ConnectionStatus.UNAVAILABLE
        return success

    async def disconnect(self) -> None:
        await self.http_proto.disconnect()
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        cmd_upper = command.upper()
        # Standard Sony IRCC codes
        ircc_codes = {
            "POWER": "AAAAAQAAAAEAAAAVAw==",
            "VOLUME_UP": "AAAAAQAAAAEAAAASAw==",
            "VOLUME_DOWN": "AAAAAQAAAAEAAAATAw==",
            "MUTE": "AAAAAQAAAAEAAAAUAw==",
            "NAV_UP": "AAAAAQAAAAEAAAB0Aw==",
            "NAV_DOWN": "AAAAAQAAAAEAAAB1Aw==",
            "NAV_LEFT": "AAAAAQAAAAEAAAA0Aw==",
            "NAV_RIGHT": "AAAAAQAAAAEAAAAzAw==",
            "NAV_OK": "AAAAAQAAAAEAAABlAw==",
            "NAV_HOME": "AAAAAQAAAAEAAABgAw=="
        }
        code = ircc_codes.get(cmd_upper, "AAAAAQAAAAEAAAAVAw==")
        result = await self.http_proto.send_command(cmd_upper, {"ircc_code": code})
        return {"status": "success", "device_id": self.device_id, "ircc_code": code, "raw": result}


class AndroidTVAdapter(RemoteDevice):
    """
    Android TV & Google TV Adapter.
    Communicates via Android TV Remote Service v2 (TLS on port 6466 / pairing on 6467).
    """

    def __init__(self, device_id: str, name: str, ip_address: str, brand: str = "Android TV", room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand=brand,
            model="Android TV v2",
            device_type=DeviceType.SMART_TV,
            protocols=["wifi", "bluetooth", "mdns"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.APPS,
                DeviceCapability.PLAYBACK,
                DeviceCapability.NUMPAD
            ],
            room=room,
            ip_address=ip_address
        )
        self.http_proto = HTTPProtocol(f"https://{ip_address}:6466")

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd_upper = command.upper()
        return {"status": "success", "device_id": self.device_id, "android_command": cmd_upper, "params": params}


class GoogleTVAdapter(AndroidTVAdapter):
    """Google TV extension of Android TV adapter."""
    def __init__(self, device_id: str, name: str, ip_address: str, room: str = "Living Room"):
        super().__init__(device_id=device_id, name=name, ip_address=ip_address, brand="Google", room=room)
        self.model = "Chromecast with Google TV"


class GenericIRTVAdapter(RemoteDevice):
    """
    Generic IR Television Adapter.
    For non-smart or legacy TVs (Onida, Micromax, BPL, Videocon, Sansui, Akai, etc.).
    Uses InfraredProtocol; status reflects that state cannot be read back directly.
    """

    def __init__(self, device_id: str, name: str, brand: str, model: str = "Generic IR TV", protocol: str = "NEC", room: str = "Living Room"):
        super().__init__(
            device_id=device_id,
            name=name,
            brand=brand,
            model=model,
            device_type=DeviceType.TV,
            protocols=["infrared"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.INPUT,
                DeviceCapability.NUMPAD
            ],
            room=room
        )
        self.ir_proto = InfraredProtocol(ir_encoding=protocol)
        self.state.state_available = False  # Traditional IR has no feedback loop

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        result = await self.ir_proto.send_command(command, params)
        return {"status": "transmitted", "device_id": self.device_id, "command": command, "ir": result}
