# RemoteOne Architecture & System Design

```
+-------------------------------------------------------------------------+
|                              Mobile App (Flutter)                       |
|                                                                         |
|  +--------------------+  +----------------------+  +-----------------+  |
|  |  TV Remote Screen  |  |   STB Remote Screen  |  | Combined Remote |  |
|  +--------------------+  +----------------------+  +-----------------+  |
|            |                         |                       |          |
|            +-------------------------+-----------------------+          |
|                                      |                                  |
|                         +-------------------------+                     |
|                         |    RemoteController     |                     |
|                         +-------------------------+                     |
|                                      |                                  |
|           +--------------------------+--------------------------+       |
|           |                          |                          |       |
|  +------------------+       +------------------+       +--------------+ |
|  |   IrTransport    |       |  WiFiTransport   |       | BleTransport | |
|  +------------------+       +------------------+       +--------------+ |
+-----------|--------------------------|--------------------------|-------+
            | (MethodChannel)          |                          |
            v                          |                          |
+------------------------+             |                          |
|  Native Android Bridge |             |                          |
|  (ConsumerIrManager)   |             |                          |
+------------------------+             |                          |
            |                          |                          |
            v (38kHz/40kHz pulses)     v (WebSocket/HTTP REST)    v (GATT)
+------------------------+    +------------------+    +-----------------+
| Physical IR Blaster    |    | Local Wi-Fi / LAN|    | Bluetooth / BLE |
+------------------------+    +------------------+    +-----------------+
            |                          |                          |
            v                          v                          v
+-------------------------------------------------------------------------+
|                  Target Hardware / Mock Device Simulators               |
|                                                                         |
|  * Indian STBs: Tata Play, Airtel Digital TV, Dish TV, d2h, Sun Direct |
|  * Smart TVs: Samsung (Tizen WS), LG (webOS SSAP), Sony (IRCC-IP)       |
|  * Cable Providers: Hathway, Den Networks, GTPL, Siti Cable             |
+-------------------------------------------------------------------------+
```

## Transport Abstraction Layer
All communication with external devices inherits from `BaseTransport`:
- `initialize()`: Checks hardware availability (e.g. checking whether phone possesses a physical IR blaster).
- `connect(DeviceModel)`: Establishes stateful session if protocol is session-oriented (e.g. WebSocket for Samsung/LG, BLE GATT).
- `sendCommand(DeviceModel, RemoteCommand)`: Encodes normalized commands (`POWER`, `VOLUME_UP`, `CHANNEL_UP`) into transport-specific payloads.
- `disconnect()`: Cleanly shuts down active sockets.

## Device Profile Architecture
RemoteOne does not hardcode device codes in UI files. Instead, device profiles are stored in versioned, declarative JSON documents in `device-profiles/`:
1. **Metadata**: Brand, Category (`TV`, `SET_TOP_BOX`), Model, Region.
2. **Supported Transports**: Array containing `["IR", "WIFI", "BLUETOOTH"]`.
3. **Protocol Details**: Carrier frequency (36–40 kHz), customer codes, and timing formulas.
4. **Command Map**: Uniform keys mapped to IR hex, WebSocket packets, or REST endpoints.
