import json
import boto3
import gzip
import base64
import os
import re

# ===============================================================================


def lambda_handler(event, context):
    """
    This function is triggered by a CloudWatch Logs subscription filter and sends an alert to an SNS topic if a secret is detected in the logs.

    Args:
        event (dict): The event data passed by AWS Lambda.
        context (object): The context object passed by AWS Lambda.

    Returns:
        None
    """
    decoded_event = json.loads(gzip.decompress(
        base64.b64decode(event['awslogs']['data'])))
    message = decoded_event['logEvents'][0]['message']


    print("Starting...")
    # Double check that the message received contains a secret
    if ("Secret detected:" in message and "dsp-testing" not in message):
        print("Secret has been tetected!")
        message_array = re.split("\s", message)
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
        body = f"API Key with value {token}, {type} and {source} has been detected in {github_repo}!"
        # Publish the alert to the SNS topic
        print("Publishing to SNS topic")
        boto3.client('sns').publish(
            TargetArn=os.environ['sns_topic_arn'],
            Message=body,
            Subject=os.environ['subject']
        )
        print("Done...")
