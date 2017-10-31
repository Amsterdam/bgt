import logging

import fme.fme_utils as fme_utils

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
