"""
Unit Tests for Device Adapters
Verifies initialization, command execution, and live state updates across adapters and mock devices.
"""

import pytest
import asyncio
from backend.devices.mock_devices import MockTV, MockSetTopBox, MockStreamingDevice
from backend.devices.tv_adapters import (
    SamsungTVAdapter, LGTVAdapter, SonyTVAdapter, AndroidTVAdapter, GenericIRTVAdapter
)
from backend.devices.stb_adapters import TataPlayAdapter, AirtelDTHAdapter
from backend.devices.manager import DeviceManager


@pytest.mark.asyncio
async def test_mock_tv_state_transitions():
    tv = MockTV()
    assert tv.get_state().power is True

    # Test Power Toggle
    await tv.execute("POWER")
    assert tv.get_state().power is False
    await tv.execute("POWER")
    assert tv.get_state().power is True

    # Test Volume
    await tv.execute("SET_VOLUME", {"value": 25})
    assert tv.get_state().volume == 25
    await tv.execute("VOLUME_UP")
    assert tv.get_state().volume == 26
    await tv.execute("VOLUME_DOWN")
    assert tv.get_state().volume == 25

    # Test Mute
    await tv.execute("MUTE")
    assert tv.get_state().muted is True
    await tv.execute("MUTE")
    assert tv.get_state().muted is False

    # Test Input & App
    await tv.execute("SET_INPUT", {"source": "HDMI 2"})
    assert tv.get_state().input == "HDMI 2"
    await tv.execute("OPEN_APP", {"app": "Netflix"})
    assert tv.get_state().application == "Netflix"


@pytest.mark.asyncio
async def test_mock_stb_channel_transitions():
    stb = MockSetTopBox()
    # Initial channel is 405 (Star Sports 1 HD)
    assert stb.get_state().channel == "405"

    await stb.execute("CHANNEL_UP")
    assert stb.get_state().channel == "406"

    await stb.execute("SET_CHANNEL", {"channel": "101"})
    assert stb.get_state().channel == "101"

    await stb.execute("LAST_CHANNEL")
    assert stb.get_state().channel == "406"


@pytest.mark.asyncio
async def test_samsung_adapter():
    samsung = SamsungTVAdapter(device_id="sam_01", name="Samsung TV", ip_address="192.168.1.50")
    connected = await samsung.connect()
    assert connected is True
    res = await samsung.execute("VOLUME_UP")
    assert res["status"] == "success"
    assert res["samsung_key"] == "KEY_VOLUP"


@pytest.mark.asyncio
async def test_lg_adapter():
    lg = LGTVAdapter(device_id="lg_01", name="LG TV", ip_address="192.168.1.51")
    connected = await lg.connect()
    assert connected is True
    res = await lg.execute("VOLUME_UP")
    assert res["status"] == "success"
    assert "ssap://" in res["lg_uri"]


@pytest.mark.asyncio
async def test_tata_play_adapter():
    tp = TataPlayAdapter(device_id="tp_01", name="Tata Play STB")
    connected = await tp.connect()
    assert connected is True
    res = await tp.execute("SET_CHANNEL", {"channel": "405"})
    assert res["status"] == "success"
    assert tp.get_state().channel == "405"


def test_device_manager():
    dm = DeviceManager()
    assert len(dm.list_devices()) >= 3
    assert dm.get_active_device() is not None

    rooms = dm.list_rooms()
    assert "Living Room" in rooms

    # Switch active device
    active_dev = dm.list_devices()[1]
    dm.set_active_device(active_dev.device_id)
    assert dm.get_active_device().device_id == active_dev.device_id
