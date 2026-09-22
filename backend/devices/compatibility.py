"""
Device Compatibility Matrix & Indian Brand Catalog
Detailed compatibility data across 30+ Indian TV brands and DTH/cable providers,
mapping supported protocols (Wi-Fi, Bluetooth, IR, Web API) and notes.
"""

from typing import List, Dict, Any

COMPATIBILITY_MATRIX: List[Dict[str, Any]] = [
    # --- SMART TVS ---
    {
        "brand": "Samsung",
        "category": "Smart TV",
        "os": "Tizen OS",
        "wifi": "✓ (WebSocket / REST)",
        "bluetooth": "Model dependent",
        "ir": "✓ (NEC / Samsung IR)",
        "web_api": "✓ (Port 8001/8002)",
        "status": "Fully Supported",
        "notes": "PIN pairing supported on Tizen 2016+"
    },
    {
        "brand": "LG",
        "category": "Smart TV",
        "os": "webOS",
        "wifi": "✓ (SSAP WebSocket)",
        "bluetooth": "Magic Remote BLE",
        "ir": "✓ (NEC / LG IR)",
        "web_api": "✓ (Port 3000/3001)",
        "status": "Fully Supported",
        "notes": "Handshake client key prompt on first connect"
    },
    {
        "brand": "Sony",
        "category": "Smart TV",
        "os": "Google TV / Android / Linux",
        "wifi": "✓ (IRCC-IP / REST)",
        "bluetooth": "Supported",
        "ir": "✓ (Sony SIRC 12/15-bit)",
        "web_api": "✓ (Pre-Shared Key PSK)",
        "status": "Fully Supported",
        "notes": "Bravia IP control via X-Auth-PSK header"
    },
    {
        "brand": "Xiaomi / Redmi / Mi TV",
        "category": "Smart TV",
        "os": "Android TV / PatchWall",
        "wifi": "✓ (Android TV Remote v2)",
        "bluetooth": "✓ (Mi Bluetooth Remote)",
        "ir": "Model dependent",
        "web_api": "✓ (Cast / Google TV API)",
        "status": "Fully Supported",
        "notes": "Zero-latency Wi-Fi & Bluetooth control"
    },
    {
        "brand": "OnePlus",
        "category": "Smart TV",
        "os": "Android TV / OxygenPlay",
        "wifi": "✓ (Android TV Remote v2)",
        "bluetooth": "✓ (BLE Remote)",
        "ir": "Model dependent",
        "web_api": "✓ (Google TV / Cast)",
        "status": "Fully Supported",
        "notes": "High responsiveness on Q & U series"
    },
    {
        "brand": "TCL",
        "category": "Smart TV",
        "os": "Google TV / Android TV",
        "wifi": "✓ (Android TV Remote v2)",
        "bluetooth": "Supported",
        "ir": "✓ (NEC IR)",
        "web_api": "✓ (Google TV API)",
        "status": "Fully Supported",
        "notes": "Supports Cast & direct IP input switching"
    },
    {
        "brand": "Hisense",
        "category": "Smart TV",
        "os": "VIDAA / Android TV",
        "wifi": "✓ (VIDAA REST / Android TV)",
        "bluetooth": "Supported",
        "ir": "✓ (NEC IR)",
        "web_api": "✓ (RemoteNow protocol)",
        "status": "Fully Supported",
        "notes": "Fast power & app launching"
    },
    {
        "brand": "Vu",
        "category": "Smart TV",
        "os": "Android TV / Google TV",
        "wifi": "✓ (Android TV Remote v2)",
        "bluetooth": "Supported",
        "ir": "✓ (NEC IR)",
        "web_api": "✓ (Google TV)",
        "status": "Fully Supported",
        "notes": "Cinema TV & GloLED series fully compatible"
    },
    {
        "brand": "Panasonic",
        "category": "Smart TV",
        "os": "My Home Screen / Android TV",
        "wifi": "✓ (Viera Remote / Android TV)",
        "bluetooth": "Supported",
        "ir": "✓ (Panasonic 48-bit)",
        "web_api": "✓ (Port 55000)",
        "status": "Fully Supported",
        "notes": "Classic Viera IP protocol + modern Android TV"
    },
    {
        "brand": "Philips",
        "category": "Smart TV",
        "os": "Saphi / Android TV / Google TV",
        "wifi": "✓ (JointSPACE REST / Android)",
        "bluetooth": "Supported",
        "ir": "✓ (RC5 / RC6 IR)",
        "web_api": "✓ (JointSPACE API v6)",
        "status": "Fully Supported",
        "notes": "Ambilight controls available on compatible models"
    },
    {
        "brand": "Realme / Motorola / Nokia / Acer",
        "category": "Smart TV",
        "os": "Android TV / Google TV",
        "wifi": "✓ (Android TV Remote v2)",
        "bluetooth": "Supported",
        "ir": "✓ (NEC IR)",
        "web_api": "✓ (Google TV API)",
        "status": "Fully Supported",
        "notes": "Controlled over Android TV protocol v2"
    },
    {
        "brand": "Kodak / Blaupunkt / Thomson / Sansui",
        "category": "Smart TV",
        "os": "Android TV / Linux",
        "wifi": "✓ (Android TV where equipped)",
        "bluetooth": "Model dependent",
        "ir": "✓ (NEC IR)",
        "web_api": "Model dependent",
        "status": "Supported",
        "notes": "Works over Android TV Wi-Fi or IR Blaster"
    },
    {
        "brand": "Onida / Micromax / BPL / Videocon / Akai / Croma",
        "category": "Traditional / Value TV",
        "os": "Custom Firmware / Basic Smart",
        "wifi": "Limited",
        "bluetooth": "—",
        "ir": "✓ (NEC / RC5 IR)",
        "web_api": "—",
        "status": "IR Control (Agent / Mobile)",
        "notes": "Controlled via Local Agent IR Blaster or Phone IR"
    },

    # --- INDIAN SET-TOP BOXES ---
    {
        "brand": "Tata Play",
        "category": "Set-Top Box (DTH)",
        "os": "NDS / Android (Binge+)",
        "wifi": "✓ (Binge+ Smart Box)",
        "bluetooth": "✓ (Binge+ Voice Remote)",
        "ir": "✓ (NEC Protocol)",
        "web_api": "Model dependent",
        "status": "Fully Supported",
        "notes": "Full support for Ch 100-999, Guide, Red/Blue keys"
    },
    {
        "brand": "Airtel Digital TV",
        "category": "Set-Top Box (DTH)",
        "os": "Xstream Android / Linux",
        "wifi": "✓ (Xstream 4K Box)",
        "bluetooth": "✓ (Xstream Voice Remote)",
        "ir": "✓ (NEC Protocol)",
        "web_api": "Model dependent",
        "status": "Fully Supported",
        "notes": "Tuning by channel number & name (e.g. Ch 277)"
    },
    {
        "brand": "Dish TV & Videocon d2h",
        "category": "Set-Top Box (DTH)",
        "os": "DishNXT / SMRT Hub",
        "wifi": "Model dependent",
        "bluetooth": "Model dependent",
        "ir": "✓ (NEC Protocol)",
        "web_api": "—",
        "status": "Fully Supported",
        "notes": "Instant tuning and favorite channel macros"
    },
    {
        "brand": "Sun Direct",
        "category": "Set-Top Box (DTH)",
        "os": "Digital DTH",
        "wifi": "—",
        "bluetooth": "—",
        "ir": "✓ (NEC Protocol)",
        "web_api": "—",
        "status": "Supported (IR)",
        "notes": "South India DTH channel mappings supported"
    },
    {
        "brand": "DD Free Dish",
        "category": "Set-Top Box (Free-To-Air)",
        "os": "DVB-S2 Free-to-Air",
        "wifi": "—",
        "bluetooth": "—",
        "ir": "✓ (NEC Protocol)",
        "web_api": "—",
        "status": "Supported (IR)",
        "notes": "Solid, Melbon, Catvision IR profiles supported"
    },
    {
        "brand": "Hathway / GTPL / DEN / Siti / Asianet / ACT",
        "category": "Cable Set-Top Box",
        "os": "Digital Cable / Android Hybrid",
        "wifi": "Hybrid boxes supported",
        "bluetooth": "Hybrid boxes supported",
        "ir": "✓ (NEC Protocol)",
        "web_api": "—",
        "status": "Supported (IR & Hybrid)",
        "notes": "Standard digital cable channel & guide navigation"
    }
]


def get_brands(category: str = "all") -> List[str]:
    """Returns sorted unique list of supported brand names."""
    brands = set(entry["brand"] for entry in COMPATIBILITY_MATRIX)
    return sorted(list(brands))
