"""
GitHub secret alert
"""

from pydantic import BaseModel  # pylint: disable=no-name-in-module


class Alert(BaseModel):
    "GitHub secret alert"
    token: str
    type: str
    url: str
    source: str
