# How to Add a New TV or Set-Top Box Profile

RemoteOne uses a modular JSON-based profile repository located in `device-profiles/`. Anyone can contribute a new profile by creating a JSON file that matches `device-profiles/schema/device_profile.schema.json`.

## Directory Structure
- TVs: `device-profiles/tv/<brand_slug>/<model_or_family>.json`
- Set-Top Boxes: `device-profiles/set-top-box/<provider_slug>/<model>.json`

## Example Profile Template

```json
{
  "$schema": "../../schema/device_profile.schema.json",
  "id": "stb-regional-provider",
  "brand": "Regional Cable",
  "category": "SET_TOP_BOX",
  "model": "HD-100",
  "region": "India",
  "version": "1.0.0",
  "supported_transports": ["IR"],
  "ir_config": {
    "protocol": "NEC",
    "carrier_frequency_hz": 38000,
    "customer_code": "0x00FF"
  },
  "commands": {
    "POWER": { "label": "Power", "ir_hex": "0x00FFA25D" },
    "VOLUME_UP": { "label": "Volume +", "ir_hex": "0x00FF629D" },
    "VOLUME_DOWN": { "label": "Volume -", "ir_hex": "0x00FFA857" },
    "CHANNEL_UP": { "label": "Channel +", "ir_hex": "0x00FF02FD" },
    "CHANNEL_DOWN": { "label": "Channel -", "ir_hex": "0x00FF9867" },
    "DPAD_OK": { "label": "OK", "ir_hex": "0x00FF708F" }
  }
}
```

## Validation
Before submitting a pull request, run the automated profile validator:
```bash
pytest tests/test_profile_schema.py -v
```
If your profile passes validation, submit a Pull Request on GitHub!
