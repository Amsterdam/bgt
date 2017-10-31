import logging

import fme.fme_utils as fme_utils

log = logging.getLogger(__name__)


def start_transformation_db():
    """
    Calls `inlezen_DB_BGT_uit_citygml.fmw` on FME server

    :rtype: dict[jobid, urltransform]
    """
    log.info("Starting transformation GML -:> db_bgt")

    return fme_utils.run_transformation_job(
        'BGT-DB',
        'inlezen_DB_BGT_uit_citygml.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "DB BGT uit city gml"},
            "publishedParameters": [
                {"name": "DestDataset_POSTGIS_4", "value": "bgt"},
                {"name": "DestDataset_POSTGIS", "value": "bgt"},
                {"name": "CITYGML_IN_ADE_XSD_DOC_CITYGML",
                 "value": ["$(FME_SHAREDRESOURCE_DATA)Import_XSD/imgeo.xsd"]},
                {"name": "SourceDataset_CITYGML",
                 "value": ["$(FME_SHAREDRESOURCE_DATA)Import_GML/*.gml"]}, ]})
