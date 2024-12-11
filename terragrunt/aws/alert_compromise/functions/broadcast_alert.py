import json
import boto3
import gzip
import base64
import os
import re

# ===============================================================================


def lambda_handler(event, context):
    """
    This function is triggered by a CloudWatch Logs subscription filter and
    sends an alert to an SNS topic if a secret is detected in the logs.

    Args:
        event (dict): The event data passed by AWS Lambda.
        context (object): The context object passed by AWS Lambda.

    Returns:
        None
    """
    decoded_event = json.loads(
        gzip.decompress(base64.b64decode(event["awslogs"]["data"]))
    )

    # List of items to ignore as these are from GitHub testing
    ignore_terms = [
        "dsp-testing",
        "example.com",
        "gcntfy-github-test-revoked",
        "cds-snc/notification-documentation",
        "dry-runs-test",
    ]

    # get the notify_api_key from the environment variable
    notify_doc_api_key = os.environ["notify_doc_api_key"]

    # Add the notify_api_key to the ignore_terms list
    ignore_terms.append(notify_doc_api_key)

    print("Starting...")

    for log_event in decoded_event["logEvents"]:
        # get the message from the logs
        message = log_event["message"]
        # Double check that the message received contains a secret
        if "Secret detected:" in message and not any(
            term in message for term in ignore_terms
        ):
            print("Secret has been detected!")
            message_array = re.split(r"\s", message)
            for element in message_array:
                # Retrieve the api_key and the github_repo from the message
                if "token=" in element:
                    token = element
                elif "url=" in element:
                    github_repo = element
                elif "type=" in element:
                    type = element
                elif "source=" in element:
                    source = element

            # Check if the token contains all zeros
            if token and does_key_contain_all_zeros(token):
                print("Key ignored as it contains all zeros.")
                continue

            body = f"API Key with value {token}, {type} and {source} has been detected in {github_repo}!"  # noqa: E501
            # Publish the alert to the SNS topic
            print("Publishing to SNS topic")
            boto3.client("sns").publish(
                TargetArn=os.environ["sns_topic_arn"],
                Message=body,
                Subject=os.environ["subject"],
            )
            print("Alert published for one event...")
    print("Done processing all events...")


def does_key_contain_all_zeros(key):
    # Split the key by the delimiter (e.g., '-')
    parts = key.split('-')[-5:]

    # Check if all parts that are numeric are zeros
    return all(part == '0' * len(part) for part in parts if part.isdigit())
