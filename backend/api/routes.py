"""
API Endpoints for RemoteOne
"""

from typing import List, Optional
from fastapi import APIRouter, HTTPException, Query
from ..models.schemas import (
    DeviceProfileSummary,
    DeviceProfileDetail,
    BackupData,
    BackupResponse,
    HealthResponse,
)
from ..services.profile_service import ProfileService
from ..services.backup_service import BackupService

router = APIRouter(prefix="/api/v1")
profile_service = ProfileService()
backup_service = BackupService()


@router.get("/health", response_model=HealthResponse)
def health_check():
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        profiles_count=profile_service.count()
    )


@router.get("/profiles", response_model=List[DeviceProfileSummary])
def list_profiles(
    category: Optional[str] = Query(None, description="TV, SET_TOP_BOX, etc."),
    brand: Optional[str] = Query(None, description="Search by brand name"),
    region: Optional[str] = Query(None, description="Filter by region e.g. India"),
    transport: Optional[str] = Query(None, description="Filter by IR, WIFI, BLUETOOTH")
):
    return profile_service.list_profiles(
        category=category,
        brand=brand,
        region=region,
        transport=transport
    )


@router.get("/profiles/{profile_id}", response_model=DeviceProfileDetail)
def get_profile(profile_id: str):
    profile = profile_service.get_profile(profile_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Device profile not found")
    return profile


@router.post("/backup", response_model=BackupResponse)
def save_backup(backup: BackupData):
    return backup_service.save_backup(backup)


@router.get("/backup/{backup_id}", response_model=BackupData)
def get_backup(backup_id: str):
    try:
        return backup_service.retrieve_backup(backup_id)
    except KeyError:
        raise HTTPException(status_code=404, detail="Backup record not found")
