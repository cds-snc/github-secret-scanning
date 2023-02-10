from utils import helpers

from unittest.mock import patch

import os
import pytest


@patch.dict(os.environ, {"MUFFINS": "bananana"}, clear=True)
def test_get_env_var():
    assert helpers.get_env_var("MUFFINS") == "bananana"
    assert helpers.get_env_var("DEFAULT_VALUE", "hello") == "hello"

    with pytest.raises(ValueError):
        helpers.get_env_var("BUELLER")
