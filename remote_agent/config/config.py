"""
Local Remote Agent Configuration
"""

import os
from pydantic import BaseModel, Field


class AgentConfig(BaseModel):
    agent_name: str = Field(default="AI-Smart-Remote-Agent")
    port: int = Field(default=8765)
    host: str = Field(default="0.0.0.0")
    secret_key: str = Field(default_factory=lambda: os.getenv("REMOTE_AGENT_SECRET", "agent_default_secret_key_12345"))
    allow_unauthenticated_localhost: bool = Field(default=True)
    enable_ir: bool = Field(default=True)
    enable_mdns: bool = Field(default=True)
    enable_ssdp: bool = Field(default=True)
    pairing_code_expiry_seconds: int = Field(default=300)
