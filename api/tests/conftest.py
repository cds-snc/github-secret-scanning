# pylint: disable=missing-docstring,line-too-long
import pytest
from fastapi.testclient import TestClient
from main import app


@pytest.fixture(scope="session")
def client() -> TestClient:
    yield TestClient(app)
