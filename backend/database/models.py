"""
Database Models for AI Smart Remote
SQLAlchemy models matching Section 34 of the master prompt specification:
- users
- devices
- device_models
- device_capabilities
- device_connections
- remote_profiles
- ir_profiles
- commands
- command_history
- scenes
- scene_actions
- favorites
- ai_preferences
- pairing_sessions
- remote_agents
"""

import time
from sqlalchemy import Column, String, Integer, Float, Boolean, Text, ForeignKey, create_engine
from sqlalchemy.orm import declarative_base, sessionmaker, relationship

Base = declarative_base()


class User(Base):
    __tablename__ = "users"
    id = Column(String(64), primary_key=True)
    username = Column(String(64), unique=True, nullable=False)
    created_at = Column(Float, default=time.time)


class DeviceModel(Base):
    __tablename__ = "device_models"
    id = Column(String(64), primary_key=True)
    brand = Column(String(64), nullable=False)
    model = Column(String(64), nullable=False)
    device_type = Column(String(32), nullable=False)
    region = Column(String(32), default="India")


class Device(Base):
    __tablename__ = "devices"
    id = Column(String(64), primary_key=True)
    name = Column(String(128), nullable=False)
    brand = Column(String(64), nullable=False)
    model = Column(String(64), nullable=False)
    device_type = Column(String(32), nullable=False)  # smart_tv, set_top_box, soundbar, etc.
    room = Column(String(64), default="Living Room")
    ip_address = Column(String(64), nullable=True)
    mac_address = Column(String(64), nullable=True)
    is_active = Column(Boolean, default=False)
    created_at = Column(Float, default=time.time)


class DeviceCapabilityModel(Base):
    __tablename__ = "device_capabilities"
    id = Column(Integer, primary_key=True, autoincrement=True)
    device_id = Column(String(64), ForeignKey("devices.id"))
    capability = Column(String(64), nullable=False)  # power, volume, channel, apps, etc.


class DeviceConnection(Base):
    __tablename__ = "device_connections"
    id = Column(Integer, primary_key=True, autoincrement=True)
    device_id = Column(String(64), ForeignKey("devices.id"))
    protocol = Column(String(32), nullable=False)  # wifi, websocket, infrared, bluetooth
    port = Column(Integer, nullable=True)
    status = Column(String(32), default="disconnected")
    last_connected_at = Column(Float, nullable=True)


class RemoteProfile(Base):
    __tablename__ = "remote_profiles"
    id = Column(String(64), primary_key=True)
    brand = Column(String(64), nullable=False)
    device_type = Column(String(32), nullable=False)
    profile_json = Column(Text, nullable=False)


class IRProfile(Base):
    __tablename__ = "ir_profiles"
    id = Column(String(64), primary_key=True)
    brand = Column(String(64), nullable=False)
    protocol = Column(String(32), default="NEC")
    frequency_hz = Column(Integer, default=38000)
    timing_data = Column(Text, nullable=False)


class CommandModel(Base):
    __tablename__ = "commands"
    id = Column(String(64), primary_key=True)
    device_id = Column(String(64), ForeignKey("devices.id"))
    command_name = Column(String(64), nullable=False)
    protocol = Column(String(32), nullable=False)
    payload = Column(Text, nullable=False)


class CommandHistory(Base):
    __tablename__ = "command_history"
    id = Column(Integer, primary_key=True, autoincrement=True)
    device_id = Column(String(64), nullable=True)
    command = Column(String(128), nullable=False)
    intent = Column(String(64), nullable=True)
    source = Column(String(32), default="ui")  # ui, ai_text, ai_voice, scene
    status = Column(String(32), default="success")
    timestamp = Column(Float, default=time.time)
    formatted_time = Column(String(32), nullable=True)


class SceneModel(Base):
    __tablename__ = "scenes"
    id = Column(String(64), primary_key=True)
    name = Column(String(128), nullable=False)
    icon = Column(String(16), default="🎬")
    description = Column(Text, nullable=True)
    created_at = Column(Float, default=time.time)


class SceneAction(Base):
    __tablename__ = "scene_actions"
    id = Column(Integer, primary_key=True, autoincrement=True)
    scene_id = Column(String(64), ForeignKey("scenes.id"))
    step_order = Column(Integer, nullable=False)
    target_type = Column(String(32), nullable=False)
    command = Column(String(64), nullable=False)
    params_json = Column(Text, default="{}")
    delay_seconds = Column(Float, default=0.5)
    description = Column(String(256), nullable=False)


class Favorite(Base):
    __tablename__ = "favorites"
    id = Column(String(64), primary_key=True)
    category = Column(String(32), nullable=False)  # channel, app, input, scene
    name = Column(String(128), nullable=False)
    value = Column(String(128), nullable=False)
    icon = Column(String(32), default="⭐")


class AIPreference(Base):
    __tablename__ = "ai_preferences"
    id = Column(String(64), primary_key=True)
    preferred_tv_id = Column(String(64), nullable=True)
    preferred_volume = Column(Integer, default=20)
    favorite_sports_channel = Column(String(64), default="405")
    offline_mode_enabled = Column(Boolean, default=True)


class PairingSession(Base):
    __tablename__ = "pairing_sessions"
    id = Column(String(64), primary_key=True)
    pairing_code = Column(String(16), nullable=False)
    token = Column(String(128), nullable=True)
    client_name = Column(String(64), nullable=False)
    expires_at = Column(Float, nullable=False)
    is_active = Column(Boolean, default=True)


class RemoteAgent(Base):
    __tablename__ = "remote_agents"
    id = Column(String(64), primary_key=True)
    agent_name = Column(String(128), nullable=False)
    host = Column(String(128), nullable=False)
    port = Column(Integer, default=8765)
    status = Column(String(32), default="online")
    last_ping = Column(Float, default=time.time)
