"""
Unit Tests for Smart Scene Engine
Verifies multi-device sequential scene execution, delays, and state transitions.
"""

import pytest
from backend.devices.manager import DeviceManager
from backend.services.scene_engine import SceneEngine


@pytest.mark.asyncio
async def test_movie_mode_scene_execution():
    dm = DeviceManager()
    se = SceneEngine(dm)

    scenes = se.list_scenes()
    scene_ids = [s.id for s in scenes]
    assert "movie_mode" in scene_ids
    assert "cricket_mode" in scene_ids
    assert "good_night" in scene_ids
    assert "gaming_mode" in scene_ids

    # Execute Movie Mode
    res = await se.execute_scene("movie_mode")
    assert res["status"] == "success"
    assert len(res["executed_steps"]) == 4

    # Verify TV state was updated
    tv = dm.get_device("demo_samsung_tv")
    assert tv.get_state().power is True
    assert tv.get_state().volume == 20
    assert tv.get_state().input == "HDMI 1"
    assert tv.get_state().application == "Netflix"


@pytest.mark.asyncio
async def test_cricket_mode_scene_execution():
    dm = DeviceManager()
    se = SceneEngine(dm)

    res = await se.execute_scene("cricket_mode")
    assert res["status"] == "success"
    assert len(res["executed_steps"]) == 4

    # Verify STB tuned to Star Sports (405)
    stb = dm.get_device("demo_tataplay_stb")
    assert stb.get_state().channel == "405"


@pytest.mark.asyncio
async def test_good_night_scene_execution():
    dm = DeviceManager()
    se = SceneEngine(dm)

    res = await se.execute_scene("good_night")
    assert res["status"] == "success"

    tv = dm.get_device("demo_samsung_tv")
    stb = dm.get_device("demo_tataplay_stb")
    assert tv.get_state().power is False
    assert stb.get_state().power is False
