"""
Database Service & Repository
Provides persistence for command history, favorites, device registry, and AI preferences.
"""

from pathlib import Path
import time
from datetime import datetime
from typing import List, Dict, Any, Optional
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from .models import Base, CommandHistory, Favorite, AIPreference, Device

DB_FILE = Path(__file__).resolve().parent.parent / "ai_remote.db"
DATABASE_URL = f"sqlite:///{DB_FILE}"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Initialize schema
Base.metadata.create_all(bind=engine)


class DatabaseService:
    def __init__(self):
        self.db: Session = SessionLocal()
        self._seed_default_favorites()

    def _seed_default_favorites(self):
        """Seed default Indian TV favorites if table is empty."""
        try:
            count = self.db.query(Favorite).count()
            if count == 0:
                defaults = [
                    Favorite(id="fav_star_sports", category="channel", name="Star Sports 1 HD", value="405", icon="🏏"),
                    Favorite(id="fav_sony_ten", category="channel", name="Sony Ten 1", value="471", icon="⚽"),
                    Favorite(id="fav_aaj_tak", category="channel", name="Aaj Tak", value="509", icon="📰"),
                    Favorite(id="fav_youtube", category="app", name="YouTube", value="YouTube", icon="▶️"),
                    Favorite(id="fav_netflix", category="app", name="Netflix", value="Netflix", icon="🍿"),
                    Favorite(id="fav_prime", category="app", name="Prime Video", value="Prime Video", icon="🎬"),
                    Favorite(id="fav_hotstar", category="app", name="Disney+ Hotstar", value="Disney+ Hotstar", icon="⭐"),
                    Favorite(id="fav_hdmi1", category="input", name="HDMI 1 (Console/STB)", value="HDMI 1", icon="🔌"),
                ]
                self.db.add_all(defaults)
                self.db.commit()
        except Exception:
            self.db.rollback()

    def record_command(self, command: str, device_id: Optional[str] = None, intent: Optional[str] = None, source: str = "ui", status: str = "success"):
        try:
            now_str = datetime.now().strftime("%H:%M")
            entry = CommandHistory(
                command=command,
                device_id=device_id,
                intent=intent,
                source=source,
                status=status,
                timestamp=time.time(),
                formatted_time=now_str
            )
            self.db.add(entry)
            self.db.commit()
        except Exception:
            self.db.rollback()

    def get_history(self, limit: int = 50) -> List[Dict[str, Any]]:
        try:
            records = self.db.query(CommandHistory).order_by(CommandHistory.id.desc()).limit(limit).all()
            return [
                {
                    "id": r.id,
                    "command": r.command,
                    "device_id": r.device_id,
                    "intent": r.intent,
                    "source": r.source,
                    "status": r.status,
                    "time": r.formatted_time or datetime.fromtimestamp(r.timestamp).strftime("%H:%M")
                }
                for r in records
            ]
        except Exception:
            return []

    def clear_history(self):
        try:
            self.db.query(CommandHistory).delete()
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False

    def get_favorites(self, category: Optional[str] = None) -> List[Dict[str, Any]]:
        try:
            q = self.db.query(Favorite)
            if category:
                q = q.filter(Favorite.category == category)
            return [
                {"id": f.id, "category": f.category, "name": f.name, "value": f.value, "icon": f.icon}
                for f in q.all()
            ]
        except Exception:
            return []

    def add_favorite(self, name: str, category: str, value: str, icon: str = "⭐") -> bool:
        try:
            fav_id = f"fav_{category}_{int(time.time())}"
            fav = Favorite(id=fav_id, name=name, category=category, value=value, icon=icon)
            self.db.add(fav)
            self.db.commit()
            return True
        except Exception:
            self.db.rollback()
            return False
