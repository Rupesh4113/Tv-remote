"""
Remote Agent Devices
"""

from backend.devices.base import (
    RemoteDevice, DeviceState, DeviceCapability, DeviceType, ConnectionStatus
)
from backend.devices.manager import DeviceManager
from backend.devices.mock_devices import MockTV, MockSetTopBox, MockStreamingDevice
from backend.devices.tv_adapters import (
    SamsungTVAdapter, LGTVAdapter, SonyTVAdapter, AndroidTVAdapter,
    GoogleTVAdapter, GenericIRTVAdapter
)
from backend.devices.stb_adapters import (
    TataPlayAdapter, AirtelDTHAdapter, DishTVAdapter,
    VideoconD2HAdapter, GenericIRSTBAdapter
)

__all__ = [
    "RemoteDevice", "DeviceState", "DeviceCapability", "DeviceType",
    "ConnectionStatus", "DeviceManager", "MockTV", "MockSetTopBox",
    "MockStreamingDevice", "SamsungTVAdapter", "LGTVAdapter", "SonyTVAdapter",
    "AndroidTVAdapter", "GoogleTVAdapter", "GenericIRTVAdapter",
    "TataPlayAdapter", "AirtelDTHAdapter", "DishTVAdapter",
    "VideoconD2HAdapter", "GenericIRSTBAdapter"
]
