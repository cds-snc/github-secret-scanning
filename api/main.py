"""
Main API entrypoint
"""
from fastapi import FastAPI
from dotenv import load_dotenv

from routers import alerts, ops
from utils.helpers import get_env_var

load_dotenv()

GITHUB_PUBLIC_KEYS_URL = get_env_var("GITHUB_PUBLIC_KEYS_URL")
GITHUB_TOKEN = get_env_var("GITHUB_TOKEN")

app = FastAPI(
    title="API GitHub Secret Scanning",
    description="API to receive GitHub secret scanning alerts",
    version="1.0.0",
)

app.include_router(alerts.router)
app.include_router(ops.router)
