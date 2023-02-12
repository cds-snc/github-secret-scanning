"""
Logging configuration
"""
import logging
import os

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

logging.basicConfig(
    format='{"time":"%(asctime)s","level":"%(levelname)s","message":"%(message)s"}',
    level=LOG_LEVEL,
)

logger = logging.getLogger("api")
