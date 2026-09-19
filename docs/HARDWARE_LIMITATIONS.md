# Hardware Realism and Platform Limitations

## 1. Core Principle: Zero False Claims
RemoteOne is built on engineering integrity. We never claim a smartphone can universally control every TV using all technologies when hardware or API constraints prevent it.

```
                    +--------------------------------+
                    | Smartphone Capabilities Check  |
                    +--------------------------------+
                                   |
            +----------------------+----------------------+
            |                                             |
   Physical IR Blaster?                        Local Wi-Fi / BLE?
            |                                             |
     +------+------+                               +------+------+
     |             |                               |             |
   [Yes]          [No]                           [Yes]          [No]
     |             |                               |             |
IR Blaster    Notify user:                    Device exposes   Show network
Active        "IR not available on phone.     public API?      disabled error
              Try Wi-Fi or Bluetooth."             |
                                            +------+------+
                                            |             |
                                          [Yes]          [No]
                                            |             |
                                        Wi-Fi Control  Show "Unsupported
                                        Enabled         Network API"
```

## 2. Infrared (IR) Constraints
- **Hardware Requirement**: Physical Consumer IR emitter chip (common on Xiaomi, Redmi, Poco, and select Vivo/Honor devices).
- **iOS Limitation**: Apple iPhones do NOT contain consumer IR emitters. On iOS, RemoteOne automatically hides/disables IR mode and activates Wi-Fi & Bluetooth smart controls.
- **Android Fallback**: If `ConsumerIrManager.hasIrEmitter()` returns `false`, the app informs the user gracefully without failing silently.

## 3. Wi-Fi Smart TV Constraints
- Both the smartphone and the TV must reside on the **same local subnet / Wi-Fi network**.
- Client isolation (Guest Wi-Fi) on certain routers blocks device-to-device communication.
- Some TV manufacturers turn off their network cards during deep sleep / standby (Wake-on-LAN must be enabled in TV settings for power-on).

## 4. Bluetooth / BLE Constraints
- The television or set-top box must expose a compatible BLE HID or Remote Control GATT service.
- Standard Android TVs require initial Bluetooth pairing from system settings before GATT write operations succeed.
