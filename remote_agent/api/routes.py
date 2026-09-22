"""
Local Remote Agent REST & WebSocket API
Exposes local endpoints for Streamlit Cloud and LAN web clients to control devices,
run network discovery, execute scenes, and pair with authentication.
"""

from typing import Dict, Any, Optional, List
from fastapi import APIRouter, HTTPException, Header, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, Field
import time
import logging

from ..security.pairing import PairingManager
from ..discovery.scanner import NetworkScanner
from backend.devices.manager import DeviceManager
from backend.services.scene_engine import SceneEngine

logger = logging.getLogger("AgentAPI")

router = APIRouter()
pairing_mgr = PairingManager()
scanner = NetworkScanner()
device_manager = DeviceManager()
scene_engine = SceneEngine(device_manager)


# --- Request/Response Models ---
class CommandRequest(BaseModel):
    device_id: str
    command: str
    params: Optional[Dict[str, Any]] = Field(default_factory=dict)


class ConnectRequest(BaseModel):
    device_id: str
    brand: Optional[str] = None
    ip_address: Optional[str] = None


class PairRequest(BaseModel):
    client_name: str = "Streamlit-Web"


class VerifyPairRequest(BaseModel):
    code: str


class SceneExecuteRequest(BaseModel):
    scene_id: str


def verify_auth_or_local(authorization: Optional[str], host: Optional[str]):
    # Allow local development connections automatically
    if host in ["127.0.0.1", "localhost"]:
        return True
    if not authorization:
        # Check if any tokens exist yet; if fresh setup, allow until paired
        if not pairing_mgr.active_tokens:
            return True
        raise HTTPException(status_code=401, detail="Authentication token required.")
    token = authorization.replace("Bearer ", "").strip()
    if not pairing_mgr.validate_token(token):
        raise HTTPException(status_code=401, detail="Invalid or expired authentication token.")
    return True


@router.get("/health")
def health():
    return {
        "status": "healthy",
        "agent": "AI Smart Remote Local Agent",
        "version": "1.0.0",
        "timestamp": time.time(),
        "devices_count": len(device_manager.devices),
        "active_device": device_manager.active_device_id
    }


@router.get("/devices")
def list_devices():
    return [d.to_dict() for d in device_manager.list_devices()]


@router.post("/devices/discover")
async def discover_devices(timeout: float = 2.0):
    discovered = await scanner.scan(timeout=timeout)
    return {"status": "success", "count": len(discovered), "devices": discovered}


@router.post("/devices/connect")
async def connect_device(req: ConnectRequest):
    dev = device_manager.get_device(req.device_id)
    if not dev:
        raise HTTPException(status_code=404, detail=f"Device {req.device_id} not registered.")
    success = await dev.connect()
    return {"status": "connected" if success else "failed", "device": dev.to_dict()}


@router.post("/devices/disconnect")
async def disconnect_device(req: ConnectRequest):
    dev = device_manager.get_device(req.device_id)
    if not dev:
        raise HTTPException(status_code=404, detail=f"Device {req.device_id} not found.")
    await dev.disconnect()
    return {"status": "disconnected", "device": dev.to_dict()}


@router.post("/command")
async def execute_command(req: CommandRequest):
    res = await device_manager.execute_command(req.device_id, req.command, req.params)
    return res


@router.get("/device/{device_id}/state")
def get_device_state(device_id: str):
    dev = device_manager.get_device(device_id)
    if not dev:
        raise HTTPException(status_code=404, detail=f"Device {device_id} not found.")
    return {
        "device_id": device_id,
        "name": dev.name,
        "state": dev.get_state().model_dump(),
        "display": dev.get_state().to_display_dict()
    }


@router.post("/scene/execute")
async def execute_scene(req: SceneExecuteRequest):
    res = await scene_engine.execute_scene(req.scene_id)
    return res


@router.post("/pair/request")
def request_pairing_code(req: PairRequest):
    code = pairing_mgr.generate_pairing_code(client_name=req.client_name)
    return {
        "status": "pending",
        "pairing_code": code,
        "instructions": "Enter this 6-digit code in the Streamlit Cloud Security page to authorize connection.",
        "expires_in_seconds": pairing_mgr.code_expiry_seconds
    }


@router.post("/pair/verify")
def verify_pairing_code(req: VerifyPairRequest):
    token = pairing_mgr.verify_pairing_code(req.code)
    if not token:
        raise HTTPException(status_code=400, detail="Invalid or expired pairing code.")
    return {
        "status": "success",
        "token": token,
        "message": "Local Remote Agent successfully paired with client."
    }
