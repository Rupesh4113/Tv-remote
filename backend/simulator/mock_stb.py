"""
Mock Indian Set-Top Box Simulator (Tata Play, Airtel Digital TV, Dish TV)
Listens for simulated network or bridge commands and tracks STB state (channel, volume, guide).
"""

import logging
from aiohttp import web

logger = logging.getLogger("MockSTB")


class MockSTB:
    def __init__(self, provider: str = "Tata Play"):
        self.provider = provider
        self.channel = 100
        self.channel_name = "Star Plus HD"
        self.volume = 18
        self.power = True
        self.app = web.Application()
        self.app.router.add_post("/stb/command", self.command_handler)
        self.app.router.add_get("/stb/status", self.status_handler)
        self.command_history: list = []

    async def status_handler(self, request: web.Request) -> web.Response:
        return web.json_response({
            "provider": self.provider,
            "power": self.power,
            "current_channel": self.channel,
            "channel_name": self.channel_name,
            "volume": self.volume,
            "recent_commands": self.command_history[-10:]
        })

    async def command_handler(self, request: web.Request) -> web.Response:
        data = await request.json()
        cmd = data.get("command", "")
        self.command_history.append(cmd)
        logger.info("[Mock STB: %s] Received command: %s", self.provider, cmd)

        if cmd == "CHANNEL_UP":
            self.channel += 1
        elif cmd == "CHANNEL_DOWN":
            self.channel = max(1, self.channel - 1)
        elif cmd.startswith("NUM_"):
            num = cmd.replace("NUM_", "")
            self.channel = int(f"{self.channel}{num}"[-3:])
        elif cmd == "VOLUME_UP":
            self.volume = min(30, self.volume + 1)
        elif cmd == "VOLUME_DOWN":
            self.volume = max(0, self.volume - 1)
        elif cmd == "POWER":
            self.power = not self.power

        return web.json_response({
            "status": "success",
            "provider": self.provider,
            "channel": self.channel,
            "volume": self.volume,
            "power": self.power
        })


def create_app(provider: str = "Tata Play") -> web.Application:
    stb = MockSTB(provider=provider)
    return stb.app


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    web.run_app(create_app("Tata Play"), port=8084)
