"""
Middleware to validate that the CloudFront header is present
on the request.  This is to ensure that the API is not
directly accessible through the Lambda function URL.
"""

from os import environ
from fastapi import Request
from fastapi.responses import JSONResponse

CLOUDFRONT_HEADER = environ.get("CLOUDFRONT_HEADER", None)


async def check_header(request: Request, call_next):
    "Check if the CloudFront header is present"
    header = request.headers.get("X-CloudFront-Header", None)
    if CLOUDFRONT_HEADER != "localhost" and CLOUDFRONT_HEADER != header:
        return JSONResponse(
            {"status": "ERROR", "message": "Direct access to the API is not allowed"},
            status_code=403,
        )
    return await call_next(request)
