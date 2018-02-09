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


def start_transformation_dgn(min_x, min_y, max_x, max_y):
    """
    calls `aanmaak_dgnNLCS_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info(f"Starting transformation -:> DGN  {min_x} {min_y} {max_x} {max_y}")
    return fme_utils.run_transformation_job(
        'BGT-DGN',
        'aanmaak_dgn_uit_DB_BGT.fmw',
        {"subsection": "REST_SERVICE",
         "FMEDirectives": {},
         "NMDirectives": {"successTopics": [], "failureTopics": []},
         "TMDirectives": {"tag": "linux", "description": "Aanmaak NLCS uit DB"},
         "publishedParameters": [
             {"name": "SourceDataset_POSTGIS_5", "value": "bgt"},
             {"name": "P_OUTPUT_DGN", "value": "$(FME_SHAREDRESOURCE_DATA)DGNv8"},
             {"name": "P_CEL", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/NLCS.cel"]},
             {"name": "P_SEED", "value": "$(FME_SHAREDRESOURCE_DATA)resources/DGNv8_seed.dgn"},
             {"name": "ENVELOPE_MINX", "value": min_x},
             {"name": "ENVELOPE_MINY", "value": min_y},
             {"name": "ENVELOPE_MAXX", "value": max_x},
             {"name": "ENVELOPE_MAXY", "value": max_y}, ]})


def upload_dgn_files():
    log.info("ZIP and upload DGNv8 products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    url = 'https://bgt-vicrea-amsterdam-2016.fmecloud.com/fmerest/v2/resources/connections/' \
          'FME_SHAREDRESOURCE_DATA/filesys/DGNv8?accept=json&depth=1&detail=low'
    if not os.path.exists('/tmp/data'):
        os.makedirs('/tmp/data')
    zip_filename = '/tmp/data/DGNv8_DGN.zip'
    zf = ZipFile(zip_filename, mode='w')

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        try:
            for entry in json.loads(response.content)['contents']:
                filename = entry['name']
                path = entry['path']
                upload_path = "DGNv8_DGN"
                log.info(f"Upload file {upload_path}/{filename}")
                file_content = fme_utils.download(f'{path}/{filename}', text=False)
                zf.writestr(filename, file_content)
        finally:
            zf.close()

        with open(zip_filename, mode='rb') as f:
            store.put_to_objectstore(
                'BGT_Kaartbladen/DGNv8/DGNv8-latest.zip', f.read(), 'application/octet-stream')

        os.remove(zip_filename)
    else:
        response.raise_for_status()
    log.info("ZIP and upload DGNv8 products to BGT objectstore done")
