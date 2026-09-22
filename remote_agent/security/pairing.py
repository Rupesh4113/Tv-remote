"""
Security & Device Pairing Manager
Generates 6-digit short-lived pairing codes (e.g. 582-914) to securely pair Streamlit Cloud with the Local Agent.
Issues and validates bearer auth tokens.
"""

import time
import random
import secrets
import logging
from typing import Dict, Any, Optional

logger = logging.getLogger("AgentSecurity")


class PairingManager:
    """Manages short-lived pairing codes and authenticated sessions."""

    def __init__(self, code_expiry_seconds: int = 300):
        self.code_expiry_seconds = code_expiry_seconds
        self.pending_codes: Dict[str, Dict[str, Any]] = {}
        self.active_tokens: Dict[str, Dict[str, Any]] = {}

    def generate_pairing_code(self, client_name: str = "Streamlit-Web") -> str:
        """Generates a human-friendly 6-digit code formatted as XXX-XXX."""
        part1 = random.randint(100, 999)
        part2 = random.randint(100, 999)
        code = f"{part1}-{part2}"

        self.pending_codes[code] = {
            "client_name": client_name,
            "created_at": time.time(),
            "expires_at": time.time() + self.code_expiry_seconds
        }
        logger.info("Generated pairing code: %s for %s", code, client_name)
        return code

    def verify_pairing_code(self, code: str) -> Optional[str]:
        """Validates code and returns a new session token if successful."""
        entry = self.pending_codes.get(code.strip())
        if not entry:
            return None

        if time.time() > entry["expires_at"]:
            del self.pending_codes[code]
            return None

        # Success: generate session token
        token = "agt_" + secrets.token_hex(24)
        self.active_tokens[token] = {
            "client_name": entry["client_name"],
            "paired_at": time.time(),
            "last_used": time.time()
        }
        del self.pending_codes[code]
        logger.info("Pairing code verified. Issued token for %s", entry["client_name"])
        return token

    def validate_token(self, token: str) -> bool:
        """Checks if a bearer token is active."""
        if not token:
            return False
        entry = self.active_tokens.get(token)
        if entry:
            entry["last_used"] = time.time()
            return True
        return False

    def revoke_token(self, token: str) -> bool:
        if token in self.active_tokens:
            del self.active_tokens[token]
            return True
        return False
