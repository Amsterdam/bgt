import logging
from datetime import datetime

import fme.fme_utils as fme_utils
from objectstore.objectstore import ObjectStore

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


def start_transformation_gebieden():
    """
    calls `inlezen_gebieden_uit_Shape_en_WFS.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation gebieden shape & wms -:> db_bgt")
    return fme_utils.run_transformation_job(
        'BGT-DB',
        'inlezen_gebieden_uit_Shape_en_WFS.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "DB BGT kaartbladen"},
            "publishedParameters": [{"name": "DestDataset_POSTGIS_4", "value": "bgt"},
                                    {"name": "bron_BGT_kaartbladen", "value": ["$(FME_SHAREDRESOURCE_DATA)Import_kaartbladen/BGT_kaartbladen.shp"]},
                                    {"name": "DestDataset_ESRISHAPE", "value": ["$(FME_SHAREDRESOURCE_DATA)Kaartbladindeling"]},
                                    {"name": "DestDataset_DGNV8", "value": ["$(FME_SHAREDRESOURCE_DATA)Kaartbladindeling/PDOK_Indeling.dgn"]}]})


def upload_gebieden():
    log.info("Upload gebieden to BGT objectstore")

    store = ObjectStore('BGT')
    filenames = {
        'BGT_Gebiedsindeling{timestamp}.dbf',
        'BGT_Gebiedsindeling{timestamp}.prj',
        'BGT_Gebiedsindeling{timestamp}.shp',
        'BGT_Gebiedsindeling{timestamp}.shx',
        'PDOK_Indeling{timestamp}.dgn',
    }
    download_folder = 'Gebieden'
    timestamp = datetime.now().strftime('-%Y%m%d%H%M%S')
    for filename in filenames:
        download_path = "{download_folder}/{filename}".format(
            download_folder=download_folder,
            filename=filename
        ).format(
            timestamp=''
        )
        log.info(f"Download file {download_path}")
        file_content = fme_utils.download(download_path, text=False)
        log.info(f"Upload {filename}")
        upload_path_template = f'products/{filename}'
        store.put_to_objectstore(
            upload_path_template.format(timestamp=timestamp),
            file_content,
            'application/octet-stream'
        )
        store.put_to_objectstore(
            upload_path_template.format(timestamp='-latest'),
            file_content,
            'application/octet-stream'
        )
