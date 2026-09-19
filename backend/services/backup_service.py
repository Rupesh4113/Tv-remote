"""
Optional Encrypted Cloud Backup Service
Stores user-consented encrypted backups.
"""

import uuid
from typing import Dict
from ..models.schemas import BackupData, BackupResponse


class BackupService:
    def __init__(self):
        self._backups: Dict[str, BackupData] = {}

    def save_backup(self, backup: BackupData) -> BackupResponse:
        backup_id = f"bkp-{uuid.uuid4().hex[:12]}"
        self._backups[backup_id] = backup
        return BackupResponse(
            status="success",
            backup_id=backup_id,
            message="Backup saved securely. Cloud sync is opt-in and local-first."
        )

    def retrieve_backup(self, backup_id: str) -> BackupData:
        if backup_id not in self._backups:
            raise KeyError("Backup not found")
        return self._backups[backup_id]
