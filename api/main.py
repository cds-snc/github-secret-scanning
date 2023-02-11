"""
Main API entrypoint
"""
from fastapi import FastAPI
from routers import alerts, ops


app = FastAPI(
    title="API GitHub Secret Scanning",
    description="API to receive GitHub secret scanning alerts",
    version="1.0.0",
)

app.include_router(alerts.router)
app.include_router(ops.router)
