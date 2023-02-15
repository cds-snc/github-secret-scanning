"""
Cryptography functions used to validate the GitHub request signature.
"""
import base64
import json
import requests

from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from dotenv import load_dotenv
from requests.adapters import HTTPAdapter, Retry
from requests.exceptions import HTTPError
from .helpers import get_env_var
from .logger import logger

load_dotenv()

GITHUB_PUBLIC_KEYS_URL = get_env_var("GITHUB_PUBLIC_KEYS_URL")
GITHUB_TOKEN = get_env_var("GITHUB_TOKEN")


def get_public_key(key_identifier: str) -> str or None:
    "Get public keys from GitHub"

    # Retry up to 5 times with exponential backoff
    session = requests.Session()
    retries = Retry(total=5, backoff_factor=1, status_forcelist=[500, 502, 503, 504])
    session.mount("http://", HTTPAdapter(max_retries=retries))

    try:
        response = session.get(
            GITHUB_PUBLIC_KEYS_URL,
            headers={"Authorization": f"token {GITHUB_TOKEN}"},
            timeout=15,
        )
        response.raise_for_status()
    except HTTPError as error:
        logger.error("Failed to get public keys from GitHub: %s", error)
        return None

    public_keys = json.loads(response.text, strict=False)
    keys = public_keys.get("public_keys", []) if isinstance(public_keys, dict) else []

    for key in keys:
        if key["key_identifier"] == key_identifier:
            return key["key"]

    logger.error(
        "Public key not found for key ID '%s'. Keys returned: %s. Response text: %s",
        key_identifier,
        public_keys,
        response.text,
    )
    return None


def is_valid_signature(key_id: str, signature: str, payload: str) -> bool:
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
