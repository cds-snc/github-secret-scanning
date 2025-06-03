import pytest
from unittest import mock
from broadcast_alert import lambda_handler, does_key_contain_all_zeros


@mock.patch("broadcast_alert.boto3.client")
@mock.patch("broadcast_alert.json.loads")
@mock.patch("broadcast_alert.gzip")
@mock.patch("broadcast_alert.base64")
@mock.patch(
    "os.environ",
    {
        "sns_topic_arn": "fake_topic_arn",
        "subject": "Fake Subject",
        "notify_doc_api_key": "gcntfy-notify-test-key-11111",
    },
)
def test_lambda_handler_secret_detected(
    mock_base64, mock_gzip, mock_json_loads, mock_boto3_client
):
    mock_json_loads.return_value = {
        "logEvents": [
            {
                "message": "Secret detected: token='gcntfy-some-test-key-1111111-1111-1111-1111-111111111111' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'"
            }
        ]
    }
    event = {"awslogs": {"data": "foo"}}

    lambda_handler(event, None)
    mock_boto3_client.assert_called_once_with("sns")
    mock_boto3_client.return_value.publish.assert_called_once_with(
        TargetArn="fake_topic_arn",
        Message="API Key with value token='gcntfy-some-test-key-1111111-1111-1111-1111-111111111111', type='cds_canada_notify_api_key' and source='commit' has been detected in url='https://github.com/cds-snc/some-repo'!",
        Subject="Fake Subject",
    )


@mock.patch("broadcast_alert.boto3.client")
@mock.patch("broadcast_alert.json.loads")
@mock.patch("broadcast_alert.gzip")
@mock.patch("broadcast_alert.base64")
@mock.patch(
    "os.environ",
    {
        "sns_topic_arn": "fake_topic_arn",
        "subject": "Fake Subject",
        "notify_doc_api_key": "gcntfy-notify-test-key-11111",
    },
)
def test_lambda_handler_secret_detected_all_zeros(
    mock_base64, mock_gzip, mock_json_loads, mock_boto3_client
):
    mock_json_loads.return_value = {
        "logEvents": [
            {
                "message": "Secret detected: token='gcntfy-some-test-key-0000000-0000-0000-0000-000000000000' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'"
            }
        ]
    }
    event = {"awslogs": {"data": "foo"}}

    lambda_handler(event, None)
    mock_boto3_client.assert_not_called()


@mock.patch("broadcast_alert.boto3.client")
@mock.patch("broadcast_alert.json.loads")
@mock.patch("broadcast_alert.gzip")
@mock.patch("broadcast_alert.base64")
@mock.patch(
    "os.environ",
    {
        "sns_topic_arn": "fake_topic_arn",
        "subject": "Fake Subject",
        "notify_doc_api_key": "gcntfy-notify-test-key-11111",
    },
)
@pytest.mark.parametrize(
    "message,expected_token,expected_type,expected_url,expected_source",
    [
        (
            "Secret detected: token='gcntfy-some-test-key-33333333-3333-3333-3333-333333333333' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'",
            "gcntfy-some-test-key-33333333-3333-3333-3333-333333333333",
            "cds_canada_notify_api_key",
            "https://github.com/cds-snc/some-repo",
            "commit",
        ),
        (
            "Secret detected: token='gcntfy-github-test-key-1111111-1111-1111-1111-111111111111' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'",
            "gcntfy-github-test-key-1111111-1111-1111-1111-111111111111",
            "cds_canada_notify_api_key",
            "https://github.com/cds-snc/some-repo",
            "commit",
        ),
        (
            "Secret detected: token='gcntfy-notify-some-key-2222222-2222-2222-2222-222222222222' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'",
            "gcntfy-notify-some-key-2222222-2222-2222-2222-222222222222",
            "cds_canada_notify_api_key",
            "https://github.com/cds-snc/some-repo",
            "commit",
        ),
        (
            "Secret detected: token='gcntfy-notify-test-key-11aa223-4455-6677-8899-aabbccddeeff' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'",
            "gcntfy-notify-test-key-11aa223-4455-6677-8899-aabbccddeeff",
            "cds_canada_notify_api_key",
            "https://github.com/cds-snc/some-repo",
            "commit",
        ),
        (
            "Secret detected: token='gcntfy-notify-secret-key-aaaabbb-cccc-dddd-eeee-56789abcdef0' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'",
            "gcntfy-notify-secret-key-aaaabbb-cccc-dddd-eeee-56789abcdef0",
            "cds_canada_notify_api_key",
            "https://github.com/cds-snc/some-repo",
            "commit",
        ),
        (
            "Secret detected: token='gcntfy-notify-access-key-abc123-def6-7890-ghij-klmnopqrstuv' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'",
            "gcntfy-notify-access-key-abc123-def6-7890-ghij-klmnopqrstuv",
            "cds_canada_notify_api_key",
            "https://github.com/cds-snc/some-repo",
            "commit",
        ),
        (
            "Secret detected: token='gcntfy-notify-api-key-0a0a0a0-1b1b-2c2c-3d3d-4e4e4e4e4e4e' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'",
            "gcntfy-notify-api-key-0a0a0a0-1b1b-2c2c-3d3d-4e4e4e4e4e4e",
            "cds_canada_notify_api_key",
            "https://github.com/cds-snc/some-repo",
            "commit",
        ),
    ],
)
def test_lambda_handler_secret_detected_multiple_secrets(
    mock_base64,
    mock_gzip,
    mock_json_loads,
    mock_boto3_client,
    message,
    expected_token,
    expected_type,
    expected_url,
    expected_source,
):
    mock_json_loads.return_value = {"logEvents": [{"message": message}]}
    event = {"awslogs": {"data": "foo"}}

    lambda_handler(event, None)
    mock_boto3_client.assert_called_once_with("sns")

    # Build the expected message body
    expected_body = f"API Key with value token='{expected_token}', type='{expected_type}' and source='{expected_source}' has been detected in url='{expected_url}'!"
    # Ensure the publish method is called with the correct arguments
    mock_boto3_client.return_value.publish.assert_called_once_with(
        TargetArn="fake_topic_arn",
        Message=expected_body,
        Subject="Fake Subject",
    )


