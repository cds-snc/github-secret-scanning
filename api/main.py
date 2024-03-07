"""
Main API entrypoint
"""

from fastapi import FastAPI
from mangum import Mangum
from starlette.middleware.base import BaseHTTPMiddleware
from routers import alerts, ops
from middleware.cloudfront import check_header

app = FastAPI(
    title="GitHub Secret Scanning Alerts API",
    description="Receives alerts from GitHub when they detect a secret in a repository",
    version="1.0.0",
)

app.include_router(alerts.router)
app.include_router(ops.router)
app.add_middleware(BaseHTTPMiddleware, dispatch=check_header)

handler = Mangum(app)
