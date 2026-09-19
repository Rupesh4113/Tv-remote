"""
Backend API Unit Tests
"""

import pytest
from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)


def test_health_endpoint():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["profiles_count"] >= 10


def test_list_profiles():
    response = client.get("/api/v1/profiles")
    assert response.status_code == 200
    data = response.json()
    assert len(data) >= 10

    # Filter by category TV
    tv_resp = client.get("/api/v1/profiles?category=TV")
    assert tv_resp.status_code == 200
    for item in tv_resp.json():
        assert item["category"] == "TV"

    # Filter by brand Tata
    tata_resp = client.get("/api/v1/profiles?brand=Tata")
    assert tata_resp.status_code == 200
    assert len(tata_resp.json()) >= 1
    assert "Tata Play" in tata_resp.json()[0]["brand"]


def test_get_profile_detail():
    response = client.get("/api/v1/profiles/tv-samsung-smart")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "tv-samsung-smart"
    assert "POWER" in data["commands"]
    assert "VOLUME_UP" in data["commands"]


def test_backup_save_and_retrieve():
    backup_payload = {
        "user_id": "test_user_123",
        "timestamp": "2026-09-19T12:00:00Z",
        "devices": [
            {"id": "dev1", "name": "Living Room TV", "brand": "Samsung"},
            {"id": "dev2", "name": "Tata Play STB", "brand": "Tata Play"}
        ],
        "macros": [],
        "learned_commands": []
    }
    post_resp = client.post("/api/v1/backup", json=backup_payload)
    assert post_resp.status_code == 200
    bkp_res = post_resp.json()
    assert bkp_res["status"] == "success"
    backup_id = bkp_res["backup_id"]

    get_resp = client.get(f"/api/v1/backup/{backup_id}")
    assert get_resp.status_code == 200
    data = get_resp.json()
    assert data["user_id"] == "test_user_123"
    assert len(data["devices"]) == 2


def test_web_remote_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "RemoteOne" in response.text
    assert "manifest.json" in response.text


def test_download_apk_redirect():
    response = client.get("/download/apk", follow_redirects=False)
    # If local APK not built, redirects to GitHub release URL
    assert response.status_code in [200, 307]

