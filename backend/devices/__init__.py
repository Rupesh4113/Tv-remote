"""
Devices Package
Universal Device Abstraction for AI Smart Remote
"""

from .base import RemoteDevice, DeviceState, DeviceCapability, DeviceType, ConnectionStatus
from .manager import DeviceManager
from .mock_devices import MockTV, MockSetTopBox, MockStreamingDevice
from .tv_adapters import (
    SamsungTVAdapter, LGTVAdapter, SonyTVAdapter,
    AndroidTVAdapter, GoogleTVAdapter, GenericIRTVAdapter
)
from .stb_adapters import (
    TataPlayAdapter, AirtelDTHAdapter, DishTVAdapter,
    VideoconD2HAdapter, GenericIRSTBAdapter
)

__all__ = [
    "RemoteDevice",
    "DeviceState",
    "DeviceCapability",
    "DeviceType",
    "ConnectionStatus",
    "DeviceManager",
    "MockTV",
    "MockSetTopBox",
    "MockStreamingDevice",
    "SamsungTVAdapter",
    "LGTVAdapter",
    "SonyTVAdapter",
    "AndroidTVAdapter",
    "GoogleTVAdapter",
    "GenericIRTVAdapter",
    "TataPlayAdapter",
    "AirtelDTHAdapter",
    "DishTVAdapter",
    "VideoconD2HAdapter",
    "GenericIRSTBAdapter"
]
