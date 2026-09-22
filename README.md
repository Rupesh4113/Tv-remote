# AI Smart Remote — Universal Smart Remote

<div align="center">

### *"One Remote. Every Screen. Powered by AI."*

[![CI Test Suite](https://github.com/Rupesh4113/Tv-remote/actions/workflows/test.yml/badge.svg)](https://github.com/Rupesh4113/Tv-remote/actions/workflows/test.yml)
[![Streamlit App](https://static.streamlit.io/badges/streamlit_badge_black_white.svg)](https://share.streamlit.io)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux%20%7C%20Android%20%7C%20iOS%20%7C%20Web-green.svg)](#)

</div>

---

## 1. Product Overview

**AI Smart Remote** is a production-grade, universal remote control platform powered by artificial intelligence. Designed to operate across **Windows, macOS, Linux, Android mobile, iPhone/iPad, and desktop web browsers**, AI Smart Remote bridges cloud-hosted Streamlit applications with local entertainment devices over **Wi-Fi, Bluetooth, and Infrared (IR)**.

The platform provides out-of-the-box support for:
- **Global & Indian Smart TVs**: Samsung (Tizen), LG (webOS), Sony (Bravia IRCC), Xiaomi, Redmi, OnePlus, TCL, Hisense, Vu, Panasonic, Philips, Haier, Toshiba, Motorola, Realme, Nokia, Acer, Kodak, Blaupunkt, Thomson, and Android TV / Google TV.
- **Traditional / Legacy TVs**: Onida, Micromax, BPL, Videocon, Sansui, Akai, Croma via IR Blasters.
- **Indian DTH & Cable Providers**: Tata Play (formerly Tata Sky), Airtel Digital TV, Dish TV, Videocon d2h, Sun Direct, DD Free Dish, Hathway, GTPL, DEN, Siti Cable, Asianet, ACT.
- **AI Command Engine**: Sub-millisecond offline NLP intent parser with multi-step sequential automation (e.g. *"Turn on the TV and set volume to 25"* or *"Watch Star Sports"*).
- **Smart Scenes**: Prebuilt and natural-language generated scenes like *Movie Mode*, *Cricket Mode*, and *Good Night*.

---

## 2. Architecture: Cloud UI vs. Local Device Control

Streamlit Cloud applications running on remote servers cannot directly transmit infrared pulses or send UDP packets inside a user's private home network (`192.168.x.x`). **AI Smart Remote** solves this with a clean, decoupled architecture:

```text
┌─────────────────────────────────────────────────────────────┐
│                 Streamlit Cloud / Web UI                    │
│                                                             │
│   🏠 Home   📺 Remote   📱 Devices   🔍 Discover Devices    │
│   🤖 AI Assistant   🎤 Voice   🎬 Scenes   ⭐ Favorites     │
│   📊 Status   🛠 Diagnostics   ⚙ Settings  🔐 Security      │
└──────────────────────────────┬──────────────────────────────┘
                               │
               HTTPS / WebSocket / Relay / Local REST
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                 Local Remote Agent                          │
│          (Windows .exe / macOS .app / Linux)                │
│                                                             │
│  FastAPI / WebSocket Server  •  Discovery (mDNS/SSDP/Cast) │
│  Security & 6-Digit Pairing  •  IR Controller (NEC/RC5/etc) │
└──────────────┬───────────────┼───────────────┬──────────────┘
               │               │               │
             Wi-Fi         Bluetooth          IR
               │               │               │
               ▼               ▼               ▼
          Smart TVs       Smart STBs     Traditional TVs
         (Samsung, LG,   (Android TV,     & Indian DTH
         Sony, Android)   Fire TV)      (Tata Play, etc.)
```

### Operational Modes
1. **Local Mode**: The user runs Streamlit locally on their PC/laptop. Streamlit and the Local Remote Agent communicate directly over localhost (`http://localhost:8765`), with zero cloud dependency and 100% privacy.
2. **Cloud Mode with Local Remote Agent**: Streamlit runs on Streamlit Cloud. The user runs the lightweight Local Remote Agent on their laptop or PC, paired via a secure 6-digit code (e.g. `582-914`) to dispatch commands to LAN TVs and STBs.
3. **Demo / Simulator Mode**: Out-of-the-box simulated devices (`MockTV`, `MockSetTopBox`, `MockStreamingDevice`) allow complete UI, AI, and scene testing without physical hardware.

---

## 3. Supported Devices Ecosystem

### Indian Television Brands
| Brand | Supported Protocols | OS / Platform | Notes |
| :--- | :--- | :--- | :--- |
| **Samsung** | Wi-Fi (WS/REST), IR | Tizen OS | Port 8001/8002 WebSocket protocol |
| **LG** | Wi-Fi (SSAP), BLE, IR | webOS | SSAP client key handshake |
| **Sony** | Wi-Fi (IRCC-IP), IR | Bravia / Android TV | Pre-Shared Key (PSK) authentication |
| **Xiaomi / Redmi / Mi TV** | Wi-Fi, Bluetooth, IR | Android TV / PatchWall | Android TV v2 & Cast discovery |
| **OnePlus TV** | Wi-Fi, Bluetooth | Android TV / OxygenPlay | Instant input & app switching |
| **TCL / Vu / Hisense** | Wi-Fi, IR, Cast | Google TV / VIDAA | Full power, volume, and input control |
| **Panasonic / Philips** | Wi-Fi, IR | My Home Screen / Saphi | Viera & JointSPACE IP protocol |
| **Realme / Motorola / Nokia / Acer** | Wi-Fi, Cast | Android TV / Google TV | Certified Android TV Remote protocol |
| **Kodak / Blaupunkt / Thomson** | Wi-Fi, IR | Android TV / Custom | IR code maps + Android TV Wi-Fi |
| **Onida / Micromax / BPL / Videocon** | Infrared (IR) | Traditional / Value TV | NEC / RC5 timing pulses |

### Indian DTH & Cable Providers
- **Tata Play**: Full channel range (100–999), Star Sports hotkeys, Binge+ Android IP, Guide & Interactive color keys (Red, Green, Yellow, Blue).
- **Airtel Digital TV**: Full channel lineup, Xstream 4K Box Wi-Fi & IR remote support.
- **Dish TV & Videocon d2h**: Instant channel tuning, SMRT Hub hybrid support.
- **Sun Direct & DD Free Dish**: Digital FTA satellite box IR code mappings.
- **Hathway / GTPL / DEN / Siti / Asianet / ACT**: Digital cable set-top box IR and hybrid remote protocols.

---

## 4. Supported Protocols & Abstraction

All communication adheres to the extensible `RemoteProtocol` and `RemoteDevice` base classes:
- **WiFiProtocol / HTTPProtocol**: Direct REST & JSON-RPC communication (Sony IRCC, Philips JointSPACE).
- **WebSocketProtocol**: Persistent, low-latency bi-directional channels (Samsung Tizen, LG webOS).
- **InfraredProtocol & IRController**: Microsecond timing pulse generation for **NEC, RC5, RC6, Sony SIRC, Samsung, LG, and Panasonic** protocols, with IR code learning capability.
- **BluetoothProtocol & BLEProtocol**: GATT service communication for modern voice remotes.
- **UPnPProtocol & mDNSProtocol**: LAN discovery of MediaRenderers, Cast targets, and Bonjour endpoints.

---

## 5. Streamlit Web Setup

### Prerequisites
- Python 3.10+
- `pip` package manager

### Quick Start
```bash
git clone https://github.com/Rupesh4113/Tv-remote.git
cd Tv-remote
pip install -r requirements.txt
streamlit run streamlit_app.py
```
Open `http://localhost:8501` in your browser.

---

## 6. Local Remote Agent Setup

The Local Remote Agent bridges your browser with local LAN devices and IR emitters.

### Run via Python
```bash
python -m remote_agent.agent --port 8765
```
Output:
```text
============================================================
  🚀 AI SMART REMOTE — LOCAL REMOTE AGENT
  'One Remote. Every Screen. Powered by AI.'
  Listening on http://0.0.0.0:8765
  API Docs:     http://localhost:8765/docs
  WebSocket:    ws://localhost:8765/ws
============================================================
```

### Build Standalone Executable (Windows / macOS / Linux)
```bash
python remote_agent/build_executable.py
```
This generates a single-file executable in `dist/` (`ai-smart-remote-agent.exe` on Windows or ELF binary on Linux).

---

## 7. Platform Specific Setup Guides

### Windows PC / Laptop
1. Launch the agent: `python -m remote_agent.agent` or run `dist/ai-smart-remote-agent.exe`.
2. Allow Windows Defender Firewall prompt for Private Networks on port `8765`.
3. Open `http://localhost:8501` in Chrome or Edge.

### macOS Laptop
1. Run `python3 -m remote_agent.agent --port 8765`.
2. Grant Local Network permissions if prompted by macOS Ventura / Sonoma.
3. Access the Streamlit interface via Safari or Chrome.

### Linux PC
1. Run `python3 -m remote_agent.agent --port 8765`.
2. If using an external USB IR transceiver (e.g. Iguanaworks, USB-UIRT), verify user permissions on `/dev/ttyUSB0`.

---

## 8. Mobile Browser Setup (Android & iOS)

### Android Mobile Browser
- Open your browser (Chrome / Brave / Firefox) and navigate to your deployed Streamlit URL or `http://<laptop-ip>:8501`.
- **Progressive Web App (PWA)**: Tap **Add to Home Screen** for a full-screen, native-app feel.
- **IR Blaster Support**: If your phone features an IR emitter (e.g. Xiaomi, Redmi, Poco), commands can be dispatched via the native Android IR bridge. If no hardware IR is present, the app gracefully notifies you and utilizes Wi-Fi / Bluetooth.
- **Microphone**: Tap **Voice Remote** to speak natural language commands directly.

### iPhone / iPad Browser (iOS)
- Open Safari and navigate to the Streamlit app.
- Tap the **Share** icon -> **Add to Home Screen**.
- **Important Note**: iOS devices do not have hardware IR blasters. All device control from iOS communicates over Wi-Fi, Apple AirPlay / Cast, or through your Local Remote Agent running on your home network.

---

## 9. TV & Set-Top Box Pairing

### Pairing Samsung TV
1. Turn on your Samsung TV and ensure it is connected to the same Wi-Fi.
2. In the **Discover Devices** tab, click **Scan Local Network**.
3. Select your Samsung TV and click **Pair**.
4. An on-screen prompt on the TV will ask: *"Allow AI Smart Remote to connect?"* Select **Allow**.

### Pairing LG webOS TV
1. Select your LG TV and click **Connect**.
2. A pairing prompt with a client key will appear on the TV screen. Accept using your original LG remote.

### Pairing Sony Bravia TV
1. On your Sony TV: Go to **Settings -> Network -> Home Network -> IP Control**.
2. Set **Pre-Shared Key (PSK)** to `0000` (or configure your custom PSK in Settings).

### Setting Up Tata Play / Airtel / Dish TV
1. Select your STB in the **Devices** tab.
2. If using an IP-enabled box (Tata Play Binge+ or Airtel Xstream 4K), enter the IP address.
3. For traditional infrared STBs, ensure your phone or laptop IR emitter is pointed towards the set-top box.

---

## 10. AI Intent Engine & NLP Capabilities

AI Smart Remote contains a **100% offline rule-based LocalIntentEngine** that processes natural language variations with sub-millisecond response times:

```text
User Spoken/Text Command
          ↓
  LocalIntentEngine (Offline / Privacy-First)
          ↓
  Pydantic AICommand Validation
          ↓
  Target Device Capability Check
          ↓
  Direct Execution on Device
```

### Supported NLP Expressions (100+ variations tested):
- **Volume**: *"Set volume to 25"*, *"Make it louder"*, *"Increase volume by 5"*, *"Turn down volume"*, *"Volume 30"*.
- **Power**: *"Turn on the TV"*, *"Switch off living room television"*, *"Shut down TV"*.
- **Mute**: *"Mute the TV"*, *"Silence sound"*, *"Unmute"*, *"Restore sound"*.
- **Channels**: *"Change channel to 405"*, *"Tune to 101"*, *"Watch Star Sports"*, *"Tune to Sony Ten"*, *"Watch Aaj Tak"*, *"Channel up"*, *"Last channel"*.
- **Apps**: *"Open YouTube"*, *"Launch Netflix"*, *"Start Prime Video"*, *"Open Hotstar"*, *"Launch Jio Cinema"*.
- **Inputs**: *"Switch to HDMI 1"*, *"Change input to HDMI 2"*, *"Go to AV"*.
- **Scenes**: *"Start Movie Mode"*, *"Watch cricket"*, *"Good Night"*, *"Turn everything off"*.
- **Compound Instructions**: *"Turn on the TV and set volume to 25"*, *"Open YouTube and set volume to 20"*.

---

## 11. Smart Scenes Automation

Scenes execute multi-device workflows sequentially with step delays:

1. **Movie Mode (🍿)**:
   - 1. Power on TV
   - 2. Switch input to HDMI 1
   - 3. Set volume to 20
   - 4. Launch Netflix
2. **Cricket Mode (🏏)**:
   - 1. Power on TV
   - 2. Power on Tata Play STB
   - 3. Tune STB directly to Star Sports 1 HD (Ch 405)
   - 4. Set volume to 25
3. **Good Night (🌙)**:
   - 1. Power off TV
   - 2. Power off Set-Top Box
   - 3. Shut down audio devices

---

## 12. Local Network Security & Pairing

When connecting Streamlit Cloud to your home Local Agent:
1. Open the **Security** tab in Streamlit.
2. The Local Agent generates an ephemeral, human-friendly 6-digit code:
   ```text
   Pairing Code: 582-914
   ```
3. Enter the code in the Streamlit Security page.
4. The agent verifies the code and issues a rotating bearer session token (`agt_...`).
5. All traffic between Streamlit and the Local Agent is authenticated and encrypted.

---

## 13. Docker Deployment

### Run All Services via Docker Compose
```bash
docker compose up --build
```
This boots:
- `streamlit`: Streamlit Web Remote on port `8501`
- `local_agent`: Local Remote Agent on port `8765`
- `backend`: FastAPI API catalog on port `8000`
- `simulator`: Device Simulators on ports `8080-8084`

---

## 14. Streamlit Cloud Deployment

1. Fork or push this repository to GitHub.
2. Go to [share.streamlit.io](https://share.streamlit.io) and create a new app.
3. Select your repository, set the main file to `streamlit_app.py`.
4. In **Advanced Settings -> Secrets**, add:
   ```toml
   LOCAL_AGENT_URL = "http://<your-public-ip-or-tunnel>:8765"
   WEBSOCKET_SECRET = "your-custom-secret"
   ```
5. Click **Deploy!**

---

## 15. Testing & Verification

Run the full automated test suite (157+ unit and integration tests):
```bash
python -m pytest -v
```

### Test Coverage:
- `tests/test_ai_command_suite.py`: **120+ natural language NLP test cases** verifying all 15 intents.
- `tests/test_device_adapters.py`: TV and STB device adapters and state management.
- `tests/test_local_agent.py`: Local Remote Agent endpoints and 6-digit pairing flow.
- `tests/test_scene_engine.py`: Multi-step sequential scene automation.
- `tests/test_ir_protocols.py`: NEC, RC5, RC6, Sony, and Samsung timing generation.

---

## 16. Troubleshooting & Diagnostics

- **TV Not Responding**: Open the **Diagnostics** tab in the sidebar and run the diagnostic scan. Ensure your TV and laptop are on the same Wi-Fi subnet (e.g. `192.168.1.x`).
- **Cannot Connect from Streamlit Cloud to Home TV**: A cloud server cannot access `192.168.x.x` directly. Start the **Local Remote Agent** on your PC (`python -m remote_agent.agent`) and pair via the **Security** tab.
- **Port Conflict on 8765**: Run the agent on a custom port: `python -m remote_agent.agent --port 9000`.

---

## 17. License

Licensed under the [Apache License, Version 2.0](LICENSE).
Copyright © 2026 AI Smart Remote Contributors.
