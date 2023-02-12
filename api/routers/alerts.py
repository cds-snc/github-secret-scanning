"""
API routes for the GitHub alerts requests
"""
from typing import List
from fastapi import APIRouter, Request, Response, status
from models.Alert import Alert
from utils.crypto import is_valid_signature
from utils.logger import logger

router = APIRouter()


@router.post("/alert", status_code=status.HTTP_201_CREATED)
async def receive_alert(request: Request, response: Response, alerts: List[Alert]):
    "Request from GitHub that a secret has been detected"

    # The raw string request body is needed to validate the signature
    raw_payload = await request.body()
    payload = raw_payload.decode("utf-8")

    # Make sure the request came from GitHub
    public_key_id = request.headers.get("GITHUB-PUBLIC-KEY-IDENTIFIER")
    public_key_signature = request.headers.get("GITHUB-PUBLIC-KEY-SIGNATURE")
    if is_valid_signature(public_key_id, public_key_signature, payload):
        for alert in alerts:
            logger.warning("Secret detected: %s", alert)
        return {"status": "OK"}

    response.status_code = status.HTTP_400_BAD_REQUEST
    return {"status": "ERROR", "payload": payload}
