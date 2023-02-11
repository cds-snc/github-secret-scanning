"""
Logging configuration
"""
import logging
import os

LOG_LEVEL = os.getenv("LOG_LEVEL", "DEBUG")

logging.basicConfig(
    format="{'time':'%(asctime)s','name':'%(name)s','level':'%(levelname)s','message':'%(message)s'}",  # pylint: disable=line-too-long
    level=LOG_LEVEL,
)

logger = logging.getLogger(__name__)
