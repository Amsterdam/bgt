import logging
import socket
import time

import requests

log = logging.getLogger(__name__)


class FMEServer(object):
    def __init__(self, server_name, instance_id, api_token):
        self.api_token = api_token
        self.instance_id = instance_id
        self.server_name = server_name

    def _in_dns(self) -> bool:
        """
        Checks if `self.server_name` is in DNS / name resolves to IP
        :return: bool
        """
        try:
            socket.gethostbyname(self.server_name.split('//')[-1])
            log.debug('DNS is available for server')
            return True
        except:
            log.warn("No DNS available for server")
            return False

    def _headers(self) -> dict:
        """
        Returns the auth header
        :return: dict
        """
        return {'Authorization': 'bearer {FME_SERVER_API}'.format(FME_SERVER_API=self.api_token)}

    def _url(self, path=None) -> str:
        """
        Returns the FME server management uinstance url
        :param path:
        :return:
        """
        return 'https://api.fmecloud.safe.com/v1/instances/{}{}'.format(self.instance_id, path or "")

    def get_status(self) -> str:
        res = requests.get(self._url(), headers=self._headers())
        res.raise_for_status()

        status = res.json()['state']
        log.debug("Current server status: %s", status)
        return status

    def start(self):
        """
        Start the FME server instance
        :return:
        """
        log.info("Starting server %s", self.server_name)
        res = requests.put(self._url("/start"), headers=self._headers())
        res.raise_for_status()

        while self.get_status() in ['PENDING', 'STOPPING']:
            time.sleep(1)

        if self.get_status() == 'RUNNING':
            log.debug("Already running")
            return

        while self.get_status() != 'RUNNING':
            time.sleep(10)

        log.debug("Waiting for DNS availability of server")

        while not self._in_dns():
            time.sleep(2)

        log.info("Server started")

    def stop(self):
        """
        Stop the FME server instance
        :return:
        """
        log.info("Stopping server")
        while self.get_status() in ['PENDING', 'STOPPING']:
            time.sleep(1)

        if self.get_status() != "RUNNING":
            log.debug("Not running, cannot stop")
            return

        res = requests.put(self._url("/pause"), headers=self._headers())
        res.raise_for_status()

        while self.get_status() != 'PAUSED':
            time.sleep(10)

        log.info("Server paused")
