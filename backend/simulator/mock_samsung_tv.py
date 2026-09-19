"""
Mock Samsung Tizen Smart TV Simulator
Implements WebSocket server emulating Samsung Tizen Remote Control Channel (port 8002/8081).
"""

import json
import logging
from typing import Set
from aiohttp import web

logger = logging.getLogger("MockSamsungTV")


class MockSamsungTV:
    def __init__(self, port: int = 8081):
        self.port = port
        self.app = web.Application()
        self.app.router.add_get("/api/v2/channels/samsung.remote.control", self.ws_handler)
        self.app.router.add_get("/api/v2/", self.info_handler)
        self.active_sockets: Set[web.WebSocketResponse] = set()
        self.last_command: str = ""
        self.command_history: list = []

    async def info_handler(self, request: web.Request) -> web.Response:
        return web.json_response({
            "device": {
                "name": "[Mock] Samsung QLED 4K TV",
                "modelName": "QA55Q60RAKXXL",
                "networkType": "wireless",
                "wifiMac": "00:11:22:33:44:55"
            }
        })

    async def ws_handler(self, request: web.Request) -> web.WebSocketResponse:
        ws = web.WebSocketResponse()
        await ws.prepare(request)
        self.active_sockets.add(ws)
        logger.info("Samsung TV client connected: %s", request.remote)

        # Send connection confirmation event with mock token
        welcome_event = {
            "event": "ms.channel.connect",
            "data": {
                "token": "mock-samsung-token-998877",
                "clients": [{"attributes": {"name": "RemoteOne"}}]
            }
        }
        await ws.send_str(json.dumps(welcome_event))

        try:
            async for msg in ws:
                if msg.type == web.WSMsgType.TEXT:
                    try:
                        data = json.loads(msg.data)
                        method = data.get("method")
                        if method == "ms.remote.control":
                            params = data.get("params", {})
                            cmd = params.get("DataOfCmd", "UNKNOWN")
                            self.last_command = cmd
                            self.command_history.append(cmd)
                            logger.info("[Mock Samsung TV] Received remote key: %s", cmd)
                            # Echo confirmation
                            await ws.send_str(json.dumps({
                                "event": "ms.remote.ack",
                                "data": {"key": cmd, "status": "success"}
                            }))
                    except Exception as e:
                        logger.error("Error parsing message: %s", e)
                elif msg.type == web.WSMsgType.ERROR:
                    logger.warning("WebSocket error: %s", ws.exception())
        finally:
            self.active_sockets.discard(ws)
            logger.info("Samsung TV client disconnected")

        return ws


def create_app(port: int = 8081) -> web.Application:
    tv = MockSamsungTV(port=port)
    return tv.app


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    web.run_app(create_app(8081), port=8081)
