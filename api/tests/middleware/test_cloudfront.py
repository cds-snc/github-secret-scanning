# pylint: disable=missing-docstring,line-too-long
from unittest.mock import patch


@patch("middleware.cloudfront.CLOUDFRONT_HEADER", "foo")
def test_check_header_present(client):
    response = client.get("/version", headers={"X-CloudFront-Header": "foo"})
    assert response.status_code == 200


@patch("middleware.cloudfront.CLOUDFRONT_HEADER", "foo")
def test_check_header_bad_value(client):
    response = client.get("/version", headers={"X-CloudFront-Header": "bar"})
    assert response.status_code == 403


@patch("middleware.cloudfront.CLOUDFRONT_HEADER", "foo")
def test_check_header_missing(client):
    response = client.get("/version")
    assert response.status_code == 403
