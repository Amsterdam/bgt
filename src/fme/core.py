import json
import logging
import sys
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
                                    {"name": "bron_BGT_kaartbladen",
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)Import_kaartbladen/BGT_kaartbladen.shp"]}]})


def start_transformation_db():
    """
    calls `inlezen_DB_BGT_uit_citygml.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
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
            "TMDirectives": {"tag": "linux", "description": "Over en onderbouw -> DB"},
            "publishedParameters": [

                {"name": "SourceDataset_WFS", "value": "https://map.datapunt.amsterdam.nl/maps/bag"},
                {"name": "_API_PAGESIZE", "value": "3000"},
                {"name": "DestDataset_POSTGIS_5", "value": "bgt"},
                {"name": "DestDataset_POSTGIS_7", "value": "bgt"}]})


def start_transformation_dgn():
    """
    calls `aanmaak_dgnNLCS_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation -:> DGN")

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
             {"name": "P_OUTPUT_DGN", "value": "$(FME_SHAREDRESOURCE_DATA)DGN.zip"},
             {"name": "P_CEL", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/NLCS.cel"]},
             {"name": "P_SEED", "value": "$(FME_SHAREDRESOURCE_DATA)resources/DGNv8_seed.dgn"}
         ]})


def start_transformation_nlcs_chunk(min_x, min_y, max_x, max_y):
    """
    calls `aanpassen.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info(f"Starting transformation -:> NLCS {min_x} {min_y} {max_x} {max_y}")
    # update data in `Export shapes` and  `Export_Shapes_Totaalgebied` directories

    return fme_utils.run_transformation_job(
        'BGT-DGN',
        'aanmaak_dgnNLCS_uit_DB_BGT.fmw',
        {"subsection": "REST_SERVICE",
         "FMEDirectives": {},
         "NMDirectives": {"successTopics": [], "failureTopics": []},
         "TMDirectives": {"tag": "linux", "description": "Aanmaak NLCS uit DB"},
         "publishedParameters": [
             {"name": "SourceDataset_POSTGIS", "value": "bgt"},
             {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
             {"name": "p_font", "value": "$(FME_SHAREDRESOURCE_DATA)resources/NLCS-ISO.ttf"},
             {"name": "DestDataset_DGNV8", "value": "$(FME_SHAREDRESOURCE_DATA)DGNv8_vlakken_NLCS"},
             {"name": "DestDataset_DGNV8_5", "value": "$(FME_SHAREDRESOURCE_DATA)DGNv8_lijnen_NLCS"},
             {"name": "P_CEL", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/NLCS.cel"]},
             {"name": "SEED_vlakken_DGNV8", "value": "$(FME_SHAREDRESOURCE_DATA)resources/NLCSvlakken_seed.dgn"},
             {"name": "SourceDataset_CSV", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/BGT_prioriteit.csv"]},
             {"name": "SEED_lijnen_DGNv8", "value": "$(FME_SHAREDRESOURCE_DATA)resources/NLCSlijnen_seed.dgn"},
             {"name": "ENVELOPE_MINX", "value": min_x},
             {"name": "ENVELOPE_MINY", "value": min_y},
             {"name": "ENVELOPE_MAXX", "value": max_x},
             {"name": "ENVELOPE_MAXY", "value": max_y}, ]})


def start_transformation_shapes():
    """
    calls `aanmaak_esrishape_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info("Starting transformation -:> Shapes")

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
                {"name": "SourceDataset_POSTGIS_5", "value": "bgt"},
                {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)Esri_Shape_gebied.zip"},
                {"name": "DestDataset_ESRISHAPE3", "value": "$(FME_SHAREDRESOURCE_DATA)Esri_Shape_totaal.zip"},
                {"name": "DestDataset_CSV", "value": "$(FME_SHAREDRESOURCE_DATA)ASCII_gebied.zip"},
                {"name": "DestDataset_CSV_3", "value": "$(FME_SHAREDRESOURCE_DATA)ASCII_totaal.zip"}]})


def resolve_chunk_coordinates():
    """
    calls `00_kaartbladen_coordinatenbepaler.fmw` on FME server
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
                {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)TestExport.zip"},
                {"name": "DestDataset_ESRISHAPE3", "value":
                    "$(FME_SHAREDRESOURCE_DATA)TestExportTotaalgebied.zip"}]})


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


def upload_resulting_shapes_to_objectstore():
    """
    Uploads the resulting shapes to BGT objectstore
    :return:
    """
    store = ObjectStore('BGT')
    log.info("Upload resulting shapes to BGT objectstore")

    files = ['Esri_Shape_totaal.zip', 'Esri_Shape_gebied.zip', 'ASCII_totaal.zip', 'ASCII_gebied.zip']

    for path in files:
        log.info("Download {} for storing in objectstore".format(path))
        download_url = '{FME_SERVER}{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/{DIR}?detail=low&' \
                       'createDirectories=true&detail=low&overwrite=true'.format(
            DIR=path, FME_SERVER=bgt_setup.FME_SERVER, url_connect="/fmerest/v2/resources/connections")
        res = requests.get(download_url, headers=fme_utils.fme_api_auth())
        res.raise_for_status()
        if res.status_code == 200:
            res_name = path.split('/')[-1].split('.')
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            store.put_to_objectstore('shapes/{}-{}.{}'.format(res_name[0], timestamp, res_name[-1]),
                                     res.content,
                                     res.headers['Content-Type'])
            store.delete_from_objectstore('shapes/{}-latest'.format(path.split('/')[-1]))
            store.put_to_objectstore('shapes/{}-latest'.format(path.split('/')[-1]),
                                     res.content,
                                     res.headers['Content-Type'])
            log.info("Uploaded {} to objectstore BGT/shapes".format(res_name[0], timestamp, res_name[-1]))
    log.info("Uploaded resulting shapes to BGT objectstore")


def upload_over_onderbouw_backup():
    """
    Upload Over- en Onderbouw data

    :return:
    """
    log.info("Upload Onder- en Overbouw data")
    store = ObjectStore('BGT')
    dumpfile = "/tmp/data/over_onderbouw.pg_dump"

    file_name_to_fetch = "CFT_OverOnderbouw_latest.backup"
    with open(dumpfile, 'wb') as newfile:
        data = store.get_store_object(f"OverOnderbouw/{file_name_to_fetch}")
        newfile.write(data)

    fme_pgsql = create_fme_sql_connection()
    fme_pgsql.run_sql_script(dumpfile)
    log.info("Uploading Onder- en Overbouw data gereed.")


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
        38309, 38320, 38322]

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
    # PDOK does not send a content-length header so we make an educated guess of ~ 420 MB
    total_length = 420 * 1024 * 1024
    downloaded_length = 0
    with open(target, 'wb') as newfile:
        for chunk in response.iter_content(chunk_size=1024):
            downloaded_length += len(chunk)
            newfile.write(chunk)
            done = int(50 * downloaded_length / total_length)
            sys.stdout.write("\r[%s%s] %s bps" % (
                '=' * done, ' ' * (50 - done), downloaded_length // (time.clock() - start)))
    log.info("Download complete, time elapsed: {}".format(time.clock() - start))
    unzip_pdok_file()
    log.info("Unzip complete")


def create_fme_sql_connection():
    log.info("create dbconnection for FME database")
    return fme_sql_utils.SQLRunner(
        host=bgt_setup.FME_SERVER.split('//')[-1], dbname=bgt_setup.DB_FME_DBNAME,
        user=bgt_setup.DB_FME_USER, password=bgt_setup.FME_DBPASS)


def create_loc_sql_connection():
    log.info("create dbconnection for Local database")
    return fme_sql_utils.SQLRunner(
        host=bgt_setup.DB_FME_HOST, port=bgt_setup.DB_FME_PORT,
        dbname=bgt_setup.DB_FME_DBNAME, user=bgt_setup.DB_FME_USER)


def create_sql_connections():
    return create_loc_sql_connection(), create_fme_sql_connection()


def upload_data():
    """Upload the GML files, XSD and kaartbladen/shapes"""
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
    import controle db using /tmp/data/*.gml
    make sure sql connections are up
    """
    loc_pgsql = create_fme_sql_connection()
    loc_pgsql.import_gml_control_db()

    # import csv / mapping db
    # incorrect in 075_mappings
    # ;;BGT_KRUINLIJN;vw_bgt_kruinlijn;vw_ngt_kruinlijn
    # ;;BGT_NUMMERAANDUIDINGREEKS;vw_bgt_nummeraanduidingreeks

    loc_pgsql.import_csv_fixture('../app/source_data/075_mapping.csv', 'imgeo_controle.mapping_gml_db')

    # comparisons FKA: 040...
    fme_comparison.compare_before_after_counts_csv()

    # comparisons FKA 080...
    fme_comparison.create_comparison_data()


if __name__ == '__main__':
    logging.basicConfig(level='DEBUG')
    logging.getLogger('requests').setLevel('WARNING')
    log.info("Starting import script")

    try:
        server_manager = fme_server.FMEServer(
            bgt_setup.FME_SERVER, bgt_setup.INSTANCE_ID, bgt_setup.FME_SERVER_API)

        log.info("Starting script, current server status is %s", server_manager.get_status())

        # start the fme server
        server_manager.start()

        download_bgt()

        # upload data and FMW scripts
        upload_data()
        upload_script_resources()

        create_fme_dbschema()
        upload_over_onderbouw_backup()
        create_fme_shape_views()
        #
        fme_utils.wait_for_job_to_complete(start_transformation_db())
        fme_utils.wait_for_job_to_complete(start_transformation_gebieden())
        fme_utils.wait_for_job_to_complete(start_transformation_stand_ligplaatsen())

        # create coordinate search envelopes
        fme_utils.wait_for_job_to_complete(resolve_chunk_coordinates())

        # run the `aanmaak_esrishape_uit_DB_BGT` script
        fme_utils.wait_for_job_to_complete(start_transformation_shapes())

        # run transformation to `NLCS` format
        for a in retrieve_chunk_coordinates():
            start_transformation_nlcs_chunk(*a)

        # run transformation to `DGN` format
        fme_utils.wait_for_job_to_complete(start_transformation_dgn())

        # upload the resulting shapes an the source GML zip to objectstore
        upload_pdok_zip_to_objectstore()

        upload_resulting_shapes_to_objectstore()

        #run_before_after_comparisons()
    except Exception as e:
        log.exception("Could not process server jobs {}".format(e))
        raise e
    finally:
        log.info("Stopping FME service")
        server_manager.stop()
