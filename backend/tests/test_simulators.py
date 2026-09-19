"""
Unit tests for Mock Simulators (Samsung, LG, Sony, STB)
Using standard aiohttp.test_utils.TestClient and TestServer
"""

import pytest
from aiohttp.test_utils import TestClient, TestServer
from backend.simulator.mock_sony_bravia import MockSonyBravia
from backend.simulator.mock_stb import MockSTB


@pytest.mark.asyncio
async def test_mock_sony_bravia_handler():
    app = MockSonyBravia(psk="0000").app
    server = TestServer(app)
    client = TestClient(server)
    await client.start_server()

    try:
        # Unauthorized test
        resp_unauth = await client.post("/sony/ircc", data="<IRCCCode>AAAAAQAAAAEAAAAVAw==</IRCCCode>")
        assert resp_unauth.status == 403

        # Authorized command test
        headers = {"X-Auth-PSK": "0000", "Content-Type": "text/xml"}
        xml_data = "<IRCCCode>AAAAAQAAAAEAAAAVAw==</IRCCCode>"
        resp_auth = await client.post("/sony/ircc", headers=headers, data=xml_data)
        assert resp_auth.status == 200
        text = await resp_auth.text()
        assert "X_SendIRCCResponse" in text
    finally:
        await client.close()


@pytest.mark.asyncio
async def test_mock_stb_handler():
    app = MockSTB(provider="Tata Play").app
    server = TestServer(app)
    client = TestClient(server)
    await client.start_server()

    try:
        # Initial status
        resp = await client.get("/stb/status")
        assert resp.status == 200
        data = await resp.json()
        assert data["provider"] == "Tata Play"
        initial_channel = data["current_channel"]

        # Send CHANNEL_UP
        cmd_resp = await client.post("/stb/command", json={"command": "CHANNEL_UP"})
        assert cmd_resp.status == 200
        cmd_data = await cmd_resp.json()
        assert cmd_data["channel"] == initial_channel + 1
    finally:
        await client.close()
