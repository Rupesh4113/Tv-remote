"""
Mock Device Suite Orchestrator
Spawns Mock Samsung TV (8081), Mock LG webOS (8082), Mock Sony Bravia (8083), and Mock Tata Play STB (8084).
Provides a unified dashboard and test endpoint on port 8080.
"""

import asyncio
import logging
from aiohttp import web
from .mock_samsung_tv import MockSamsungTV
from .mock_lg_tv import MockLGWebOS
from .mock_sony_bravia import MockSonyBravia
from .mock_stb import MockSTB

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("SimulatorRunner")


async def dashboard_handler(request: web.Request) -> web.Response:
    return web.json_response({
        "status": "online",
        "mock_devices": [
            {
                "name": "Samsung Smart TV",
                "transport": "WIFI (Tizen WebSocket)",
                "port": 8081,
                "endpoint": "ws://localhost:8081/api/v2/channels/samsung.remote.control"
            },
            {
                "name": "LG webOS OLED TV",
                "transport": "WIFI (SSAP WebSocket)",
                "port": 8082,
                "endpoint": "ws://localhost:8082/"
            },
            {
                "name": "Sony Bravia 4K TV",
                "transport": "WIFI (IRCC-IP HTTP)",
                "port": 8083,
                "endpoint": "http://localhost:8083/sony/ircc",
                "auth_psk": "0000"
            },
            {
                "name": "Tata Play HD Set-Top Box",
                "transport": "IP Bridge / IR Simulation",
                "port": 8084,
                "endpoint": "http://localhost:8084/stb/command"
            }
        ]
    })


async def start_all_simulators():
    samsung_app = MockSamsungTV(8081).app
    lg_app = MockLGWebOS(8082).app
    sony_app = MockSonyBravia(psk="0000").app
    stb_app = MockSTB(provider="Tata Play").app

    dashboard_app = web.Application()
    dashboard_app.router.add_get("/", dashboard_handler)
    dashboard_app.router.add_get("/api/devices", dashboard_handler)

    runners = []
    ports = [(samsung_app, 8081), (lg_app, 8082), (sony_app, 8083), (stb_app, 8084), (dashboard_app, 8080)]

    for app, port in ports:
        runner = web.AppRunner(app)
        await runner.setup()
        site = web.TCPSite(runner, "0.0.0.0", port)
        await site.start()
        runners.append(runner)
        logger.info("Simulator running on http://localhost:%d", port)

    logger.info("All 4 Mock Devices + Dashboard are active! Press Ctrl+C to terminate.")
    try:
        while True:
            await asyncio.sleep(3600)
    except (KeyboardInterrupt, asyncio.CancelledError):
        for runner in runners:
            await runner.cleanup()
        logger.info("Simulators shutdown.")


if __name__ == "__main__":
    asyncio.run(start_all_simulators())
