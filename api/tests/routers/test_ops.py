# pylint: disable=missing-docstring,line-too-long
from os import environ
from unittest.mock import patch
from fastapi import status


@patch.dict(environ, {"GIT_SHA": "mmmsha"})
def test_version(client):
    response = client.get("/version")
    assert response.status_code == status.HTTP_200_OK
    assert response.json()["version"] == "mmmsha"


def test_healthcheck(client):
    response = client.get("/healthcheck")
    assert response.status_code == status.HTTP_200_OK
    assert response.json()["status"] == "OK"


def test_security(client):
    response = client.get("/.well-known/security.txt")
    assert response.status_code == status.HTTP_200_OK
    assert (
        response.text
        == """Contact: mailto:security-securite@cds-snc.ca
Preferred-Languages: en, fr
Policy: https://digital.canada.ca/legal/security-notice
Hiring: https://digital.canada.ca/join-our-team/
Hiring: https://numerique.canada.ca/rejoindre-notre-equipe/
"""
    )
