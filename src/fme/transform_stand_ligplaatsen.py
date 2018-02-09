import logging

import fme.fme_utils as fme_utils

log = logging.getLogger(__name__)


def start_transformation_stand_ligplaatsen():
    """
    calls `SPS_LPS2postgres.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation stand- en ligplaatsen =:> db_bgt")
    return fme_utils.run_transformation_job(
        'BGT-DB',
        'SPS_LPS2postgres.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "Stand- en ligplaatsen -> DB"},
            "publishedParameters": [
                {"name": "SourceDataset_WFS", "value": "https://map.data.amsterdam.nl:443/maps/bag"},
                {"name": "_API_PAGESIZE", "value": "3000"},
                {"name": "DestDataset_POSTGIS_5", "value": "bgt"},
                {"name": "DestDataset_POSTGIS_7", "value": "bgt"}]})
