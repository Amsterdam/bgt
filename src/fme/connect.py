import json
import logging
import subprocess
import sys
import urllib.parse
import urllib.request
from datetime import datetime
from zipfile import ZipFile
from objectstore.objectstore import ObjectStore
import requests
from fme.sql_utils import run_sql_script
from setup import FME_SERVER_API, FME_SERVER, INSTANCE_ID, SCRIPT_ROOT

from fme import fme_server
from fme.fme_utils import (
    run_transformation_job, delete_directory, create_directory, fme_api_auth, upload_repository, upload,
    wait_for_job_to_complete)

log = logging.getLogger(__name__)


def start_transformation_gebieden():
    log.info("Starting transformation")
    return run_transformation_job(
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
    log.info("Starting transformation")
    return run_transformation_job(
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
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_GML/bgt_buurt.gml"]}, ]})


def start_transformation_shapes():
    log.info("Starting transformation")

    # update data in `Export shapes` and  `Export_Shapes_Totaalgebied` directories
    delete_directory('Export_Shapes')
    create_directory('Export_Shapes')

    delete_directory('Export_Shapes_Totaalgebied')
    create_directory('Export_Shapes_Totaalgebied')

    return run_transformation_job(
        'BGT-SHAPES',
        'aanmaak_esrishape_uit_DB_BGT.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "Aanmaak Shapes uit DB"},
            "publishedParameters": [
                {"name": "SourceDataset_POSTGIS", "value": "bgt"},
                {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
                {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)/Export_Shapes.zip"},
                {"name": "DestDataset_ESRISHAPE3", "value":
                    "$(FME_SHAREDRESOURCE_DATA)/Export_Shapes_Totaalgebied.zip"}]})


def upload_resulting_shapes_to_objectstore():
    """
    Uploads the resulting shapes to BGT objectstore
    :return:
    """
    store = ObjectStore('BGT')
    log.info("Upload resulting shapes to BGT objectstore")
    files = ['Export_Shapes.zip', 'Export_Shapes_Totaalgebied.zip']

    for path in files:
        log.info("Download {} for storing in objectstore".format(path))
        download_url = '{FME_SERVER}{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/{DIR}?detail=low' \
                       'createDirectories=false&detail=low&overwrite=false'.format(
            DIR=path, FME_SERVER=FME_SERVER, url_connect="/fmerest/v2/resources/connections")
        res = requests.get(download_url, headers=fme_api_auth())
        res.raise_for_status()
        if res.status_code == 200:
            res_name = path.split('/')[-1]
            store.put_to_objectstore('shapes/{}'.format(res_name), res.content, res.headers['Content-Type'])
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


def download_bgt():
    """
    Downloads the PDOK files to extract_bgt.zip and calls unzip_pdok_file()
    :return: 0
    """
    target = "extract_bgt.zip"
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
                 38309, 38320, 38322]
             }
        ]
    }
    tiles_as_json = json.dumps(tiles)
    datum = datetime.now().strftime("%d-%m-%Y")

    source = pdok_extract + "?" + urllib.parse.urlencode({
        "extractset": "citygml",
        "excludedtypes": "plaatsbepalingspunt",
        "history": "false",
        "enddate": datum,
        "tiles": tiles_as_json,
    })

    log.info("Starting download from %s to %s", source, target)

    def progress(count, block_size, total_size):
        approximate = ''
        if total_size == -1:
            # evil PDOK not telling us the content size :-(
            # educated guess is ~350Mb
            total_size = 350 * 1024 * 1024
            approximate = '~'

        percentage = float(count * block_size * 100.0 / total_size)
        log.info("%s%2.2f%%", approximate, percentage)

    urllib.request.urlretrieve(source, target, reporthook=progress)
    unzip_pdok_file()
    log.info("Download complete")
    return 0


if __name__ == '__main__':
    logging.basicConfig(level='DEBUG')
    logging.getLogger('requests').setLevel('WARNING')

    server_manager = fme_server.Server(FME_SERVER, INSTANCE_ID, FME_SERVER_API)

    log.info("Starting script, current server status is %s", server_manager.get_status())

    download_bgt()
    try:
        server_manager.start()
        run_sql_script("{app}/020_create_schema.sql".format(app=SCRIPT_ROOT))

        # upload the GML files and FMW scripts
        upload('/tmp/data', 'resources/connections', 'Import_GML', '*.*', recreate_dir=True)
        upload_repository(
            '{app}/030_inlezen_BGT/fme'.format(app=SCRIPT_ROOT), 'repositories', 'BGT-DB', '*.*', register_fmejob=True)

        # DB Connection in FMECLoud needs to be set manually - NOT POSSIBLE IN CURRENT API VERSION
        upload('{app}/030_inlezen_BGT/xsd'.format(app=SCRIPT_ROOT), 'resources/connections', 'Import_XSD', 'imgeo.xsd')
        upload('{app}/030_inlezen_BGT/bron_shapes'.format(app=SCRIPT_ROOT), 'resources/connections',
               'Import_kaartbladen',
               '*.*')
        try:
            wait_for_job_to_complete(start_transformation_gebieden())
            wait_for_job_to_complete(start_transformation_db())
        except Exception:
            sys.exit(1)

        run_sql_script("{app}/060_aanmaak_tabellen_BGT.sql".format(app=SCRIPT_ROOT))

        # aanmaak db-views shapes_bgt
        run_sql_script("{app}/090_aanmaak_DB_views_BGT.sql".format(app=SCRIPT_ROOT))
        run_sql_script("{app}/090_aanmaak_DB_views_IMGEO.sql".format(app=SCRIPT_ROOT))

        # upload shapes fmw scripts naar reposiory
        upload_repository(
            '{app}/100_aanmaak_producten_BGT'.format(app=SCRIPT_ROOT), 'BGT-SHAPES', '*.*', register_fmejob=True)

        # run the `aanmaak_esrishape_uit_DB_BGT` scrop
        try:
            wait_for_job_to_complete(start_transformation_shapes())
        except Exception:
            sys.exit(1)

        upload_resulting_shapes_to_objectstore()

        # TODO: 1) download db and do telling OR do it on remote database
        # TODO: Telling: 040

        # import controle db
        subprocess.call("{app}/070_import_gml_controledb.sh".format(app=SCRIPT_ROOT), shell=True)

        # import csv / mapping db
        run_sql_script("{app}/075_aanmaak_mapping.sql".format(app=SCRIPT_ROOT))

        # TODO: Frequentie verdeling: 080
    except:
        log.exception("Could not process server jobs")
    finally:
        server_manager.stop()
        sys.exit(0)
