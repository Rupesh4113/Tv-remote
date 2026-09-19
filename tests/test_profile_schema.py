"""
Test schema validation for all Device Profiles
"""

import json
from pathlib import Path
import pytest
import jsonschema

BASE_DIR = Path(__file__).resolve().parent.parent
PROFILES_DIR = BASE_DIR / "device-profiles"
SCHEMA_FILE = PROFILES_DIR / "schema" / "device_profile.schema.json"


@pytest.fixture(scope="session")
def profile_schema():
    with open(SCHEMA_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def test_schema_file_exists():
    assert SCHEMA_FILE.exists(), f"Schema file not found at {SCHEMA_FILE}"


def test_validate_all_device_profiles(profile_schema):
    profile_files = list(PROFILES_DIR.rglob("*.json"))
    # Filter out the schema file itself
    profiles_to_test = [f for f in profile_files if "schema" not in f.parts]
    assert len(profiles_to_test) >= 10, f"Expected at least 10 device profiles, found {len(profiles_to_test)}"

    for profile_path in profiles_to_test:
        with open(profile_path, "r", encoding="utf-8") as f:
            data = json.load(f)
            try:
                jsonschema.validate(instance=data, schema=profile_schema)
            except jsonschema.ValidationError as e:
                pytest.fail(f"Validation failed for profile {profile_path.name}: {e.message}")
