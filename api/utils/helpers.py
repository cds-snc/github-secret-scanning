"""
Helper functions that need a home.
"""
import base64
import json
import os
import requests

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from dotenv import load_dotenv
from .logger import logger

load_dotenv()

GITHUB_PUBLIC_KEYS_URL = os.getenv("GITHUB_PUBLIC_KEYS_URL", "")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN", "")

if GITHUB_PUBLIC_KEYS_URL.strip() == "":
    raise ValueError("GITHUB_PUBLIC_KEYS_URL cannot be empty")
if GITHUB_TOKEN.strip() == "":
    raise ValueError("GITHUB_TOKEN cannot be empty")


def get_public_key(key_identifier):
    "Get public keys from GitHub"

    response = requests.get(
        GITHUB_PUBLIC_KEYS_URL,
        headers={"Authorization": f"token {GITHUB_TOKEN}"},
        timeout=15,
    )
    public_keys = json.loads(response.text)
    keys = public_keys.get("public_keys", [])

    if len(keys) == 0:
        logger.error("No public keys found: %s", public_keys)
        return None

    for key in keys:
        if key["key_identifier"] == key_identifier:
            return key["key"]

    logger.error(
        "Public key not found for key ID '%s'.  Keys returned: %s",
        key_identifier,
        public_keys,
    )
    return None


def is_valid_signature(key_id, signature, payload):
    "Validate the message signature"

    if not key_id or not signature or not payload:
        logger.error(
            "Missing key ID, signature or payload.  Key ID: %s, signature: %s, payload: %s",
            key_id,
            signature,
            payload,
        )
        return False

    pem = get_public_key(key_id)
    if not pem:
        return False

    public_key = serialization.load_pem_public_key(pem.encode("utf-8"), backend=None)
    try:
        public_key.verify(
            base64.b64decode(signature.encode("utf-8")),
            payload.encode("utf-8"),
            ec.ECDSA(hashes.SHA256()),
        )
        return True
    except InvalidSignature:
        logger.error("Invalid signature for key ID %s: %s", key_id, payload)
        return False
