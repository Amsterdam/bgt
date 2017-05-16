import json
import logging
import os
import time
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
from fme.transform_db import start_transformation_db
from fme.transform_dgn import start_transformation_dgn, upload_dgn_files
from fme.transform_gebieden import start_transformation_gebieden
from fme.transform_nlcs import (
    start_transformation_nlcs_chunk, upload_nlcs_lijnen_files, upload_nlcs_vlakken_files)
from fme.transform_shapes import start_transformation_shapes
from fme.transform_stand_ligplaatsen import start_transformation_stand_ligplaatsen
from objectstore.objectstore import ObjectStore

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


def resolve_chunk_coordinates():
    """
    calls :file:`00_kaartbladen_coordinatenbepaler.fmw` on FME server
    output csv is used to split dgnNCS job in smaller chunks

    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation -:> Resolve Chunk Coordinates")

    return fme_utils.run_transformation_job(
        'BGT-DGN',
        '00_kaartbladen_coordinatenbepaler.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "Bepaal coordinaten"},
            "publishedParameters": [
                {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
                {"name": "DestDataset_CSV", "value": "$(FME_SHAREDRESOURCE_DATA)BGT_uitwissel"}]})


def retrieve_chunk_coordinates():
    """
    Retrieve the chunck coordinates stored in
    $(FME_SHAREDRESOURCE_DATA)BGT_uitwissel/Kaartbladen_coordinaten.csv
    and return an iterator with the coordinates

    :return:
    """
    content = fme_utils.download("BGT_uitwissel/Kaartbladen_coordinaten.csv")

    coords = [row.split(',') for row in content.split('\n')[1:-1]]
    return coords


def upload_pdok_zip_to_objectstore():
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


def upload_over_onderbouw_backup():
    """
    Upload Over- en Onderbouw data

    :return:
    """

    # 1. fetch latest `GBKA_OVERBOUW.dat from objectstore
    log.info("ZIP and upload DGNv8 lijnen products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }

    # determine the latest upload filename
    latest_upload = sorted(
        [c['name'] for c in store._get_full_container_list([]) if c['name'].endswith('_GBKA_OVERBOUW.zip')])[-1]

    if not os.path.exists('/tmp/data'):
        os.makedirs('/tmp/data')

    # download the latest `GBKA_OVERBOUW.dat` zipfile and temporary store it
    with open("/tmp/data/GBKA_OVERBOUW.dat.zip", 'wb') as f:
        f.write(store.get_store_object(latest_upload))

    # unzip the GBKA_OVERBOUW.dat.zip file
    with ZipFile('/tmp/data/GBKA_OVERBOUW.dat.zip', 'r') as myzip:
        myzip.extractall('/tmp/data/')

    # get the data and process
    data = open("/tmp/data/Alle_Producten/GBKA_A/Objecten/WKT/GBKA_OVERBOUW.dat").read()
    # cut column [0:4], create sql insert statements and exec.
    db = create_fme_sql_connection()
    for line in str(data).split(os.linesep):
        fields = line.split('|')[1:]
        if len(fields) > 0:
            if int(fields[2]) > 0:
                # overbouw
                sql = "insert into imgeo.\"CFT_Overbouw\" (guid, relatievehoogteligging, bestandsnaam, geometrie) " \
                      "values ('{}', {}, 'CFT_Overbouw', ST_GeomFromText('{}', 28992));".format(
                    fields[0].replace('$$', ''), int(fields[2]), fields[3])
            else:
                # onderbouw
                sql = "insert into imgeo.\"CFT_Onderbouw\" (guid, relatievehoogteligging, bestandsnaam, geometrie) " \
                      "values ('{}', {}, 'CFT_Onderbouw', ST_GeomFromText('{}', 28992));".format(
                    fields[0].replace('$$', ''), int(fields[2]), fields[3])
            db.run_sql(sql)


def unzip_pdok_file():
    """
    Unzip the extract_bgt.zip file into the `/tmp/data` directory
    :return:
    """
    log.info("Start unzipping contents")
    with ZipFile('extract_bgt.zip', 'r') as myzip:
        myzip.extractall('/tmp/data/')
    log.info("Unzip complete")


def pdok_url():
    """
    Returns the PDOK url for `now`
    :return:
    """
    pdok_extract = "https://www.pdok.nl/download/service/extract.zip"
    tile_codes = [
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
        38309, 38320, 38322, 38305, 38669, 38473, 38123, 38519, 38286]

    tiles = {
        "layers": [
            {"aggregateLevel": 0,
             "codes": tile_codes}]}
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
    Check new pdok.nl functionality / for the moment we get 500 server errors form pdok.
    """
    res = requests.head(pdok_url())
    print(res)


def download_bgt():
    target = "extract_bgt.zip"
    log.info("Starting download from %s to %s", pdok_url(), target)
    response = requests.get(pdok_url(), stream=True)
    start = time.clock()
    # total_length = response.headers.get('content-length')
    downloaded_length = 0
    with open(target, 'wb') as newfile:
        for chunk in response.iter_content(chunk_size=1024):
            downloaded_length += len(chunk)
            newfile.write(chunk)
    log.info("Download complete, time elapsed: {}".format(time.clock() - start))
    unzip_pdok_file()
    log.info("Unzip complete")


def create_fme_sql_connection():
    log.info("create dbconnection for FME database")
    return fme_sql_utils.SQLRunner(
        host=bgt_setup.FME_SERVER.split('//')[-1], dbname=bgt_setup.DB_FME_DBNAME,
        user=bgt_setup.DB_FME_USER, password=bgt_setup.FME_DBPASS)


