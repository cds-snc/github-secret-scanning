# pylint: disable=missing-docstring,line-too-long
import os
import pytest

from unittest.mock import patch
from utils import helpers


@patch.dict(os.environ, {"MUFFINS": "bananana"}, clear=True)
def test_get_env_var():
    assert helpers.get_env_var("MUFFINS") == "bananana"
    assert helpers.get_env_var("DEFAULT_VALUE", "hello") == "hello"

    with pytest.raises(ValueError):
        helpers.get_env_var("BUELLER")
