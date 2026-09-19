"""
Mock Sony Bravia IRCC-IP TV Simulator
Implements HTTP POST /sony/ircc endpoint with pre-shared key validation and XML parsing.
"""

import logging
from aiohttp import web

logger = logging.getLogger("MockSonyBravia")

IRCC_CODE_MAP = {
    "AAAAAQAAAAEAAAAVAw==": "POWER",
    "AAAAAQAAAAEAAAASAw==": "VOLUME_UP",
    "AAAAAQAAAAEAAAATAw==": "VOLUME_DOWN",
    "AAAAAQAAAAEAAAAUAw==": "MUTE",
    "AAAAAQAAAAEAAAAQAw==": "CHANNEL_UP",
    "AAAAAQAAAAEAAAARAw==": "CHANNEL_DOWN",
    "AAAAAQAAAAEAAAB0Aw==": "DPAD_UP",
    "AAAAAQAAAAEAAAB1Aw==": "DPAD_DOWN",
    "AAAAAQAAAAEAAAA0Aw==": "DPAD_LEFT",
    "AAAAAQAAAAEAAAAzAw==": "DPAD_RIGHT",
    "AAAAAQAAAAEAAABlAw==": "DPAD_OK",
    "AAAAAQAAAAEAAABgAw==": "HOME",
    "AAAAAgAAABoAAAB8Aw==": "NETFLIX",
    "AAAAAgAAAMQAAABHAw==": "YOUTUBE",
}


class MockSonyBravia:
    def __init__(self, psk: str = "0000"):
        self.psk = psk
        self.app = web.Application()
        self.app.router.add_post("/sony/ircc", self.ircc_handler)
        self.app.router.add_get("/sony/system", self.system_handler)
        self.command_history: list = []

    async def system_handler(self, request: web.Request) -> web.Response:
        return web.json_response({
            "model": "Mock Sony Bravia 4K XR",
            "generation": "2024",
            "ircc_service": True
        })

    async def ircc_handler(self, request: web.Request) -> web.Response:
        auth_psk = request.headers.get("X-Auth-PSK", "")
        if auth_psk != self.psk:
            logger.warning("[Mock Sony] Unauthorized PSK attempt: %s", auth_psk)
            return web.Response(status=403, text="Forbidden: Invalid PSK")

        body = await request.text()
        extracted_code = ""
        if "<IRCCCode>" in body and "</IRCCCode>" in body:
            start = body.find("<IRCCCode>") + len("<IRCCCode>")
            end = body.find("</IRCCCode>")
            extracted_code = body[start:end].strip()

        cmd_name = IRCC_CODE_MAP.get(extracted_code, extracted_code)
        self.command_history.append(cmd_name)
        logger.info("[Mock Sony] IRCC Command executed: %s (code: %s)", cmd_name, extracted_code)

        xml_response = """<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
  <s:Body>
    <u:X_SendIRCCResponse xmlns:u="urn:schemas-sony-com:service:IRCC:1" />
  </s:Body>
</s:Envelope>"""
        return web.Response(text=xml_response, content_type="text/xml")


def create_app(psk: str = "0000") -> web.Application:
    sony = MockSonyBravia(psk=psk)
    return sony.app


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    web.run_app(create_app(), port=8083)
