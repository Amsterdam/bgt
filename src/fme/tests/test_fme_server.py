import pytest
import logging
from unittest.mock import MagicMock, patch
from ..fme_server import FMEServer

log = logging.getLogger(__name__)


@pytest.fixture
def fme_server():
    s = FMEServer(
        'http://localhost',
        '2222',
        '95b4bd5265c03482n2cb481bf37f29e7a545ab88')
    s.get_status = MagicMock(return_value='RUNNING')
    return s


def test_in_dns(fme_server):
    assert fme_server._in_dns()


def test_headers(fme_server):
    assert {'Authorization': 'bearer 95b4bd5265c03482n2cb481bf37f29e7a545ab88'} == fme_server._headers()


def test_url(fme_server):
    assert 'https://api.fmecloud.safe.com/v1/instances/2222' == fme_server._url()
    assert 'https://api.fmecloud.safe.com/v1/instances/2222/test/1/test/2' == fme_server._url('/test/1/test/2')


def test_get_status(fme_server):
    assert 'RUNNING' == fme_server.get_status()


def test_start(fme_server):
    with patch.object(fme_server, 'start') as mocked_start:
        fme_server.start()
        mocked_start.assert_called_once_with()


def test_stop(fme_server):
    with patch.object(fme_server, 'stop') as mocked_stop:
        fme_server.stop()
        mocked_stop.assert_called_once_with()
