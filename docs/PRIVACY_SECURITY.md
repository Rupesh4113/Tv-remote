# Privacy & Security Architecture

RemoteOne follows a strict **Local-First, Zero-Telemetry** privacy model.

## 1. Local Processing
- Remote control signals (IR pulses, Wi-Fi packets, and Bluetooth commands) are generated directly on your smartphone and sent straight to your television or set-top box.
- No remote commands or button clicks are ever transmitted to external cloud servers.

## 2. Secure Local Storage
- Device pairings, local IP addresses, and authentication tokens (e.g. LG client-key, Samsung session token, Sony PSK) are stored exclusively in the application's private sandbox storage (`SharedPreferences` / Android Keystore).
- Plaintext secrets are never exported or leaked in diagnostic logs.

## 3. Network Discovery Consent
- LAN discovery mechanisms (SSDP M-SEARCH, mDNS Bonjour) only broadcast queries within your local home network subnet.
- The app asks for network permissions explicitly.

## 4. Total Data Control & Erasure
- The Settings screen features a prominent **"Delete All Local Data"** button.
- Tapping this instantly purges all paired devices, learned commands, and automation macros from disk.

## 5. Opt-in Cloud Sync
- Cloud profile synchronization and encrypted backup are 100% optional.
- If disabled, RemoteOne functions completely offline without any internet connection.
