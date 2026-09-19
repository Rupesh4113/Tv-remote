"""
Mock LG webOS TV Simulator
Implements SSAP WebSocket handshake, pairing confirmation, and command dispatcher.
"""

import json
import logging
from typing import Set
from aiohttp import web

logger = logging.getLogger("MockLGWebOS")


class MockLGWebOS:
    def __init__(self, port: int = 8082):
        self.port = port
        self.app = web.Application()
        self.app.router.add_get("/", self.ws_handler)
        self.app.router.add_get("/api/status", self.status_handler)
        self.active_sockets: Set[web.WebSocketResponse] = set()
        self.volume: int = 15
        self.muted: bool = False
        self.channel: int = 100
        self.power_state: bool = True
        self.command_history: list = []

    async def status_handler(self, request: web.Request) -> web.Response:
        return web.json_response({
            "device": "[Mock] LG OLED 4K TV (webOS 6.0)",
            "power": self.power_state,
            "volume": self.volume,
            "muted": self.muted,
            "channel": self.channel,
            "recent_commands": self.command_history[-10:]
        })

    async def ws_handler(self, request: web.Request) -> web.WebSocketResponse:
        ws = web.WebSocketResponse()
        await ws.prepare(request)
        self.active_sockets.add(ws)
        logger.info("LG webOS client connected from %s", request.remote)

        try:
            async for msg in ws:
                if msg.type == web.WSMsgType.TEXT:
                    try:
                        data = json.loads(msg.data)
                        msg_type = data.get("type")
                        req_id = data.get("id", "req_01")
                        uri = data.get("uri", "")

                        if msg_type == "register":
                            # Successful registration pairing handshake
                            resp = {
                                "type": "registered",
                                "id": req_id,
                                "payload": {
                                    "client-key": "mock-lg-client-key-554433"
                                }
                            }
                            await ws.send_str(json.dumps(resp))
                            logger.info("[Mock LG] Handshake registered with client-key")

                        elif msg_type == "request":
                            self.command_history.append(uri)
                            logger.info("[Mock LG] Request received: %s", uri)

                            if uri == "ssap://audio/volumeUp":
                                self.volume = min(100, self.volume + 1)
                            elif uri == "ssap://audio/volumeDown":
                                self.volume = max(0, self.volume - 1)
                            elif uri == "ssap://audio/setMute":
                                self.muted = data.get("payload", {}).get("mute", not self.muted)
                            elif uri == "ssap://tv/channelUp":
                                self.channel += 1
                            elif uri == "ssap://tv/channelDown":
                                self.channel = max(1, self.channel - 1)
                            elif uri == "ssap://system/turnOff":
                                self.power_state = False

                            resp = {
                                "type": "response",
                                "id": req_id,
                                "payload": {
                                    "returnValue": True,
                                    "volume": self.volume,
                                    "muted": self.muted,
                                    "channel": self.channel
                                }
                            }
                            await ws.send_str(json.dumps(resp))
                    except Exception as e:
                        logger.error("Error parsing LG command: %s", e)
        finally:
            self.active_sockets.discard(ws)
            logger.info("LG webOS client disconnected")

        return ws


def create_app(port: int = 8082) -> web.Application:
    tv = MockLGWebOS(port=port)
    return tv.app


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    web.run_app(create_app(8082), port=8082)
