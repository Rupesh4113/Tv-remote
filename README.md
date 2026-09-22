# RemoteOne — Universal TV & Set-Top Box Remote

<div align="center">

**Control your TV and Set-Top Box from your phone with Infrared (IR), Wi-Fi, and Bluetooth.**

[![CI Test Suite](https://github.com/Rupesh4113/Tv-remote/actions/workflows/test.yml/badge.svg)](https://github.com/Rupesh4113/Tv-remote/actions/workflows/test.yml)
[![Android Build](https://github.com/Rupesh4113/Tv-remote/actions/workflows/android-build.yml/badge.svg)](https://github.com/Rupesh4113/Tv-remote/actions/workflows/android-build.yml)
[![Streamlit App](https://static.streamlit.io/badges/streamlit_badge_black_white.svg)](https://share.streamlit.io)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green.svg)](#)

</div>

---

### 🌐 Live Streamlit Web Remote
Run or deploy the full interactive Universal Web Remote directly in your browser:
```bash
pip install -r requirements.txt
streamlit run streamlit_app.py
```
Or deploy in 1-click on [Streamlit Community Cloud](https://share.streamlit.io) with zero setup! See [docs/STREAMLIT_DEPLOYMENT.md](docs/STREAMLIT_DEPLOYMENT.md).

---

## 1. Project Overview

**RemoteOne** is a modern, open-source Universal Remote Control application specifically tailored for televisions and set-top boxes (STBs), with deep support for the **Indian television and DTH ecosystem** as well as global smart TV brands.

The application unifies three distinct communication technologies into an extensible driver architecture:
1. **Infrared (IR)** — for Android phones equipped with a built-in IR blaster (`ConsumerIrManager`).
2. **Wi-Fi / LAN** — for network-connected smart televisions (Samsung Tizen, LG webOS, Android TV, Google TV, Sony Bravia IRCC, Roku).
3. **Bluetooth / BLE** — for low-energy wireless pairing and compatible remote GATT profiles.

---

## 2. Key Features

- **Realistic Tactile Remote Interface**: High-contrast dark and light modes, tactile haptic feedback, 5-way D-Pad, Volume & Channel rockers, Indian DTH color keys (Red, Green, Yellow, Blue), and streaming hotkeys (Netflix, YouTube, Prime Video).
- **Combined Remote Mode**: Control both your television (Power, Volume, Input) and Set-Top Box (Channels, D-Pad, Guide, Numbers) simultaneously from a unified screen with customizable command routing.
- **Hardware Realism & Graceful Fallback**: Automatically detects phone hardware capabilities. If an IR blaster is not present, the app gracefully notifies the user and directs them to Wi-Fi or Bluetooth.
- **Auto-Discovery & Pairing**: LAN discovery via mDNS and SSDP, with automated pairing prompts and PIN exchange.
- **IR Learning Mode**: Capture IR signals from physical remotes on supported hardware, verify with test bursts, and save custom command maps.
- **Macro Automation**: Chain multi-step commands with configurable delays (e.g. *"Watch TV"*: Power TV -> Wait 1.5s -> Switch to HDMI 1 -> Power Set-Top Box).
- **Voice Control**: Natural language intent parser for voice-driven volume changes, channel tuning, and app launching.
- **Local-First & Private**: Zero telemetry, no external servers required for day-to-day use, local secure storage, and instant "Delete All Local Data" capability.
- **Mock Device Simulator**: Built-in Python simulators for Samsung TV, LG webOS, Sony Bravia, and Tata Play STB to develop and verify without physical hardware.

---

## 3. Supported Devices Ecosystem

### Indian DTH & Cable Providers
- **Tata Play** (formerly Tata Sky) — HD, SD, Binge+ Android STB
- **Airtel Digital TV** — HD & Xstream 4K Smart Box
- **Dish TV** — DishNXT HD & SMRT Hub
- **Videocon d2h** — HD & 4K Boxes
- **Sun Direct** — HD DTH
- **DD Free Dish** — Free-to-Air Satellite Boxes (Solid, Melbon, Catvision)
- **Hathway Cable** — HD & Playbox Android STB
- **Den Networks** — Digital Cable Boxes
- **GTPL (KCBPL)** — Digital Cable STBs
- **Siti Cable & Asianet** — Regional cable boxes

### Television Brands
- **Global Smart TVs**: Samsung (Tizen), LG (webOS), Sony (Bravia IRCC-IP / Android TV), Philips, Panasonic, TCL, Hisense, Toshiba, Sharp.
- **Popular Indian / Value Brands**: Xiaomi / Redmi (PatchWall), OnePlus TV (OxygenPlay), Vu Cinema TV, Realme, Motorola, Haier, Kodak, Blaupunkt, Thomson, Akai, Onida, Videocon, Sansui, Lloyd, Croma, Micromax, Intex, BPL, CloudWalker, iFFALCON, Acer, Coocaa, JVC, Nokia.

---

## 4. Architecture

```
mobile/ (Flutter Client)
├── android/           -> Native Kotlin IR Bridge (ConsumerIrManager)
├── lib/core/          -> Themes, Haptic Feedback, Constants
├── lib/transports/    -> IR Encoders, Wi-Fi Adapters, BLE, Discovery
├── lib/services/      -> RemoteController, CombinedRemote, Macros, Voice
└── lib/ui/            -> Realistic Remote Screens, Add Wizard, Settings

device-profiles/       -> Declarative JSON Profiles for TVs & STBs
protocols/             -> IR timing generators (NEC, RC5, RC6, Sony, Samsung)
backend/               -> FastAPI optional catalog sync & Mock Simulator Suite
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed sequence diagrams and technical design.

---

## 5. Installation & Setup

### Prerequisites
- **Flutter SDK**: `>=3.22.x`
- **Java JDK**: `17+`
- **Android SDK**: `Platform 34`
- **Python**: `3.10+` (for backend & simulators)

### Clone & Install
```bash
git clone https://github.com/Rupesh4113/Tv-remote.git
cd "Tv remote"

# Install backend dependencies
pip install -r backend/requirements.txt

# Install mobile dependencies
cd mobile
flutter pub get
```

---

## 6. Android Development Setup

1. Connect your Android device via USB with USB Debugging enabled.
2. Verify connected device:
   ```bash
   adb devices
   ```
3. Run on device:
   ```bash
   cd mobile
   flutter run
   ```

### IR Blaster Setup
The app interacts with Android's native `ConsumerIrManager`. Permissions are declared in `mobile/android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.TRANSMIT_IR" />
<uses-feature android:name="android.hardware.consumerir" android:required="false" />
```
The native Kotlin bridge is implemented in `mobile/android/app/src/main/kotlin/org/remoteone/app/ir/ConsumerIrBridge.kt`.

### Wi-Fi & Bluetooth Setup
Required network permissions:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_MULTICAST_STATE" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

---

## 7. Running Tests

### 1. Protocols, Profiles & Backend Tests (Python)
```bash
# Run root test suite (IR timing encoders, profile schemas, voice parser, macros)
pytest tests/ -v

# Run backend API and simulator integration tests
pytest backend/tests/ -v
```

### 2. Mobile App Tests (Flutter)
```bash
cd mobile
flutter analyze
flutter test
```

---

## 8. Mock Device Simulators (No Hardware Needed)

RemoteOne includes a comprehensive mock device suite simulating real smart TVs and STBs:
```bash
python -m backend.simulator.runner
```
Or with Docker:
```bash
docker compose up simulator
```
Simulators active:
- **Dashboard**: `http://localhost:8080`
- **Mock Samsung TV**: `ws://localhost:8081/api/v2/channels/samsung.remote.control`
- **Mock LG webOS**: `ws://localhost:8082/`
- **Mock Sony Bravia**: `http://localhost:8083/sony/ircc`
- **Mock Tata Play STB**: `http://localhost:8084/stb/command`

---

## 9. Building the Android APK

To generate a standalone release APK:
```bash
cd mobile
flutter build apk --release
```
The output APK will be located at:
`mobile/build/app/outputs/flutter-apk/app-release.apk`

---

## 10. Docker Deployment

Deploy the optional backend and simulators:
```bash
docker compose up -d
```
API Documentation will be available at `http://localhost:8000/docs`.

---

## 11. Adding New TV or Set-Top Box Profiles

See [docs/CONTRIBUTING_PROFILES.md](docs/CONTRIBUTING_PROFILES.md) for full guidelines.
1. Create a JSON file in `device-profiles/tv/<brand>/` or `device-profiles/set-top-box/<provider>/`.
2. Ensure it conforms to `device-profiles/schema/device_profile.schema.json`.
3. Validate:
   ```bash
   pytest tests/test_profile_schema.py -v
   ```

---

## 12. Privacy & Security

RemoteOne operates strictly local-first:
- Commands are processed locally over IR, Wi-Fi, or Bluetooth.
- Credentials and PINs are stored securely on your device.
- Full data deletion is available under **Settings -> Privacy & Security -> Delete All Local Data**.
- Detailed policy: [docs/PRIVACY_SECURITY.md](docs/PRIVACY_SECURITY.md).

---

## 13. License

Distributed under the Apache 2.0 License. See [LICENSE](LICENSE) for details.