@mock.patch("broadcast_alert.boto3.client")
@mock.patch("broadcast_alert.json.loads")
@mock.patch("broadcast_alert.gzip")
@mock.patch("broadcast_alert.base64")
@mock.patch(
    "os.environ",
    {
        "sns_topic_arn": "fake_topic_arn",
        "subject": "Fake Subject",
        "notify_doc_api_key": "gcntfy-notify-test-key-11111",
    },
)
@pytest.mark.parametrize(
    "message",
    [
        "Secret detected: token='gcntfy-some-test-key-0a0a0a0-1b1b-2c2c-3d3d-4e4e4e4e4e4e' type='cds_canada_notify_api_key' url='https://example.com/cds-snc/some-repo' source='commit'",
        "Secret detected: token='gcntfy-some-test-key-0a0a0a0-1b1b-2c2c-3d3d-4e4e4e4e4e4e' type='cds_canada_notify_api_key' url='https://github.com/dsp-testing/some-repo' source='commit'",
        "Secret detected: token='gcntfy-some-test-key-0a0a0a0-1b1b-2c2c-3d3d-4e4e4e4e4e4e' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/notification-documentation' source='commit'",
        "Secret detected: token='gcntfy-some-test-key-0a0a0a0-1b1b-2c2c-3d3d-4e4e4e4e4e4e' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/notification-documentation' source='commit'",
        "Secret detected: token='gcntfy-github-test-revoked' type='cds_canada_notify_api_key' url='https://example.com/cds-snc/some-repo' source='commit'",
        "Secret detected: token='gcntfy-notify-test-key-0a0a0a0-1b1b-2c2c-3d3d-4e4e4e4e4e4e' type='cds_canada_notify_api_key' url='https://github.com/dry-runs-test/some-repo' source='commit'",
        "Secret detected: token='gcntfy-some-test-key-0000000-0000-0000-0000-000000000000' type='cds_canada_notify_api_key' url='https://whatever.com/cds-snc/some-repo' source='commit'",
    ],
)
def test_lambda_handler_secret_ignored(
    mock_base64, mock_gzip, mock_json_loads, mock_boto3_client, message
):
    mock_json_loads.return_value = {"logEvents": [{"message": message}]}
    event = {"awslogs": {"data": "foo"}}
    lambda_handler(event, None)
    mock_boto3_client.assert_not_called()


@pytest.mark.parametrize(
    "key,expected",
    [
        # Alphanumeric in numeric positions (should be False)
        ("gcntfy-some-test-key-0000a00-0000-0000-0000-000000000000", False),
        ("gcntfy-some-test-key-0000000-00b0-0000-0000-000000000000", False),
        ("gcntfy-some-test-key-0000000-0000-0000-0000-00000000c000", False),
        ("gcntfy-some-test-key-1200000-0000-0000-0000-000000000000", False),
        ("gcntfy-some-test-key-aaaaaaa-bbbb-cccc-dddd-e00000000000", False),
        # All numeric and zeros (should be True)
        ("gcntfy-some-test-key-0000000-0000-0000-0000-000000000000", True),
    ],
)
def test_does_key_contain_all_zeros_alphanumeric(key, expected):
    assert does_key_contain_all_zeros(key) == expected
