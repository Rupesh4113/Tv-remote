"""
Device Profile Service
Discovers, indexes, and filters JSON device profiles from the device-profiles repository.
"""

import json
import os
from pathlib import Path
from typing import List, Optional, Dict
from ..models.schemas import DeviceProfileDetail, DeviceProfileSummary

PROFILES_DIR = Path(__file__).resolve().parent.parent.parent / "device-profiles"


class ProfileService:
    def __init__(self, base_dir: Path = PROFILES_DIR):
        self.base_dir = base_dir
        self._cache: Dict[str, DeviceProfileDetail] = {}
        self.reload()

    def reload(self):
        self._cache.clear()
        if not self.base_dir.exists():
            return

        for json_file in self.base_dir.rglob("*.json"):
            if "schema" in json_file.parts:
                continue
            try:
                with open(json_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    if "id" in data and "brand" in data:
                        profile = DeviceProfileDetail(**data)
                        self._cache[profile.id] = profile
            except Exception as e:
                print(f"Error loading profile {json_file}: {e}")

    def list_profiles(
        self,
        category: Optional[str] = None,
        brand: Optional[str] = None,
        region: Optional[str] = None,
        transport: Optional[str] = None,
    ) -> List[DeviceProfileSummary]:
        results = []
        for p in self._cache.values():
            if category and p.category.upper() != category.upper():
                continue
            if brand and brand.lower() not in p.brand.lower():
                continue
            if region and region.lower() not in p.region.lower() and p.region.lower() != "global":
                continue
            if transport and transport.upper() not in [t.upper() for t in p.supported_transports]:
                continue
            results.append(
                DeviceProfileSummary(
                    id=p.id,
                    brand=p.brand,
                    category=p.category,
                    model=p.model,
                    region=p.region,
                    version=p.version,
                    supported_transports=p.supported_transports,
                )
            )
        return sorted(results, key=lambda x: (x.brand, x.model))

    def get_profile(self, profile_id: str) -> Optional[DeviceProfileDetail]:
        return self._cache.get(profile_id)

    def count(self) -> int:
        return len(self._cache)
