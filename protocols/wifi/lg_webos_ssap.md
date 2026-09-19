# LG webOS TV Protocol (SSAP WebSocket)

## 1. Overview
LG webOS smart televisions use the **SSAP (Second Screen Application Protocol)** over WebSocket.
- **Port**: `3000` (WS) or `3001` (WSS)
- **Discovery**: SSDP M-SEARCH for `urn:lge-com:service:webos-second-screen:1`

## 2. Registration & Pairing Handshake
The client sends a registration handshake:
```json
{
  "type": "register",
  "id": "reg_01",
  "payload": {
    "forcePairing": false,
    "pairingType": "PROMPT",
    "client-key": "<saved_client_key_or_empty>",
    "manifest": {
      "manifestVersion": 1,
      "appVersion": "1.0.0",
      "signed": {
        "created": "20260101",
        "appId": "org.remoteone.app",
        "vendorId": "org.remoteone",
        "localizedAppNames": { "": "RemoteOne" },
        "permissions": [
          "CONTROL_INPUT_TEXT",
          "CONTROL_MOUSE_AND_KEYBOARD",
          "READ_INSTALLED_APPS",
          "READ_RUNNING_APPS"
        ]
      }
    }
  }
}
```
If `client-key` is missing or invalid, a pairing prompt appears on the TV screen. When accepted, the TV responds with `client-key`, which is stored locally.

## 3. Remote Commands
Commands are sent via request URIs:
- Volume Up: `ssap://audio/volumeUp`
- Volume Down: `ssap://audio/volumeDown`
- Set Mute: `ssap://audio/setMute` with `{"mute": true}`
- Channel Up: `ssap://tv/channelUp`
- Channel Down: `ssap://tv/channelDown`
- Power Off: `ssap://system/turnOff`
- Launch App: `ssap://system.launcher/launch` with `{"id": "netflix"}`
- Key input: Pointer socket / `ssap://media.controls/play`
