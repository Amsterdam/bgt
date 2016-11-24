import pytest
import logging
from unittest.mock import MagicMock, patch
from ..bld_database import get_name

log = logging.getLogger(__name__)


# @pytest.fixture
# def fme_server():
#     s = FMEServer(
#         'http://localhost',
#         '2222',
#         '95b4bd5265c03482n2cb481bf37f29e7a545ab88')
#     s.get_status = MagicMock(return_value='RUNNING')
#     return s


def test_get_name():
    a = get_name('/endproduct/tests/fixtures/bgt_test.zip')
    print(a)