def upload_data():
    """Upload the GML files, XSD and kaartbladen/shapes"""
    fme_utils.upload('/tmp/data', 'resources/connections', 'Import_GML', '*.*')
    fme_utils.upload('{app}/source_data/xsd'.format(app=bgt_setup.SCRIPT_ROOT),
                     'resources/connections', 'Import_XSD', 'imgeo.xsd')
    fme_utils.upload('{app}/source_data/bron_shapes'.format(app=bgt_setup.SCRIPT_ROOT),
                     'resources/connections', 'Import_kaartbladen', '*.*')
    fme_utils.upload('{app}/source_data/aanmaak_producten_bgt/resource'.format(app=bgt_setup.SCRIPT_ROOT),
                     'resources/connections', 'resources', '*.*')


def upload_script_resources():
    """
    Upload script resources
    :return:
    """
    fme_utils.upload_repository(
        '{app}/source_data/fme'.format(app=bgt_setup.SCRIPT_ROOT),
        'BGT-DB', '*.*', register_fmejob=True)

    fme_utils.upload_repository(
        '{app}/source_data/aanmaak_producten_bgt'.format(app=bgt_setup.SCRIPT_ROOT),
        'BGT-SHAPES', '*shape*.*', register_fmejob=True)

    fme_utils.upload_repository(
        '{app}/source_data/aanmaak_producten_bgt'.format(app=bgt_setup.SCRIPT_ROOT),
        'BGT-DGN', '*dgn*.*', register_fmejob=True)

    fme_utils.upload_repository(
        '{app}/source_data/aanmaak_producten_bgt'.format(app=bgt_setup.SCRIPT_ROOT),
        'BGT-DGN', '*kaartbladen*.*', recreate_repo=False, register_fmejob=True)


def create_fme_dbschema():
    """
    create FME schema
    :return:
    """
    fme_pgsql = create_fme_sql_connection()
    fme_pgsql.run_sql_script("{app}/fme_source_sql/020_create_schema.sql".format(app=bgt_setup.SCRIPT_ROOT))
    fme_pgsql.run_sql_script("{app}/fme_source_sql/060_aanmaak_tabellen_BGT.sql".format(app=bgt_setup.SCRIPT_ROOT))
    fme_pgsql.close()


def create_fme_shape_views():
    """
    aanmaak db-views shapes_bgt
    :return:
    
    """
    fme_pgsql = create_fme_sql_connection()
    fme_pgsql.run_sql_script("{app}/fme_source_sql/090_aanmaak_DB_views_BGT.sql".format(app=bgt_setup.SCRIPT_ROOT))
    fme_pgsql.run_sql_script(
        "{app}/fme_source_sql/090_aanmaak_DB_views_IMGEO.sql".format(app=bgt_setup.SCRIPT_ROOT))
    fme_pgsql.close()


def run_before_after_comparisons():
    """
    Import controle db using :file:`/tmp/data/*.gml`.
    
    Make sure sql connections are up
    """
    loc_pgsql = create_fme_sql_connection()
    loc_pgsql.import_gml_control_db()
    loc_pgsql.import_csv_fixture('../app/source_data/075_mapping.csv', 'imgeo_controle.mapping_gml_db')

    # comparisons FKA: 040...
    fme_comparison.compare_before_after_counts_csv(
        loc_pgsql.host, loc_pgsql.port, loc_pgsql.dbname,
        loc_pgsql.user, loc_pgsql.password
    )

    # comparisons FKA 080...
    fme_comparison.create_comparison_data(
        loc_pgsql.host, loc_pgsql.port, loc_pgsql.dbname,
        loc_pgsql.user, loc_pgsql.password
    )


def run_all():
    # download_bgt()

    # upload data and FMW scripts
    # upload_data()
    # upload_script_resources()

    # create_fme_dbschema()
    # upload_over_onderbouw_backup()
    # create_fme_shape_views()

    # fme_utils.wait_for_job_to_complete(start_transformation_db())
    # fme_utils.wait_for_job_to_complete(start_transformation_gebieden())
    # fme_utils.wait_for_job_to_complete(start_transformation_stand_ligplaatsen())

    # create coordinate search envelopes
    fme_utils.wait_for_job_to_complete(resolve_chunk_coordinates())

    # run the `aanmaak_esrishape_uit_DB_BGT` script
    # start_transformation_shapes()

    # run transformation to `NLCS` and `DGN` format
    last_job_in_queue = {}
    for a in retrieve_chunk_coordinates():
        start_transformation_nlcs_chunk(*a)
        last_job_in_queue = start_transformation_dgn(*a)
    fme_utils.wait_for_job_to_complete(last_job_in_queue, sleep_time=20)

    # upload the resulting shapes an the source GML zip to objectstore
    # upload_pdok_zip_to_objectstore()
    # upload_nlcs_lijnen_files()
    # upload_nlcs_vlakken_files()
    # upload_dgn_files()
    # run_before_after_comparisons()


if __name__ == '__main__':
    logging.basicConfig(level='DEBUG')
    logging.getLogger('requests').setLevel('WARNING')
    log.info("Starting import script")
    server_manager = fme_server.FMEServer(
        bgt_setup.FME_SERVER, bgt_setup.INSTANCE_ID, bgt_setup.FME_SERVER_API)

    try:
        log.info("Starting script, current server status is %s", server_manager.get_status())

        # start the fme server
        server_manager.start()

        run_all()

    except Exception as e:
        log.exception("Could not process server jobs {}".format(e))
        raise e
    finally:
        log.info("Stopping FME service")
        server_manager.stop()
