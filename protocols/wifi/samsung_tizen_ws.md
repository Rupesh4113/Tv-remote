# Samsung Tizen Smart TV Protocol (WebSocket)

## 1. Overview
Samsung Smart TVs running Tizen OS (2016+) expose an authenticated WebSocket endpoint for remote control commands.

- **Ports**: 
  - `8001` (Insecure WebSocket: `ws://<ip>:8001/api/v2/channels/samsung.remote.control?name=<base64_client_name>`)
  - `8002` (Secure TLS WebSocket: `wss://<ip>:8002/api/v2/channels/samsung.remote.control?name=<base64_client_name>&token=<token>`)
- **Discovery**: UPnP M-SEARCH with ST `urn:samsung.com:device:RemoteControlReceiver:1` or SSDP `ssdp:all`.

## 2. Pairing & Handshake
1. The mobile app connects to `wss://<tv-ip>:8002/api/v2/channels/samsung.remote.control?name=UmVtb3RlT25l`.
2. The TV displays an on-screen dialog: *"Allow RemoteOne to connect?"*.
3. Once approved, the TV sends a JSON event:
```json
{
  "event": "ms.channel.connect",
  "data": {
    "token": "12345678",
    "clients": [...]
  }
}
```
4. The client saves `token` securely in local storage for subsequent connections.

## 3. Sending Key Commands
Remote key presses are sent as JSON frames:
```json
{
  "method": "ms.remote.control",
  "params": {
    "Cmd": "Click",
    "DataOfCmd": "KEY_VOLUP",
    "Option": "false",
    "TypeOfRemote": "SendRemoteKey"
  }
}
```

### Common Keys
- `KEY_POWER`
- `KEY_VOLUP`, `KEY_VOLDOWN`, `KEY_MUTE`
- `KEY_CHUP`, `KEY_CHDOWN`
- `KEY_UP`, `KEY_DOWN`, `KEY_LEFT`, `KEY_RIGHT`, `KEY_ENTER`
- `KEY_HOME`, `KEY_RETURN`, `KEY_SOURCE`
- `KEY_0` ... `KEY_9`
