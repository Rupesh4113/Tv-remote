# Android TV Remote Protocol v2 & Sony Bravia IRCC-IP & Roku ECP

## 1. Android TV Remote Protocol v2
- **Port**: `6466` (Control), `6467` (Pairing via TLS)
- **Discovery**: mDNS service `_androidtvremote2._tcp.local`
- **Authentication**: Mutual TLS with 4-digit or 6-digit PIN exchange.
- **Protocol**: Protocol Buffers over TLS socket (`RemoteKeyCode`, `RemoteDirection`, `RemoteKeyInject`).
  - Key codes follow standard Android `KeyEvent`:
    - `KEYCODE_POWER` = 26
    - `KEYCODE_VOLUME_UP` = 24
    - `KEYCODE_VOLUME_DOWN` = 25
    - `KEYCODE_VOLUME_MUTE` = 164
    - `KEYCODE_DPAD_UP` = 19
    - `KEYCODE_DPAD_DOWN` = 20
    - `KEYCODE_DPAD_LEFT` = 21
    - `KEYCODE_DPAD_RIGHT` = 22
    - `KEYCODE_DPAD_CENTER` = 23
    - `KEYCODE_BACK` = 4
    - `KEYCODE_HOME` = 3

---

## 2. Sony Bravia IRCC-IP Protocol
- **Port**: `80` (HTTP POST to `/sony/ircc`)
- **Discovery**: UPnP `urn:schemas-sony-com:service:IRCC:1`
- **Authentication**: Pre-Shared Key (`X-Auth-PSK: <password>`) configured in TV settings (Settings -> Network -> Home Network Setup -> IP Control -> Pre-Shared Key).
- **Format**: XML Envelope over HTTP POST:
```xml
<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:X_SendIRCC xmlns:u="urn:schemas-sony-com:service:IRCC:1">
      <IRCCCode>AAAAAQAAAAEAAAAVAw==</IRCCCode>
    </u:X_SendIRCC>
  </s:Body>
</s:Envelope>
```

---

## 3. Roku External Control Protocol (ECP)
- **Port**: `8060` (HTTP POST to `/keypress/<KEY>`)
- **Discovery**: SSDP M-SEARCH for `roku:ecp`
- **Authentication**: None required (local LAN).
- **Endpoints**:
  - `POST http://<roku-ip>:8060/keypress/Power`
  - `POST http://<roku-ip>:8060/keypress/VolumeUp`
  - `POST http://<roku-ip>:8060/keypress/VolumeDown`
  - `POST http://<roku-ip>:8060/launch/<appId>`
