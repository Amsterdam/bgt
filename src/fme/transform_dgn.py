import logging

import fme.fme_utils as fme_utils

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


def start_transformation_dgn(min_x, min_y, max_x, max_y):
    """
    calls `aanmaak_dgnNLCS_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation -:> DGN  {min_x} {min_y} {max_x} {max_y}")

    return fme_utils.run_transformation_job(
        'BGT-DGN',
        'aanmaak_dgn_uit_DB_BGT.fmw',
        {"subsection": "REST_SERVICE",
         "FMEDirectives": {},
         "NMDirectives": {"successTopics": [], "failureTopics": []},
         "TMDirectives": {"tag": "linux", "description": "Aanmaak NLCS uit DB"},
         "publishedParameters": [
             {"name": "SourceDataset_POSTGIS", "value": "bgt"},
             {"name": "SourceDataset_POSTGIS_5", "value": "bgt"},
             {"name": "P_OUTPUT_DGN", "value": "$(FME_SHAREDRESOURCE_DATA)DGNv8.zip"},
             {"name": "P_CEL", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/NLCS.cel"]},
             {"name": "P_SEED", "value": "$(FME_SHAREDRESOURCE_DATA)resources/DGNv8_seed.dgn"},
             {"name": "ENVELOPE_MINX", "value": min_x},
             {"name": "ENVELOPE_MINY", "value": min_y},
             {"name": "ENVELOPE_MAXX", "value": max_x},
             {"name": "ENVELOPE_MAXY", "value": max_y},]})
