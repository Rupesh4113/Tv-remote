"""
Pydantic Schemas for RemoteOne Backend
"""

from typing import List, Dict, Optional, Any
from pydantic import BaseModel, Field


class CommandItem(BaseModel):
    label: Optional[str] = None
    ir_hex: Optional[str] = None
    ir_pattern: Optional[List[int]] = None
    wifi_payload: Optional[Dict[str, Any]] = None
    ble_bytes: Optional[str] = None


class DeviceProfileSummary(BaseModel):
    id: str
    brand: str
    category: str
    model: str
    region: str
    version: str
    supported_transports: List[str]


class DeviceProfileDetail(DeviceProfileSummary):
    ir_config: Optional[Dict[str, Any]] = None
    wifi_config: Optional[Dict[str, Any]] = None
    bluetooth_config: Optional[Dict[str, Any]] = None
    commands: Dict[str, CommandItem] = Field(default_factory=dict)


class BackupData(BaseModel):
    user_id: str
    timestamp: str
    devices: List[Dict[str, Any]]
    macros: List[Dict[str, Any]] = Field(default_factory=list)
    learned_commands: List[Dict[str, Any]] = Field(default_factory=list)


class BackupResponse(BaseModel):
    status: str
    backup_id: str
    message: str


class HealthResponse(BaseModel):
    status: str
    version: str
    profiles_count: int
