"""
Sync Device Profiles to Mobile App Assets & Generate index.json
Ensures offline availability of all TV & STB profiles directly within the mobile app.
"""

import json
import shutil
from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent
SOURCE_PROFILES_DIR = ROOT_DIR / "device-profiles"
TARGET_ASSETS_DIR = ROOT_DIR / "mobile" / "assets" / "profiles"


def sync_profiles():
    TARGET_ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    index = []

    for json_path in SOURCE_PROFILES_DIR.rglob("*.json"):
        if "schema" in json_path.parts:
            continue
        try:
            with open(json_path, "r", encoding="utf-8") as f:
                data = json.load(f)
                if "id" in data and "brand" in data:
                    target_file = TARGET_ASSETS_DIR / f"{data['id']}.json"
                    shutil.copy2(json_path, target_file)
                    index.append({
                        "id": data["id"],
                        "brand": data["brand"],
                        "category": data["category"],
                        "model": data["model"],
                        "region": data.get("region", "Global"),
                        "version": data.get("version", "1.0.0"),
                        "supported_transports": data["supported_transports"],
                        "file": f"{data['id']}.json"
                    })
        except Exception as e:
            print(f"Error copying {json_path}: {e}")

    index.sort(key=lambda x: (x["category"], x["brand"], x["model"]))
    with open(TARGET_ASSETS_DIR / "index.json", "w", encoding="utf-8") as f:
        json.dump(index, f, indent=2)

    print(f"Successfully synced {len(index)} device profiles to {TARGET_ASSETS_DIR}!")


if __name__ == "__main__":
    sync_profiles()
