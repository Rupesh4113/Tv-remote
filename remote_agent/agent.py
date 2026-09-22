"""
AI Smart Remote — Local Remote Agent Daemon
Runs on Windows / macOS / Linux to bridge local LAN TVs and STBs with Streamlit Cloud.
"""

import sys
import argparse
import logging
from pathlib import Path
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
import uvicorn

# Ensure project root is in sys.path
PROJECT_ROOT = Path(__file__).resolve().parent.parent
if str(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(PROJECT_ROOT))

from remote_agent.api.routes import router, device_manager

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s"
)
logger = logging.getLogger("LocalRemoteAgent")

app = FastAPI(
    title="AI Smart Remote — Local Remote Agent",
    description="Bridge connecting Streamlit Cloud & local browsers to LAN TVs, STBs, and IR Blasters",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router, prefix="/api/v1")


@app.get("/")
def index():
    return {
        "agent": "AI Smart Remote Local Agent",
        "tagline": "One Remote. Every Screen. Powered by AI.",
        "status": "online",
        "docs_url": "/docs",
        "devices_online": len(device_manager.devices)
    }


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """Real-time bi-directional command channel for low latency control."""
    await websocket.accept()
    logger.info("WebSocket client connected to Local Remote Agent")
    try:
        while True:
            data = await websocket.receive_json()
            cmd_type = data.get("type", "command")
            if cmd_type == "ping":
                await websocket.send_json({"type": "pong", "time": data.get("time")})
            elif cmd_type == "command":
                dev_id = data.get("device_id")
                command = data.get("command")
                params = data.get("params", {})
                res = await device_manager.execute_command(dev_id, command, params)
                await websocket.send_json({"type": "command_result", "data": res})
            elif cmd_type == "get_state":
                dev_id = data.get("device_id")
                dev = device_manager.get_device(dev_id)
                if dev:
                    await websocket.send_json({"type": "state", "data": dev.get_state().model_dump()})
    except WebSocketDisconnect:
        logger.info("WebSocket client disconnected")
    except Exception as e:
        logger.error("WebSocket error: %s", e)


def main():
    parser = argparse.ArgumentParser(description="AI Smart Remote Local Agent")
    parser.add_argument("--host", default="0.0.0.0", help="Binding host (default 0.0.0.0)")
    parser.add_argument("--port", type=int, default=8765, help="Port to listen on (default 8765)")
    args = parser.parse_args()

    print("\n" + "="*60)
    print("  🚀 AI SMART REMOTE — LOCAL REMOTE AGENT")
    print("  'One Remote. Every Screen. Powered by AI.'")
    print(f"  Listening on http://{args.host}:{args.port}")
    print(f"  API Docs:     http://localhost:{args.port}/docs")
    print(f"  WebSocket:    ws://localhost:{args.port}/ws")
    print("="*60 + "\n")

    uvicorn.run(app, host=args.host, port=args.port, log_level="info")


if __name__ == "__main__":
    main()
