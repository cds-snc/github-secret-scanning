# pylint: disable=missing-docstring,line-too-long
from unittest.mock import call, patch
from fastapi import status
from models.Alert import Alert


def test_homepage_404(client):
    response = client.get("/")
    assert response.status_code == status.HTTP_404_NOT_FOUND


@patch("main.alerts.is_valid_signature")
@patch("main.alerts.logger")
def test_alert_valid_signature(mock_logger, mock_is_valid_signature, client):
    mock_is_valid_signature.return_value = True
    response = client.post(
        "/alert",
        json=[
            {"token": "ring", "type": "frodo", "url": "baggins", "source": "shire"},
            {
                "token": "po-ta-toes",
                "type": "samwise",
                "url": "gamgee",
                "source": "shire",
            },
        ],
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert response.json() == {"status": "OK"}
    assert mock_logger.warning.call_count == 2
    mock_logger.warning.assert_has_calls(
        [
            call(
                "Secret detected: %s",
                Alert(token="ring", type="frodo", url="baggins", source="shire"),
            ),
            call(
                "Secret detected: %s",
                Alert(token="po-ta-toes", type="samwise", url="gamgee", source="shire"),
            ),
        ]
    )


@patch("main.alerts.is_valid_signature")
def test_alert_invalid_signature(mock_is_valid_signature, client):
    mock_is_valid_signature.return_value = False
    response = client.post(
        "/alert", json=[{"token":"foo","type":"bar","url":"bam","source":"baz"}]
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST
    assert response.json() == {
        "status": "ERROR",
        "payload": '[{"token":"foo","type":"bar","url":"bam","source":"baz"}]',
    }


def test_alert_bad_data(client):
    response = client.post("/alert", json={"foo": "bar"})
    assert response.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY
