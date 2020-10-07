import json
import logging
import os
import time
import urllib.parse
import urllib.request
import csv
from datetime import datetime
from zipfile import ZipFile

import requests

import bgt_setup
import fme.comparison as fme_comparison
import fme.fme_server as fme_server
import fme.fme_utils as fme_utils
import fme.sql_utils as fme_sql_utils
import fme.polygon as polygon
from fme.transform_db import start_transformation_db
from fme.transform_dgn import start_transformation_dgn, upload_dgn_files
from fme.transform_gebieden import start_transformation_gebieden, upload_gebieden
from fme.transform_nlcs import (
    start_transformation_nlcs_chunk, upload_nlcs_lijnen_files, upload_nlcs_vlakken_files)
from fme.transform_shapes import start_transformation_shapes
from fme.transform_stand_ligplaatsen import start_transformation_stand_ligplaatsen
from objectstore.objectstore import ObjectStore

logging.basicConfig(level=logging.DEBUG)
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

    # timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
    filename = 'BGT_Totaal/GML_totaal-latest.zip'
    store.put_to_objectstore(filename, content, 'application/octet-stream')
    log.info("Uploaded {} to objectstore BGT/BGT_Totaal/".format(filename))


def get_gob_over_onderbouw_files():
    """
    Downloads overbouw and onderbouw files from GOB objectstore.
    Returns locations of stored files
    """
    store = ObjectStore('GOB', bgt_setup.GOB_OBJECTSTORE_CONTAINER)

    if not os.path.exists('/tmp/data'):
        os.makedirs('/tmp/data')

    files = [
        # Filename, object type
        ('CFT_onderbouw.csv', 'CFT_Onderbouw'),
        ('CFT_overbouw.csv', 'CFT_Overbouw'),
    ]

    def file_objectstore_location(filename: str):
        return f"bgt/CSV_Actueel/{filename}"

    def file_write_location(filename: str):
        return f"/tmp/data/{filename}"

    for filename, _ in files:
        with open(file_write_location(filename), "wb") as f:
            f.write(store.get_store_object(file_objectstore_location(filename)))

    return [(file_write_location(filename), typestr) for filename, typestr in files]


def upload_over_onderbouw_backup():
    log.info("Get onderbouw and overbouw files from GOB objectstore")
    files = get_gob_over_onderbouw_files()

    log.info("Running INSERT statements...")
    db = create_fme_sql_connection()

    for file_location, object_type in files:
        with open(file_location, 'r') as f:
            reader = csv.reader(f, delimiter=';')

            # Skip header
            next(reader)
            for row in reader:
                guid, begin_geldigheid, eind_geldigheid, relatievehoogteligging, geometrie = row
                sql = f"INSERT INTO imgeo.\"{object_type}\" (guid, relatievehoogteligging, bestandsnaam, geometrie) " \
                      f"VALUES ('{guid.replace('$$', '')}', {relatievehoogteligging}, '{object_type}', " \
                      f"ST_GeomFromText('{geometrie}', 28992));"
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


def get_pdok_feature_types():
    """Returns all available feature types from PDOK using the /dataset API endpoint.

    """
    r = requests.get(f"{bgt_setup.PDOK_DOWNLOAD_API}/dataset")
    r.raise_for_status()

    return [item['featuretype'] for item in r.json()['timeliness']]


