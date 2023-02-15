# pylint: disable=missing-docstring,line-too-long
from unittest.mock import patch
from requests.models import Response
from utils import crypto


@patch("utils.crypto.requests")
def test_get_public_key(mock_requests):
    mock_requests.Session.return_value.get.return_value.text = '{"public_keys":[{"key_identifier":"42","key":"some key value"},{"key_identifier":"43","key":"another key value"}]}'
    assert crypto.get_public_key("42") == "some key value"
    assert crypto.get_public_key("43") == "another key value"
    assert crypto.get_public_key("44") is None


@patch("utils.crypto.requests.Session.get")
def test_get_public_key_4xx_response(mock_get):
    mock_response = Response()
    mock_response.status_code = 404
    mock_get.return_value = mock_response
    assert crypto.get_public_key("42") is None


@patch("utils.crypto.requests.Session.get")
def test_get_public_key_5xx_response(mock_get):
    mock_response = Response()
    mock_response.status_code = 500
    mock_get.return_value = mock_response
    assert crypto.get_public_key("42") is None


@patch("utils.crypto.requests")
def test_get_public_key_no_key(mock_requests):
    mock_requests.Session.return_value.get.return_value.text = '{"public_keys":[]}'
    assert crypto.get_public_key("42") is None


@patch("utils.crypto.get_public_key")
def test_is_valid_signature(mock_get_public_key):
    mock_get_public_key.return_value = "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEsz9ugWDj5jK5ELBK42ynytbo38gP\nHzZFI03Exwz8Lh/tCfL3YxwMdLjB+bMznsanlhK0RwcGP3IDb34kQDIo3Q==\n-----END PUBLIC KEY-----\n"
    assert (
        crypto.is_valid_signature(
            "42",
            "MEUCIFLZzeK++IhS+y276SRk2Pe5LfDrfvTXu6iwKKcFGCrvAiEAhHN2kDOhy2I6eGkOFmxNkOJ+L2y8oQ9A2T9GGJo6WJY=",
            '[{"token":"some_token","type":"some_type","url":"some_url","source":"some_source"}]',
        )
        is True
    )
    assert (
        crypto.is_valid_signature(
            "42",
            "MEUCIFLZzeK++IhS+y276SRk2Pe5LfDrfvTXu6iwKKcFGCrvAiEAhHN2kDOhy2I6eGkOFmxNkOJ+L2y8oQ9A2T9GGJo6WJY=",
            '[{"token":"nope"}]',
        )
        is False
    )


@patch("utils.crypto.get_public_key")
def test_is_valid_signature_missing_data(mock_get_public_key):
    mock_get_public_key.return_value = None
    assert crypto.is_valid_signature("1", "2", "3") is False
    assert crypto.is_valid_signature(None, None, None) is False
