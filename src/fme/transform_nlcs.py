import json
import logging
from datetime import datetime
from zipfile import ZipFile

import os
import requests

import bgt_setup
import fme.fme_utils as fme_utils
from objectstore.objectstore import ObjectStore

log = logging.getLogger(__name__)


def start_transformation_nlcs_chunk(min_x, min_y, max_x, max_y):
    """
    calls `aanpassen.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info(f"Starting transformation -:> NLCS {min_x} {min_y} {max_x} {max_y}")

    return fme_utils.run_transformation_job(
        'BGT-DGN',
        'aanmaak_dgnNLCS_uit_DB_BGT.fmw',
        {"subsection": "REST_SERVICE",
         "FMEDirectives": {},
         "NMDirectives": {"successTopics": [], "failureTopics": []},
         "TMDirectives": {"tag": "linux", "description": "Aanmaak NLCS uit DB"},
         "publishedParameters": [
             {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
             {"name": "p_font", "value": "$(FME_SHAREDRESOURCE_DATA)resources/NLCS-ISO.ttf"},
             {"name": "DestDataset_DGNV8", "value": "$(FME_SHAREDRESOURCE_DATA)DGNv8_vlakken_NLCS"},
             {"name": "DestDataset_DGNV8_5", "value": "$(FME_SHAREDRESOURCE_DATA)DGNv8_lijnen_NLCS"},
             {"name": "P_CEL", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/NLCS.cel"]},
             {"name": "SEED_vlakken_DGNV8", "value": "$(FME_SHAREDRESOURCE_DATA)resources/NLCSvlakken_seed.dgn"},
             {"name": "SourceDataset_CSV", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/BGT_prioriteit.csv"]},
             {"name": "SEED_lijnen_DGNv8", "value": "$(FME_SHAREDRESOURCE_DATA)resources/NLCSlijnen_seed.dgn"},
             {"name": "ENVELOPE_MINX", "value": min_x},
             {"name": "ENVELOPE_MINY", "value": min_y},
             {"name": "ENVELOPE_MAXX", "value": max_x},
             {"name": "ENVELOPE_MAXY", "value": max_y}, ]})


def upload_nlcs_vlakken_files():
    log.info("ZIP and upload NLCS vlakken products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_INSTANCE_API_TOKEN}'.format(FME_INSTANCE_API_TOKEN=bgt_setup.FME_INSTANCE_API_TOKEN),
    }
    url = '{FME_BASE_URL}/fmerest/v2/resources/connections/' \
      'FME_SHAREDRESOURCE_DATA/filesys/{folder}?' \
      'accept=json&depth=1&detail=low'.format(FME_BASE_URL=bgt_setup.FME_BASE_URL, folder='DGNv8_vlakken_NLCS/BGT_NLCS_V')

    if not os.path.exists('/tmp/data'):
        os.makedirs('/tmp/data')
    zip_filename = '/tmp/data/NLCS_vlakken.zip'
    zf = ZipFile(zip_filename, mode='w')

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        try:
            for entry in json.loads(response.content)['contents']:
                filename = entry['name']
                path = entry['path']
                upload_path = "NLCS_vlakken"
                log.info(f"Upload file {upload_path}/{filename}")
                file_content = fme_utils.download(f'{path}/{filename}', text=False)
                zf.writestr(filename, file_content)
        finally:
            zf.close()

        with open(zip_filename, mode='rb') as f:
            log.info("store latest")
            store.put_to_objectstore(
                'BGT_Kaartbladen/NLCS_Vlak/NLCS_vlakken-latest.zip', f.read(), 'application/octet-stream')

        os.remove(zip_filename)
    else:
        response.raise_for_status()
    log.info("ZIP and upload NLCS vlakken products to BGT objectstore done")


def upload_nlcs_lijnen_files():
    log.info("ZIP and upload NLCS lijnen products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_INSTANCE_API_TOKEN}'.format(FME_INSTANCE_API_TOKEN=bgt_setup.FME_INSTANCE_API_TOKEN),
    }
    url = '{FME_BASE_URL}/fmerest/v2/resources/connections/' \
          'FME_SHAREDRESOURCE_DATA/filesys/{folder}?' \
          'accept=json&depth=1&detail=low'.format(FME_BASE_URL=bgt_setup.FME_BASE_URL, folder='DGNv8_lijnen_NLCS/BGT_NLCS_L')

    if not os.path.exists('/tmp/data'):
        os.makedirs('/tmp/data')
    zip_filename = '/tmp/data/NLCS_lijnen.zip'
    zf = ZipFile(zip_filename, mode='w')
    upload_path = "NLCS_lijnen"

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        try:
            for entry in json.loads(response.content)['contents']:
                filename = entry['name']
                path = entry['path']
                log.info(f"Upload file {upload_path}/{filename}")
                file_content = fme_utils.download(f'{path}/{filename}', text=False)
                zf.writestr(filename, file_content)
        finally:
            zf.close()

        with open(zip_filename, mode='rb') as f:
            log.info("store latest")
            store.put_to_objectstore(
                'BGT_Kaartbladen/NLCS_Lijn/NLCS_lijnen-latest.zip', f.read(), 'application/octet-stream')

        os.remove(zip_filename)
    else:
        response.raise_for_status()
    log.info("ZIP and upload NLCS lijnen products to BGT objectstore done")
