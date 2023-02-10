"""
Helper functions that need a home.
"""
from os import environ


def get_env_var(env_var_name: str, default_value: str = "") -> str:
    "Get environment variable value and fail if it does not exist."
    value = environ.get(env_var_name, default_value)
    if value.strip() == "":
        raise ValueError(f"{env_var_name} environment variable is empty")
    return value
