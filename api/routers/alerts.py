"""
API routes for the GitHub alerts requests
"""
from fastapi import APIRouter, Request, Response, status
from utils.crypto import is_valid_signature
from utils.logger import logger

router = APIRouter()


@router.post("/alert", status_code=status.HTTP_201_CREATED)
async def receive_alert(request: Request, response: Response):
    "Request from GitHub that a secret has been detected"

    public_key_id = request.headers.get("GITHUB-PUBLIC-KEY-IDENTIFIER")
    public_key_signature = request.headers.get("GITHUB-PUBLIC-KEY-SIGNATURE")

    raw_payload = await request.body()
    payload = raw_payload.decode("utf-8")

    if is_valid_signature(public_key_id, public_key_signature, payload):
        logger.info("%s", payload)
        return {"status": "OK"}

    response.status_code = status.HTTP_400_BAD_REQUEST
    return {"status": "ERROR", "payload": payload}
