"""
Integration Tests for Local Remote Agent API & Security Pairing
"""

import pytest
from fastapi.testclient import TestClient
from remote_agent.agent import app
from remote_agent.security.pairing import PairingManager

client = TestClient(app)


def test_agent_health_endpoint():
    res = client.get("/api/v1/health")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "healthy"
    assert "devices_count" in data


def test_agent_devices_list():
    res = client.get("/api/v1/devices")
    assert res.status_code == 200
    devs = res.json()
    assert isinstance(devs, list)
    assert len(devs) > 0


def test_agent_command_execution():
    res = client.post("/api/v1/command", json={
        "device_id": "demo_samsung_tv",
        "command": "VOLUME_UP",
        "params": {}
    })
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "success"


def test_agent_device_state():
    res = client.get("/api/v1/device/demo_samsung_tv/state")
    assert res.status_code == 200
    data = res.json()
    assert "state" in data
    assert "display" in data


def test_pairing_manager_flow():
    pm = PairingManager(code_expiry_seconds=300)
    code = pm.generate_pairing_code("Test-Client")
    assert "-" in code
    assert len(code) == 7  # XXX-XXX

    # Invalid code
    assert pm.verify_pairing_code("000-000") is None

    # Valid code
    token = pm.verify_pairing_code(code)
    assert token is not None
    assert token.startswith("agt_")

    # Validate active token
    assert pm.validate_token(token) is True
    assert pm.validate_token("invalid_token") is False

    # Revoke
    pm.revoke_token(token)
    assert pm.validate_token(token) is False
