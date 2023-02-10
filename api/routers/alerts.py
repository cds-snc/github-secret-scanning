"""
API routes for the GitHub alerts requests
"""
from fastapi import APIRouter, status

router = APIRouter()


@router.post("/alert", status_code=status.HTTP_201_CREATED)
def receive_alert():
    "Request from GitHub that a secret has been detected"
    return {"status": "OK"}
