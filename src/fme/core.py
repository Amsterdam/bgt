import json
import logging
import sys
import urllib.parse
import urllib.request
from datetime import datetime
from zipfile import ZipFile

import requests

import bgt_setup
import fme.comparison as fme_comparison
import fme.fme_server as fme_server
import fme.fme_utils as fme_utils
import fme.sql_utils as fme_sql_utils
import endproduct.bld_database as bld_database

from objectstore.objectstore import ObjectStore

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


def start_transformation_gebieden():
    """
    calls `inlezen_gebieden_uit_Shape_en_WFS.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation")
    return fme_utils.run_transformation_job(
        'BGT-DB',
        'inlezen_gebieden_uit_Shape_en_WFS.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "DB BGT kaartbladen"},
            "publishedParameters": [{"name": "DestDataset_POSTGIS_4", "value": "bgt"},
                                    {"name": "bron_BGT_kaartbladen",
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_kaartbladen/BGT_kaartbladen.shp"]}]})


def start_transformation_db():
    """
    calls `inlezen_DB_BGT_uit_citygml.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation")
    return fme_utils.run_transformation_job(
        'BGT-DB',
        'inlezen_DB_BGT_uit_citygml.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "DB BGT uit city gml"
                             },
            "publishedParameters": [{"name": "DestDataset_POSTGIS_4", "value": "bgt"},
                                    {"name": "CITYGML_IN_ADE_XSD_DOC_CITYGML",
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_XSD/imgeo.xsd"]},
                                    {"name": "SourceDataset_CITYGML",
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_GML/*.gml"]}, ]})


def start_transformation_dgn():
    """
    calls `aanmaak_dgnNLCS_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation")

    # update data in `Export shapes` and  `Export_Shapes_Totaalgebied` directories
    return fme_utils.run_transformation_job(
        'BGT-DGN',
        'aanmaak_dgn_uit_DB_BGT.fmw',
        {"subsection": "REST_SERVICE",
         "FMEDirectives": {},
         "NMDirectives": {"successTopics": [], "failureTopics": []},
         "TMDirectives": {"tag": "linux", "description": "Aanmaak NLCS uit DB"},
         "publishedParameters": [{"name": "SourceDataset_POSTGIS", "value": "bgt"},
                                 {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
                                 {"name": "OUTPUT_DGN", "value": "$(FME_SHAREDRESOURCE_DATA)/DGN.zip"},
                                 {"name": "P_CEL", "value": "$(FME_SHAREDRESOURCE_DATA)/BGT_NLCS.cel"},
                                 {"name": "P_SEED", "value": "$(FME_SHAREDRESOURCE_DATA)/NLCS-GBKAseed_v8.dgn"}]})


def start_transformation_nlcs():
    """
    calls `aanmaak_esrishape_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation")
    # update data in `Export shapes` and  `Export_Shapes_Totaalgebied` directories
    return fme_utils.run_transformation_job(
        'BGT-DGN',
        'aanmaak_dgnNLCS_uit_DB_BGT.fmw',
        {"subsection": "REST_SERVICE",
         "FMEDirectives": {},
         "NMDirectives": {"successTopics": [], "failureTopics": []},
         "TMDirectives": {"tag": "linux", "description": "Aanmaak NLCS uit DB"},
         "publishedParameters": [{"name": "SourceDataset_POSTGIS", "value": "bgt"},
                                 {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
                                 {"name": "P_CEL", "value": "$(FME_SHAREDRESOURCE_DATA)/BGT_NLCS.cel"},
                                 {"name": "p_font", "value": "$(FME_SHAREDRESOURCE_DATA)/NLCS-ISO.ttf"},
                                 {"name": "DestDataset_DGNV8", "value": "$(FME_SHAREDRESOURCE_DATA)/NLCS.zip"},
                                 {"name": "SEED_FILE_DGNV8", "value": "$(FME_SHAREDRESOURCE_DATA)/NLCS-Seed2d.dgn"}]})


def start_transformation_shapes():
    """
    calls `aanmaak_esrishape_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation")

    # update data in `Export shapes` and  `Export_Shapes_Totaalgebied` directories
    return fme_utils.run_transformation_job(
        'BGT-SHAPES',
        'aanmaak_esrishape_csv_zip.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "Aanmaak Shapes uit DB"},
            "publishedParameters": [
                {"name": "SourceDataset_POSTGIS", "value": "bgt"},
                {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
                {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)/shp_gebied.zip"},
                {"name": "DestDataset_ESRISHAPE3", "value": "$(FME_SHAREDRESOURCE_DATA)/shp_totaal.zip"},
                {"name": "DestDataset_CSV", "value": "$(FME_SHAREDRESOURCE_DATA)/csv_gebieden.zip"},
                {"name": "DestDataset_CSV_3", "value": "$(FME_SHAREDRESOURCE_DATA)/csv_totaal.zip"}]})


def start_test_transformation():
    """
    calls `aanmaak_esrishape_test_zip.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    return fme_utils.run_transformation_job(
        'BGT-SHAPES',
        'aanmaak_esrishape_test_zip.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "Aanmaak Shapes uit DB"},
            "publishedParameters": [
                {"name": "SourceDataset_POSTGIS", "value": "bgt"},
                {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
                {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)/TestExport.zip"},
                {"name": "DestDataset_ESRISHAPE3", "value":
                    "$(FME_SHAREDRESOURCE_DATA)/TestExportTotaalgebied.zip"}]})


def upload_bgt_source_zip():
    """
    Upload the PDOK/bgt source zip to the objecstore
    :return:
    """
    store = ObjectStore('BGT')
    log.info("Upload BGT source zip")
    content = open('extract_bgt.zip', 'rb').read()

    timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    filename = 'bron-gml/extract_bgt-{}.zip'.format(timestamp)
    store.put_to_objectstore(filename, content, 'application/octet-stream')
    log.info("Uploaded {} to objectstore BGT/bron-gml".format(filename))


def upload_resulting_shapes_to_objectstore():
    """
    Uploads the resulting shapes to BGT objectstore
    :return:
    """
    store = ObjectStore('BGT')
    log.info("Upload resulting shapes to BGT objectstore")

    files = ['shp_gebied.zip', 'shp_totaal.zip', 'csv_gebieden.zip', 'csv_totaal.zip']

    for path in files:
        log.info("Download {} for storing in objectstore".format(path))
        download_url = '{FME_SERVER}{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/{DIR}?detail=low' \
                       'createDirectories=false&detail=low&overwrite=false'.format(
            DIR=path, FME_SERVER=bgt_setup.FME_SERVER, url_connect="/fmerest/v2/resources/connections")
        res = requests.get(download_url, headers=fme_utils.fme_api_auth())
        res.raise_for_status()
        if res.status_code == 200:
            res_name = path.split('/')[-1].split('.')
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            store.put_to_objectstore('shapes/{}-{}.{}'.format(res_name[0], timestamp, res_name[-1]),
                                     res.content,
                                     res.headers['Content-Type'])
            store.put_to_objectstore('shapes/{}-latest'.format(path.split('/')[-1]),
                                     res.content,
                                     res.headers['Content-Type'])
            log.info("Uploaded {} to objectstore BGT/shapes".format(res_name))
    log.info("Uploaded resulting shapes to BGT objectstore")


def unzip_pdok_file():
    """
    Unzip the extract_bgt.zip file into the `/tmp/data` directory
    :return:
    """
    log.info("Start unzipping contents")
    with ZipFile('extract_bgt.zip', 'r') as myzip:
        myzip.extractall('/tmp/data/')
    log.info("Unzip complete")
    return 0


def pdok_url():
    """
    Returns the PDOK url for `now`
    :return:
    """
    pdok_extract = "https://www.pdok.nl/download/service/extract.zip"
    tiles = {
        "layers": [
            {"aggregateLevel": 0,
             "codes": [
                 38121, 38115, 38120, 38077, 38076, 38078, 38079, 38421, 38423, 38429, 38431, 38474, 38475, 38478,
                 38479, 38490, 38491, 38494, 38516, 38518, 38690, 38525, 38696, 38688, 38666, 38667, 38670, 38671,
                 38682, 38680, 38681, 38675, 38673, 38331, 38329, 38323, 38321, 38299, 38298, 38287, 38285, 38284,
                 38281, 38275, 38274, 38103, 38109, 38280, 38108, 38105, 38104, 38093, 38092, 38094, 38116, 38674,
                 38672, 38330, 38328, 38317, 38476, 38477, 38488, 38489, 38492, 38493, 38495, 38664, 38665, 38668,
                 38517, 38466, 38467, 38118, 38119, 38117, 38095, 38106, 38107, 38110, 38111, 38282, 38283, 38316,
                 38319, 38472, 38464, 38465, 38122, 38470, 38471, 38468, 38469, 38126, 38127, 38124, 38125, 38482,
                 38480, 38138, 38136, 38483, 38481, 38139, 38140, 38142, 38484, 38486, 38487, 38485, 38143, 38141,
                 38134, 38132, 38133, 38135, 38306, 38304, 38312, 38314, 38130, 38128, 38129, 38131, 38137, 38313,
                 38307, 38308, 38310, 38315, 38318, 38656, 38658, 38659, 38657, 38662, 38660, 38661, 38663, 38311,
                 38309, 38320, 38322]}]}
    tiles_as_json = json.dumps(tiles)
    datum = datetime.now().strftime("%d-%m-%Y")
    return pdok_extract + "?" + urllib.parse.urlencode({
        "extractset": "citygml",
        "excludedtypes": "plaatsbepalingspunt",
        "history": "false",
        "enddate": datum,
        "tiles": tiles_as_json})


def is_bgt_updated():
    """
    Check new pdok.nl functionality / for th emoment we get 500 server errors form pdok.
    """
    res = requests.head(pdok_url())
    print(res)


def download_bgt():
    """
    Downloads the PDOK files to extract_bgt.zip and calls unzip_pdok_file()
    :return: 0
    """
    target = "extract_bgt.zip"

    log.info("Starting download from %s to %s", pdok_url(), target)

    def progress(count, block_size, total_size):
        approximate = ''
        if total_size == -1:
            # evil PDOK not telling us the content size :-(
            # educated guess is ~350Mb
            total_size = 350 * 1024 * 1024
            approximate = '~'

        percentage = float(count * block_size * 100.0 / total_size)
        log.info("%s%2.2f%%", approximate, percentage)

    urllib.request.urlretrieve(pdok_url(), target, reporthook=progress)
    unzip_pdok_file()
    log.info("Download complete")
    return 0


if __name__ == '__main__':
    logging.basicConfig(level='DEBUG')
    logging.getLogger('requests').setLevel('WARNING')

    server_manager = fme_server.FMEServer(bgt_setup.FME_SERVER, bgt_setup.INSTANCE_ID, bgt_setup.FME_SERVER_API)

    log.info("Starting script, current server status is %s", server_manager.get_status())

    loc_pgsql = fme_sql_utils.SQLRunner(port='5401', dbname='gisdb', user='dbuser')
    fme_pgsql = fme_sql_utils.SQLRunner(host=bgt_setup.FME_SERVER.split('//')[-1],
                                        dbname='gisdb', user='dbuser', password=bgt_setup.FME_DBPASS)

    download_bgt()
    try:
        # start the fme server
        server_manager.start()
        fme_pgsql.run_sql_script("{app}/source_sql/020_create_schema.sql".format(app=bgt_setup.SCRIPT_ROOT))

        # upload the GML files and FMW scripts
        fme_utils.upload('/tmp/data', 'resources/connections', 'Import_GML', '*.*', recreate_dir=True)
        fme_utils.upload_repository(
            '{app}/source_data/fme'.format(app=bgt_setup.SCRIPT_ROOT), 'repositories', 'BGT-DB', '*.*',
            register_fmejob=True)

        # When setting up a new FME instance a
        # DB Connection in FMECLoud needs to be set manually - NOT POSSIBLE IN CURRENT API VERSION
        fme_utils.upload('{app}/source_data/xsd'.format(app=bgt_setup.SCRIPT_ROOT), 'resources/connections',
                         'Import_XSD',
                         'imgeo.xsd')
        fme_utils.upload('{app}/source_data/bron_shapes'.format(app=bgt_setup.SCRIPT_ROOT), 'resources/connections',
                         'Import_kaartbladen',
                         '*.*')
        try:
            fme_utils.wait_for_job_to_complete(start_transformation_db())
            fme_utils.wait_for_job_to_complete(start_transformation_gebieden())
        except Exception as e:
            logging.exception("Exception during FME transformation {}".format(e))
            sys.exit(1)

        fme_pgsql.run_sql_script("{app}/source_sql/060_aanmaak_tabellen_BGT.sql".format(app=bgt_setup.SCRIPT_ROOT))

        # aanmaak db-views shapes_bgt
        fme_pgsql.run_sql_script("{app}/source_sql/090_aanmaak_DB_views_BGT.sql".format(app=bgt_setup.SCRIPT_ROOT))
        fme_pgsql.run_sql_script("{app}/source_sql/090_aanmaak_DB_views_IMGEO.sql".format(app=bgt_setup.SCRIPT_ROOT))

        # upload shapes fmw scripts naar reposiory
        fme_utils.upload_repository(
            '{app}/source_data/aanmaak_producten_bgt'.format(app=bgt_setup.SCRIPT_ROOT),
            'BGT-SHAPES', '*.*', register_fmejob=True)

        # upload resources
        fme_utils.upload_repository(
            '{app}/source_data/aanmaake_producten_bgt/resource'.format(
                app=bgt_setup.SCRIPT_ROOT), 'repositories', 'BGT-DGN', '*.*', register_fmejob=True)

        # run the `aanmaak_esrishape_uit_DB_BGT` script
        try:
            fme_utils.wait_for_job_to_complete(start_transformation_shapes())
        except Exception as e:
            logging.exception("Exception during FME transformation to shapes {}".format(e))
            sys.exit(1)

        # upload the resulting shapes an the source GML zip to objectstore
        upload_resulting_shapes_to_objectstore()
        upload_bgt_source_zip()

        try:
            fme_utils.wait_for_job_to_complete(start_transformation_dgn())
        except Exception as e:
            logging.exception("Exception during FME transformation to dgn {}".format(e))

        try:
            fme_utils.wait_for_job_to_complete(start_transformation_nlcs())
        except Exception as e:
            logging.exception("Exception during FME transformation to dgn {}".format(e))

        # import controle db vanuit /tmp/data/*.gml
        loc_pgsql.import_gml_control_db()

        # import csv / mapping db
        loc_pgsql.import_csv_fixture('../app/source_data/075_mapping.csv', 'imgeo_controle.mapping_gml_db')

        # comparisons FKA: 040...
        fme_comparison.compare_before_after_counts_csv()

        # comparisons FKA 080...
        fme_comparison.create_comparison_data()

        # build final database
        bld_database.bld_sql_db(loc_pgsql)

    except Exception as e:
        log.exception("Could not process server jobs {}".format(e))
    finally:
        # server_manager.stop()
        sys.exit(0)
