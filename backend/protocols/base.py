"""
Universal Remote Protocol Abstraction Layer
Defines protocol interfaces for communicating with TVs, Set-Top Boxes, and Audio Devices.
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from enum import Enum


class ProtocolType(str, Enum):
    WIFI = "wifi"
    BLUETOOTH = "bluetooth"
    BLE = "ble"
    INFRARED = "infrared"
    WEBSOCKET = "websocket"
    HTTP = "http"
    UPNP = "upnp"
    MDNS = "mdns"
    MANUFACTURER = "manufacturer"


class RemoteProtocol(ABC):
    """Base abstract protocol for device communication."""
    
    def __init__(self, name: str, protocol_type: ProtocolType, config: Optional[Dict[str, Any]] = None):
        self.name = name
        self.protocol_type = protocol_type
        self.config = config or {}
        self.is_connected = False

    @abstractmethod
    async def connect(self) -> bool:
        """Establish connection to device via this protocol."""
        pass

    @abstractmethod
    async def disconnect(self) -> None:
        """Close connection."""
        pass

    @abstractmethod
    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """Send a raw or formatted command over the protocol."""
        pass

    def get_info(self) -> Dict[str, Any]:
        return {
            "name": self.name,
            "type": self.protocol_type.value,
            "connected": self.is_connected,
            "config": {k: v for k, v in self.config.items() if "secret" not in k and "password" not in k}
        }


class WiFiProtocol(RemoteProtocol):
    def __init__(self, ip: str, port: int, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"WiFi-{ip}:{port}", protocol_type=ProtocolType.WIFI, config=config)
        self.ip = ip
        self.port = port

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {"protocol": "wifi", "status": "sent", "command": command, "ip": self.ip, "port": self.port}


class WebSocketProtocol(RemoteProtocol):
    def __init__(self, ws_url: str, token: Optional[str] = None, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"WebSocket-{ws_url}", protocol_type=ProtocolType.WEBSOCKET, config=config)
        self.ws_url = ws_url
        self.token = token

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {"protocol": "websocket", "status": "sent", "command": command, "url": self.ws_url}


class HTTPProtocol(RemoteProtocol):
    def __init__(self, base_url: str, headers: Optional[Dict[str, str]] = None, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"HTTP-{base_url}", protocol_type=ProtocolType.HTTP, config=config)
        self.base_url = base_url
        self.headers = headers or {}

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {"protocol": "http", "status": "sent", "command": command, "base_url": self.base_url}


class BluetoothProtocol(RemoteProtocol):
    def __init__(self, mac_address: str, service_uuid: Optional[str] = None, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"Bluetooth-{mac_address}", protocol_type=ProtocolType.BLUETOOTH, config=config)
        self.mac_address = mac_address
        self.service_uuid = service_uuid

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {"protocol": "bluetooth", "status": "sent", "command": command, "mac": self.mac_address}


class BLEProtocol(RemoteProtocol):
    def __init__(self, ble_address: str, characteristic_uuid: Optional[str] = None, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"BLE-{ble_address}", protocol_type=ProtocolType.BLE, config=config)
        self.ble_address = ble_address
        self.characteristic_uuid = characteristic_uuid

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {"protocol": "ble", "status": "sent", "command": command, "address": self.ble_address}


class InfraredProtocol(RemoteProtocol):
    def __init__(self, ir_encoding: str = "NEC", carrier_frequency: int = 38000, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"IR-{ir_encoding}", protocol_type=ProtocolType.INFRARED, config=config)
        self.ir_encoding = ir_encoding
        self.carrier_frequency = carrier_frequency

    async def connect(self) -> bool:
        # IR is stateless, connection represents transmitter readiness
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {
            "protocol": "infrared",
            "status": "transmitted",
            "command": command,
            "encoding": self.ir_encoding,
            "frequency_hz": self.carrier_frequency
        }


class UPnPProtocol(RemoteProtocol):
    def __init__(self, control_url: str, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"UPnP-{control_url}", protocol_type=ProtocolType.UPNP, config=config)
        self.control_url = control_url

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {"protocol": "upnp", "status": "sent", "command": command, "control_url": self.control_url}


class mDNSProtocol(RemoteProtocol):
    def __init__(self, service_name: str, host: str, port: int, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"mDNS-{service_name}", protocol_type=ProtocolType.MDNS, config=config)
        self.service_name = service_name
        self.host = host
        self.port = port

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {"protocol": "mdns", "status": "resolved", "command": command, "host": self.host, "port": self.port}


class ManufacturerProtocol(RemoteProtocol):
    def __init__(self, manufacturer: str, api_version: str, config: Optional[Dict[str, Any]] = None):
        super().__init__(name=f"Manufacturer-{manufacturer}-{api_version}", protocol_type=ProtocolType.MANUFACTURER, config=config)
        self.manufacturer = manufacturer
        self.api_version = api_version

    async def connect(self) -> bool:
        self.is_connected = True
        return True

    async def disconnect(self) -> None:
        self.is_connected = False

    async def send_command(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        return {
            "protocol": "manufacturer",
            "status": "sent",
            "manufacturer": self.manufacturer,
            "version": self.api_version,
            "command": command
        }
