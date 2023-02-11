"""
API routes for operation requests
"""
from os import environ
from fastapi import APIRouter
from fastapi.responses import PlainTextResponse

router = APIRouter()


@router.get("/version")
def version():
    "Commit SHA of the deployed version"
    return {"version": environ.get("GIT_SHA", "unknown")}


@router.get("/healthcheck")
def healthcheck():
    "Simple healthcheck to check the service is running"
    return {"status": "OK"}


@router.get("/.well-known/security.txt", response_class=PlainTextResponse)
def security():
    "Security.txt file"
    return """Contact: mailto:security-securite@cds-snc.ca
Preferred-Languages: en, fr
Policy: https://digital.canada.ca/legal/security-notice
Hiring: https://digital.canada.ca/join-our-team/
Hiring: https://numerique.canada.ca/rejoindre-notre-equipe/
"""