def pdok_url(fme_test_run=0) -> str:
    """Requests a download with PDOK and returns the download URL.

    """
    exclude_feature_types = [
        'plaatsbepalingspunt'
    ]

    body = {
        'featuretypes': [ftype for ftype in get_pdok_feature_types() if ftype not in exclude_feature_types],
        'format': 'citygml',
        'geofilter': polygon.full if not fme_test_run else polygon.test
    }

    # Request a new custom download
    log.info("Requesting PDOK download")
    r = requests.post(f"{bgt_setup.PDOK_DOWNLOAD_API}/full/custom", json=body)
    r.raise_for_status()

    download_request_id = r.json()['downloadRequestId']
    log.info(f"PDOK download request id is {download_request_id}")

    while True:
        # Periodically check if download is ready. Return download URL when it is.
        time.sleep(5)

        r = requests.get(f"{bgt_setup.PDOK_DOWNLOAD_API}/full/custom/{download_request_id}/status")
        r.raise_for_status()

        if r.status_code == 201:
            log.info(f"Download ready")
            return f"{bgt_setup.PDOK_DOWNLOAD_API_HOST}{r.json()['_links']['download']['href']}"
        elif r.status_code == 200:
            log.info(f"Download generation in progress: {r.json()['progress']}%")


def download_bgt(fme_test_run=0):
    url = pdok_url(fme_test_run)
    target = "extract_bgt.zip"
    log.info("Starting download from %s to %s", url, target)
    response = requests.get(url, stream=True)
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
        host=bgt_setup.FME_BASE_URL.split('//')[-1], dbname=bgt_setup.DB_FME_DBNAME,
        user=bgt_setup.DB_FME_USER, password=bgt_setup.FME_DBPASS)


def upload_data():
    """Upload the GML files, XSD and kaartbladen/shapes"""
    fme_utils.upload('/tmp/data', 'resources/connections', 'Import_GML', '*.*')
    fme_utils.upload('{app}/source_data/xsd'.format(app=bgt_setup.SCRIPT_ROOT),
                     'resources/connections', 'Import_XSD', 'imgeo.xsd')
    fme_utils.upload('{app}/source_data/bron_csv'.format(app=bgt_setup.SCRIPT_ROOT),
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
        'BGT-DB', '*.fmw', register_fmejob=True)

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


# noinspection PyInterpreter
def run_all(fme_run_test=0):

    download_bgt(fme_run_test)

    # upload data and FMW scripts
    upload_data()
    upload_script_resources()

    create_fme_dbschema()
    upload_over_onderbouw_backup()
    create_fme_shape_views()

    fme_utils.wait_for_job_to_complete(start_transformation_db())
    fme_utils.wait_for_job_to_complete(start_transformation_gebieden())
    fme_utils.wait_for_job_to_complete(start_transformation_stand_ligplaatsen())

    # create coordinate search envelopes
    fme_utils.wait_for_job_to_complete(resolve_chunk_coordinates())

    # run the `aanmaak_esrishape_uit_DB_BGT` script
    start_transformation_shapes()

    # run transformation to `NLCS` and `DGN` format
    last_job_in_queue = {}
    for a in retrieve_chunk_coordinates():
        start_transformation_nlcs_chunk(*a)
        last_job_in_queue = start_transformation_dgn(*a)
    fme_utils.wait_for_job_to_complete(last_job_in_queue, sleep_time=20)

    # upload the resulting shapes an the source GML zip to objectstore
    upload_gebieden()
    upload_pdok_zip_to_objectstore()
    upload_nlcs_lijnen_files()
    upload_nlcs_vlakken_files()
    upload_dgn_files()
    # run_before_after_comparisons()


def main() -> int:
    """
    This function is defined as an **entry-point** in :file:`setup.py`.

    """
    logging.getLogger('requests').setLevel('WARNING')
    log.info("Starting import script")
    server_manager = fme_server.FMEServer(
        bgt_setup.FME_BASE_URL, bgt_setup.FME_INSTANCE_ID, bgt_setup.FME_CLOUD_API_TOKEN)

    try:
        log.info("Starting script, current server status is %s", server_manager.get_status())

        # start the fme server
        server_manager.start()
        run_all(bgt_setup.FME_TEST_RUN)
    except Exception as e:
        log.exception("Could not process server jobs {}".format(e))
        raise e
    finally:
        log.info("Stopping FME service")
        server_manager.stop()
    return 0


if __name__ == '__main__':
    main()
