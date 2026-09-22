"""
Mock Device Simulators
Provides fully interactive MockTV, MockSetTopBox, and MockStreamingDevice instances.
Maintains state internally to enable realistic UI testing, AI command verification, and scene execution.
"""

from typing import Dict, Any, Optional, List
from .base import RemoteDevice, DeviceType, DeviceCapability, ConnectionStatus, DeviceState


class MockTV(RemoteDevice):
    """Simulates a modern Smart TV (Samsung/LG/Sony/Android TV)."""

    def __init__(
        self,
        device_id: str = "demo_samsung_tv",
        name: str = "Demo Samsung QLED TV",
        brand: str = "Samsung",
        model: str = "QA55Q60R",
        room: str = "Living Room",
        ip_address: str = "192.168.1.101"
    ):
        super().__init__(
            device_id=device_id,
            name=name,
            brand=brand,
            model=model,
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
        self.state.power = True
        self.state.volume = 20
        self.state.input = "HDMI 1"
        self.state.application = "Home"

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd = command.upper()

        if cmd == "POWER" or cmd == "KEY_POWER":
            self.state.power = not self.state.power
            action_desc = f"Power toggled to {'ON' if self.state.power else 'OFF'}"
        elif cmd in ["POWER_ON", "KEY_POWERON"]:
            self.state.power = True
            action_desc = "Power set to ON"
        elif cmd in ["POWER_OFF", "KEY_POWEROFF"]:
            self.state.power = False
            action_desc = "Power set to OFF"
        elif cmd in ["VOLUME_UP", "KEY_VOLUP"]:
            self.state.volume = min(100, self.state.volume + 1)
            self.state.muted = False
            action_desc = f"Volume increased to {self.state.volume}"
        elif cmd in ["VOLUME_DOWN", "KEY_VOLDOWN"]:
            self.state.volume = max(0, self.state.volume - 1)
            self.state.muted = False
            action_desc = f"Volume decreased to {self.state.volume}"
        elif cmd == "SET_VOLUME":
            val = int(params.get("value", self.state.volume))
            self.state.volume = max(0, min(100, val))
            self.state.muted = False
            action_desc = f"Volume set to {self.state.volume}"
        elif cmd in ["MUTE", "KEY_MUTE"]:
            self.state.muted = not self.state.muted
            action_desc = f"Audio {'Muted' if self.state.muted else 'Unmuted'}"
        elif cmd in ["INPUT", "SET_INPUT"]:
            source = params.get("source", params.get("input", "HDMI 1"))
            self.state.input = source
            action_desc = f"Input switched to {source}"
        elif cmd in ["APP", "OPEN_APP", "APPLICATION"]:
            app_name = params.get("app", params.get("application", "YouTube"))
            self.state.application = app_name
            action_desc = f"Opened application {app_name}"
        elif cmd in ["NAV_UP", "KEY_UP"]:
            action_desc = "Navigated Up"
        elif cmd in ["NAV_DOWN", "KEY_DOWN"]:
            action_desc = "Navigated Down"
        elif cmd in ["NAV_LEFT", "KEY_LEFT"]:
            action_desc = "Navigated Left"
        elif cmd in ["NAV_RIGHT", "KEY_RIGHT"]:
            action_desc = "Navigated Right"
        elif cmd in ["NAV_OK", "KEY_ENTER", "KEY_OK"]:
            action_desc = "Pressed OK / Select"
        elif cmd in ["NAV_HOME", "KEY_HOME"]:
            self.state.application = "Home"
            action_desc = "Returned to Home Screen"
        elif cmd in ["NAV_BACK", "KEY_BACK"]:
            action_desc = "Navigated Back"
        else:
            action_desc = f"Executed {cmd}"

        return {
            "status": "success",
            "device_id": self.device_id,
            "command": cmd,
            "description": action_desc,
            "new_state": self.state.model_dump()
        }


class MockSetTopBox(RemoteDevice):
    """Simulates an Indian DTH Set-Top Box (Tata Play, Airtel Digital TV, Dish TV)."""

    def __init__(
        self,
        device_id: str = "demo_tataplay_stb",
        name: str = "Demo Tata Play HD STB",
        brand: str = "Tata Play",
        model: str = "Binge+ HD",
        room: str = "Living Room",
        ip_address: str = "192.168.1.102"
    ):
        super().__init__(
            device_id=device_id,
            name=name,
            brand=brand,
            model=model,
            device_type=DeviceType.SET_TOP_BOX,
            protocols=["infrared", "wifi"],
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
        self.state.power = True
        self.state.channel = "405"  # Star Sports 1 HD
        self.last_channel = "101"

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd = command.upper()

        if cmd in ["POWER", "KEY_POWER"]:
            self.state.power = not self.state.power
            action_desc = f"STB Power toggled to {'ON' if self.state.power else 'OFF'}"
        elif cmd in ["POWER_ON", "KEY_POWERON"]:
            self.state.power = True
            action_desc = "STB Power set to ON"
        elif cmd in ["POWER_OFF", "KEY_POWEROFF"]:
            self.state.power = False
            action_desc = "STB Power set to OFF"
        elif cmd in ["CHANNEL_UP", "KEY_CHUP"]:
            try:
                curr = int(self.state.channel)
                self.last_channel = self.state.channel
                self.state.channel = str(curr + 1)
            except ValueError:
                self.state.channel = "102"
            action_desc = f"Channel tuned to {self.state.channel}"
        elif cmd in ["CHANNEL_DOWN", "KEY_CHDOWN"]:
            try:
                curr = int(self.state.channel)
                self.last_channel = self.state.channel
                self.state.channel = str(max(1, curr - 1))
            except ValueError:
                self.state.channel = "100"
            action_desc = f"Channel tuned to {self.state.channel}"
        elif cmd in ["SET_CHANNEL", "CHANGE_CHANNEL"]:
            ch = str(params.get("channel", params.get("value", "101")))
            self.last_channel = self.state.channel
            self.state.channel = ch
            action_desc = f"Directly tuned channel to {ch}"
        elif cmd in ["LAST_CHANNEL", "KEY_LAST"]:
            temp = self.state.channel
            self.state.channel = self.last_channel
            self.last_channel = temp
            action_desc = f"Switched to last channel {self.state.channel}"
        elif cmd in ["GUIDE", "KEY_GUIDE"]:
            action_desc = "Opened TV Guide / EPG"
        elif cmd in ["INFO", "KEY_INFO"]:
            action_desc = "Displaying Program Info"
        elif cmd.startswith("KEY_COLOR_") or cmd in ["RED", "GREEN", "YELLOW", "BLUE"]:
            color = cmd.replace("KEY_COLOR_", "").capitalize()
            action_desc = f"Pressed Interactive {color} Key"
        else:
            action_desc = f"Executed STB command {cmd}"

        return {
            "status": "success",
            "device_id": self.device_id,
            "command": cmd,
            "description": action_desc,
            "new_state": self.state.model_dump()
        }


class MockStreamingDevice(RemoteDevice):
    """Simulates an Android TV / Google TV / Fire TV Stick."""

    def __init__(
        self,
        device_id: str = "demo_android_tv",
        name: str = "Demo Android TV Stick",
        brand: str = "Google",
        model: str = "Chromecast with Google TV",
        room: str = "Bedroom",
        ip_address: str = "192.168.1.103"
    ):
        super().__init__(
            device_id=device_id,
            name=name,
            brand=brand,
            model=model,
            device_type=DeviceType.STREAMING_DEVICE,
            protocols=["wifi", "bluetooth", "mdns"],
            capabilities=[
                DeviceCapability.POWER,
                DeviceCapability.VOLUME,
                DeviceCapability.MUTE,
                DeviceCapability.NAVIGATION,
                DeviceCapability.APPS,
                DeviceCapability.PLAYBACK,
                DeviceCapability.HOME,
                DeviceCapability.BACK
            ],
            room=room,
            ip_address=ip_address
        )
        self.state.power = True
        self.state.application = "Netflix"

    async def connect(self) -> bool:
        self.status = ConnectionStatus.CONNECTED
        return True

    async def disconnect(self) -> None:
        self.status = ConnectionStatus.DISCONNECTED

    async def execute(self, command: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        params = params or {}
        cmd = command.upper()
        if cmd == "OPEN_APP":
            app_name = params.get("app", "Netflix")
            self.state.application = app_name
            action_desc = f"Launched {app_name}"
        else:
            action_desc = f"Streaming device action {cmd}"

        return {
            "status": "success",
            "device_id": self.device_id,
            "command": cmd,
            "description": action_desc,
            "new_state": self.state.model_dump()
        }
