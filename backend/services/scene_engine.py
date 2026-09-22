"""
Smart Scene Engine
Manages and sequentially executes multi-device automation scenes:
- Movie Mode
- Cricket Mode
- Good Night
- Gaming Mode
- Custom user-created scenes
"""

from typing import List, Dict, Any, Optional
import asyncio
import time
import logging
from pydantic import BaseModel, Field
from ..devices.manager import DeviceManager

logger = logging.getLogger("SceneEngine")


class SceneStep(BaseModel):
    """Single action step in a scene."""
    target_type: str = Field(description="tv, stb, audio, or specific device_id")
    command: str = Field(description="Remote command e.g. POWER_ON, SET_INPUT, SET_VOLUME")
    params: Dict[str, Any] = Field(default_factory=dict)
    delay_seconds: float = Field(default=0.5, description="Wait time before next step")
    description: str


class Scene(BaseModel):
    """Definition of a Smart Scene."""
    id: str
    name: str
    icon: str = "🎬"
    description: str
    steps: List[SceneStep]


class SceneEngine:
    """Executes multi-device automation scenes sequentially with real-time logging."""

    def __init__(self, device_manager: DeviceManager):
        self.device_manager = device_manager
        self.scenes: Dict[str, Scene] = {}
        self._init_default_scenes()

    def _init_default_scenes(self):
        # 1. Movie Mode
        movie_mode = Scene(
            id="movie_mode",
            name="Movie Mode",
            icon="🍿",
            description="Turns on TV, switches to HDMI 1, sets volume to 20, launches Netflix.",
            steps=[
                SceneStep(target_type="tv", command="POWER_ON", description="1. Turn on TV", delay_seconds=0.3),
                SceneStep(target_type="tv", command="SET_INPUT", params={"source": "HDMI 1"}, description="2. Switch to HDMI 1", delay_seconds=0.3),
                SceneStep(target_type="tv", command="SET_VOLUME", params={"value": 20}, description="3. Set volume to 20", delay_seconds=0.2),
                SceneStep(target_type="tv", command="OPEN_APP", params={"app": "Netflix"}, description="4. Launch Netflix", delay_seconds=0.1)
            ]
        )

        # 2. Cricket Mode
        cricket_mode = Scene(
            id="cricket_mode",
            name="Cricket Mode",
            icon="🏏",
            description="Powers on TV & Tata Play STB, tunes to Star Sports 1 HD (405), and sets volume to 25.",
            steps=[
                SceneStep(target_type="tv", command="POWER_ON", description="1. Turn on TV", delay_seconds=0.3),
                SceneStep(target_type="stb", command="POWER_ON", description="2. Turn on Set-Top Box", delay_seconds=0.3),
                SceneStep(target_type="stb", command="SET_CHANNEL", params={"channel": "405"}, description="3. Tune to Star Sports 1 HD (Ch 405)", delay_seconds=0.2),
                SceneStep(target_type="tv", command="SET_VOLUME", params={"value": 25}, description="4. Set volume to 25", delay_seconds=0.1)
            ]
        )

        # 3. Good Night
        good_night = Scene(
            id="good_night",
            name="Good Night",
            icon="🌙",
            description="Turns off all TVs, Set-Top Boxes, and audio systems.",
            steps=[
                SceneStep(target_type="tv", command="POWER_OFF", description="1. Power off TV", delay_seconds=0.2),
                SceneStep(target_type="stb", command="POWER_OFF", description="2. Power off Set-Top Box", delay_seconds=0.2)
            ]
        )

        # 4. Gaming Mode
        gaming_mode = Scene(
            id="gaming_mode",
            name="Gaming Mode",
            icon="🎮",
            description="Switches TV to HDMI 2 (Console), sets volume to 22.",
            steps=[
                SceneStep(target_type="tv", command="POWER_ON", description="1. Turn on TV", delay_seconds=0.3),
                SceneStep(target_type="tv", command="SET_INPUT", params={"source": "HDMI 2"}, description="2. Switch input to HDMI 2", delay_seconds=0.2),
                SceneStep(target_type="tv", command="SET_VOLUME", params={"value": 22}, description="3. Set volume to 22", delay_seconds=0.1)
            ]
        )

        self.register_scene(movie_mode)
        self.register_scene(cricket_mode)
        self.register_scene(good_night)
        self.register_scene(gaming_mode)

    def register_scene(self, scene: Scene):
        self.scenes[scene.id] = scene

    def get_scene(self, scene_id: str) -> Optional[Scene]:
        return self.scenes.get(scene_id)

    def list_scenes(self) -> List[Scene]:
        return list(self.scenes.values())

    async def execute_scene(self, scene_id: str) -> Dict[str, Any]:
        """Executes scene steps sequentially across target devices."""
        scene = self.get_scene(scene_id)
        if not scene:
            # Try fuzzy matching by name
            for s in self.scenes.values():
                if s.name.lower() == scene_id.lower() or s.id.lower() == scene_id.lower():
                    scene = s
                    break

        if not scene:
            return {"status": "error", "error": f"Scene '{scene_id}' not found."}

        logs = []
        start_time = time.time()

        for step in scene.steps:
            target_device = None
            # Resolve target device
            if step.target_type == "tv":
                for d in self.device_manager.devices.values():
                    if d.device_type.value in ["smart_tv", "tv"]:
                        target_device = d
                        break
            elif step.target_type == "stb":
                for d in self.device_manager.devices.values():
                    if d.device_type.value == "set_top_box":
                        target_device = d
                        break
            else:
                target_device = self.device_manager.get_device(step.target_type)

            if not target_device:
                target_device = self.device_manager.get_active_device()

            if target_device:
                res = await target_device.execute(step.command, step.params)
                logs.append({
                    "step": step.description,
                    "target": target_device.name,
                    "status": "success",
                    "result": res
                })
            else:
                logs.append({
                    "step": step.description,
                    "target": "None",
                    "status": "skipped",
                    "reason": f"No available device found for {step.target_type}"
                })

            if step.delay_seconds > 0:
                await asyncio.sleep(step.delay_seconds)

        duration = round(time.time() - start_time, 2)
        return {
            "status": "success",
            "scene_id": scene.id,
            "scene_name": scene.name,
            "duration_seconds": duration,
            "executed_steps": logs
        }
