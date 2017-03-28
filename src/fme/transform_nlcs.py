import json
import logging
from datetime import datetime
from zipfile import ZipFile

import os
import requests

import bgt_setup
import fme.fme_utils as fme_utils
from objectstore.objectstore import ObjectStore

logging.basicConfig(level=logging.INFO)
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
             {"name": "SourceDataset_POSTGIS", "value": "bgt"},
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
    log.info("ZIP and upload DGNv8 vlakken products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    url = 'https://bgt-vicrea-amsterdam-2016.fmecloud.com/fmerest/v2/resources/connections/' \
          'FME_SHAREDRESOURCE_DATA/filesys/DGNv8_vlakken_NLCS/BGT_NLCS_V?accept=json&depth=1&detail=low'

    zip_filename = '/tmp/data/DGNv8_vlakken.zip'
    zf = ZipFile(zip_filename, mode='w')

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        try:
            for entry in json.loads(response.content)['contents']:
                filename = entry['name']
                path = entry['path']
                upload_path = "DGNv8_vlakken"
                log.info(f"Upload file {upload_path}/{filename}")
                file_content = fme_utils.download(f'{path}/{filename}', text=False)
                zf.writestr(filename, file_content)
        finally:
            zf.close()

        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        with open(zip_filename, mode='rb') as f:
            store.put_to_objectstore(
                'products/DGNv8_vlakken-latest.zip', f.read(), 'application/octet-stream')
            store.put_to_objectstore(
                f'products/DGNv8_vlakken-{timestamp}.zip', f.read(), 'application/octet-stream')

        os.remove(zip_filename)
    log.info("ZIP and upload DGNv8 vlakken products to BGT objectstore done")


def upload_nlcs_lijnen_files():
    log.info("ZIP and upload DGNv8 lijnen products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    url = 'https://bgt-vicrea-amsterdam-2016.fmecloud.com/fmerest/v2/resources/connections/' \
          'FME_SHAREDRESOURCE_DATA/filesys/DGNv8_lijnen_NLCS/BGT_NLCS_L?accept=json&depth=1&detail=low'

    if not os.path.exists('/tmp/data'):
        os.makedirs('/tmp/data')
    zip_filename = '/tmp/data/DGNv8_lijnen.zip'
    zf = ZipFile(zip_filename, mode='w')
    upload_path = "DGNv8_lijnen"

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

        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        with open(zip_filename, mode='rb') as f:
            file_content = f.read()
            store.put_to_objectstore(
                'products/DGNv8_lijnen-latest.zip', file_content, 'application/octet-stream')
            store.put_to_objectstore(
                f'products/DGNv8_lijnen-{timestamp}.zip', file_content, 'application/octet-stream')

        os.remove(zip_filename)
    log.info("ZIP and upload DGNv8 lijnen products to BGT objectstore done")