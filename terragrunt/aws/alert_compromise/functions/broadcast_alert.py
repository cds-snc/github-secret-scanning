import json
import boto3
import gzip
import base64
import os
import re

#===============================================================================

def lambda_handler(event, context):
    """
    This function is triggered by a CloudWatch Logs subscription filter and sends an alert to an SNS topic if a secret is detected in the logs.

    Args:
        event (dict): The event data passed by AWS Lambda.
        context (object): The context object passed by AWS Lambda.

    Returns:
        None
    """
    decoded_event = json.loads(gzip.decompress(base64.b64decode(event['awslogs']['data'])))
    message = decoded_event['logEvents'][0]['message']
    # Double check that the message received contains a secret
    if ("Secret detected:" in message ):
        message_array = re.split("\s", message)
        for element in message_array:
            # Retrieve the api_key and the github_repo from the message
            if "token=" in element: 
                token = element
            if "url=" in element:
                github_repo = element
        body = f"API Key with value {token} has been detected in {github_repo}! This key needs to be revoked."
        # Publish the alert to the SNS topic 
        boto3.client('sns').publish(
            TargetArn = os.environ['sns_topic_arn'],
            Message = body,
            Subject = os.environ['subject']
            )