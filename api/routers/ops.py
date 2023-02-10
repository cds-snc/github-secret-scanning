"""
API routes for operation requests
"""
from os import environ
from fastapi import APIRouter

router = APIRouter()


@router.get("/version")
def version():
    "Commit SHA of the deployed version"
    return {"version": environ.get("GIT_SHA", "unknown")}


@router.get("/healthcheck")
def healthcheck():
    "Simple healthcheck to check the service is running"
    return {"status": "OK"}
