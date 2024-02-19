import pytest
from unittest import mock
from broadcast_alert import lambda_handler


@mock.patch("broadcast_alert.boto3.client")
@mock.patch("broadcast_alert.json.loads")
@mock.patch("broadcast_alert.gzip")
@mock.patch("broadcast_alert.base64")
@mock.patch(
    "os.environ",
    {
        "sns_topic_arn": "fake_topic_arn",
        "subject": "Fake Subject",
        "notify_test_api_key": "gcntfy-notify-test-key-11111",
    },
)
def test_lambda_handler_secret_detected(
    mock_base64, mock_gzip, mock_json_loads, mock_boto3_client
):
    mock_json_loads.return_value = {
        "logEvents": [
            {
                "message": "Secret detected: token='gcntfy-some-test-key-00000' type='cds_canada_notify_api_key' url='https://github.com/cds-snc/some-repo' source='commit'"
            }
        ]
    }
    event = {"awslogs": {"data": "foo"}}

    lambda_handler(event, None)
    mock_boto3_client.assert_called_once_with("sns")
    mock_boto3_client.return_value.publish.assert_called_once_with(
        TargetArn="fake_topic_arn",
        Message="API Key with value token='gcntfy-some-test-key-00000', type='cds_canada_notify_api_key' and source='commit' has been detected in url='https://github.com/cds-snc/some-repo'!",
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
        "notify_test_api_key": "gcntfy-notify-test-key-11111",
    },
)
@pytest.mark.parametrize(
    "message",
    [
        "Secret detected: token='gcntfy-some-test-key-00000' type='cds_canada_notify_api_key' url='https://example.com/cds-snc/some-repo' source='commit'",
        "Secret detected: token='gcntfy-some-test-key-00000' type='cds_canada_notify_api_key' url='https://github.com/dsp-testing/some-repo' source='commit'",
        "Secret detected: token='gcntfy-github-test-revoked' type='cds_canada_notify_api_key' url='https://example.com/cds-snc/some-repo' source='commit'",
        "Secret detected: token='gcntfy-notify-test-key-11111' type='cds_canada_notify_api_key' url='https://whatever.com/cds-snc/some-repo' source='commit'",
    ],
)
def test_lambda_handler_secret_ignored(
    mock_base64, mock_gzip, mock_json_loads, mock_boto3_client, message
):
    mock_json_loads.return_value = {"logEvents": [{"message": message}]}
    event = {"awslogs": {"data": "foo"}}
    lambda_handler(event, None)
    mock_boto3_client.assert_not_called()
