import json
import logging
import os
import shutil
import sys
import time
import urllib.parse
import urllib.request
import zipfile
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

shape_object_types = [
    'imgeo_extractie.vw_bgt_begroeidterreindeel',
    'imgeo_extractie.vw_bgt_kruinlijn',
    'imgeo_extractie.vw_bgt_onbegroeidterreindeel',
    'imgeo_extractie.vw_bgt_ondersteunendwaterdeel',
    'imgeo_extractie.vw_bgt_ondersteunendwegdeel',
    'imgeo_extractie.vw_bgt_ongeclassificeerdobject',
    'imgeo_extractie.vw_bgt_overbruggingsdeel',
    'imgeo_extractie.vw_bgt_tunneldeel',
    'imgeo_extractie.vw_bgt_wegdeel',
    'imgeo_extractie.vw_imgeo_bak',
    'imgeo_extractie.vw_imgeo_functioneelgebied',
    'imgeo_extractie.vw_imgeo_gebouwinstallatie',
    'imgeo_extractie.vw_imgeo_installatie',
    'imgeo_extractie.vw_imgeo_kast',
    'imgeo_extractie.vw_imgeo_kunstwerkdeel',
    'imgeo_extractie.vw_imgeo_overigbouwwerk',
    'imgeo_extractie.vw_imgeo_overigescheiding',
    'imgeo_extractie.vw_imgeo_put',
    'imgeo_extractie.vw_imgeo_scheiding',
    'imgeo_extractie.vw_imgeo_spoor',
    'imgeo_extractie.vw_imgeo_straatmeubilair',
    'imgeo_extractie.vw_imgeo_vegetatieobject',
    'imgeo_extractie.vw_imgeo_waterinrichtingselement',
    'imgeo_extractie.vw_imgeo_weginrichtingselement',
    'imgeo_extractie.vw_dgn_bgt_wegdeel',
    'imgeo_extractie.vw_imgeo_mast',
    'imgeo_extractie.vw_imgeo_sensor',
    'imgeo_extractie.vw_imgeo_bord',
    'imgeo_extractie.vw_bgt_waterdeel',
    'imgeo_extractie.vw_imgeo_paal',
    'imgeo_extractie.vw_cft_overbouw',
    'imgeo_extractie.vw_cft_onderbouw',
    'imgeo_extractie.vw_bgt_openbareruimtelabel',
    'imgeo_extractie.vw_bag_ligplaats',
    'imgeo_extractie.vw_bag_standplaats',
    'imgeo_extractie.vw_bgt_pand',
    'imgeo_extractie.vw_bgt_nummeraanduidingreeks',
]


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
             {"name": "P_OUTPUT_DGN", "value": "$(FME_SHAREDRESOURCE_DATA)DGNv8.zip"},
             {"name": "P_CEL", "value": ["$(FME_SHAREDRESOURCE_DATA)resources/NLCS.cel"]},
             {"name": "P_SEED", "value": "$(FME_SHAREDRESOURCE_DATA)resources/DGNv8_seed.dgn"}
         ]})


def start_transformation_nlcs_chunk(min_x, min_y, max_x, max_y):
    """
    calls `aanpassen.fmw` on FME server
    :return: dict with 'jobid' and 'urltransform'
    """
    log.info(f"Starting transformation -:> NLCS {min_x} {min_y} {max_x} {max_y}")

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
    Transform the shapes per shape object type
    :return:
    """
    for shape_type in shape_object_types:
        fme_utils.wait_for_job_to_complete(start_transformation_shapes_for(shape_type))
        download_shape_files(shape_type)
        remove_shape_results(shape_type)

    # upload and cleanup results
    zip_upload_and_cleanup_shape_results()


def start_transformation_shapes_for(shape_type):
    """
    calls `aanmaak_esrishape_uit_DB_BGT.fmw` on FME server
    :return: dict with 'jstart_transformation_shapesobid' and 'urltransform'
    """
    log.info("Starting transformation -:> Shapes")

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
                {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)Esri_Shape_gebieden"},
                {"name": "DestDataset_ESRISHAPE3", "value": "$(FME_SHAREDRESOURCE_DATA)Esri_Shape_totaal"},
                {"name": "DestDataset_CSV", "value": "$(FME_SHAREDRESOURCE_DATA)ASCII_gebieden"},
                {"name": "DestDataset_CSV_3", "value": "$(FME_SHAREDRESOURCE_DATA)ASCII_totaal"},
                {"name": "bgt_view", "value": shape_type}]})


def collect_shape_files_to_fetch():
    """
    Get the filenames of all the shapefiles in fme cloud
    :return:
    """

    def get_dir_contents(contents):
        res = []
        for file_result in contents:
            if file_result['type'] == 'DIR':
                return get_dir_contents(file_result['contents'])
            res.append('{}{}'.format(file_result['path'], file_result['name']))
        return res

    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    files_to_fetch = []

    for folder in ['ASCII_totaal', 'Esri_Shape_totaal', 'ASCII_gebieden', 'Esri_Shape_gebieden']:
        url = 'https://bgt-vicrea-amsterdam-2016.fmecloud.com/fmerest/v2/resources/connections/' \
              'FME_SHAREDRESOURCE_DATA/filesys/{}?accept=json&depth=4&detail=low'.format(folder)
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            files_to_fetch += get_dir_contents(response.json()['contents'])
    return files_to_fetch


def download_shape_files(shape_type):
    log.info(f"download results for {shape_type}")

    for filename in collect_shape_files_to_fetch():

        dirname = '/'.join(filename.split('/')[:-1])
        directory = f'/tmp/data/shaperesults{dirname}'
        if not os.path.exists(directory):
            os.makedirs(directory)

        with open(f'/tmp/data/shaperesults{filename}', 'wb') as file:
            file.write(fme_utils.download(filename, text=False))

    log.info(f"downloaded results for {shape_type}")


def remove_shape_results(shape_type):
    log.info(f"remove results for {shape_type}")
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    for folder in ['ASCII_totaal', 'Esri_Shape_totaal', 'ASCII_gebieden', 'Esri_Shape_gebieden']:
        url = "https://bgt-vicrea-amsterdam-2016.fmecloud.com/fmerest/v2/resources/connections/" \
              "FME_SHAREDRESOURCE_DATA/filesys/{}?detail=low".format(folder)
        response = requests.delete(url, headers=headers)
        if response.status_code == 204:
            log.info(f"removed folder {folder}")
        else:
            log.info(f"Removing folder {folder} failed {response.status_code}")


def zip_upload_and_cleanup_shape_results():
    store = ObjectStore('BGT')
    names = [datetime.now().strftime('%Y%m%d%H%M%S'), "latest"]
    cwd = os.getcwd()

    os.chdir('/tmp/data/shaperesults')
    log.info("Upload Zip Shape results")
    for folder in ['ASCII_totaal', 'Esri_Shape_totaal', 'ASCII_gebieden', 'Esri_Shape_gebieden']:
        zipfile_name = f"/tmp/data/shaperesults/{folder}.zip"
        with ZipFile(f'{folder}.zip', "w") as zf:
            for dirname, subdirs, files in os.walk(folder):
                zf.write(dirname)
                for filename in files:
                    zf.write(os.path.join(dirname, filename))

        for name in names:
            log.info(f"upload {zipfile_name}:{name} to object store")
            store.put_to_objectstore(
                'products/{}-{}.zip'.format(folder, name),
                open(zipfile_name, 'rb').read(),
                'application/octet-stream')

    os.chdir(cwd)
    log.info("Clean up results")
    shutil.rmtree('/tmp/data/shaperesults', ignore_errors=True)
    log.info("Zipped results and uploaded them to the objectstore")


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


def upload_nlcs_vlakken_files():
    log.info("ZIP and upload DGNv8 vlakken products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    url = 'https://bgt-vicrea-amsterdam-2016.fmecloud.com/fmerest/v2/resources/connections/' \
          'FME_SHAREDRESOURCE_DATA/filesys/DGNv8_vlakken_NLCS/BGT_NLCS_V?accept=json&depth=1&detail=low'

    zip_filename = '/tmp/data/DGNv8_vlakken.zip'
    zf = zipfile.ZipFile(zip_filename, mode='w')

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        try:
            for entry in json.loads(response.content)['contents']:
                filename = entry['name']
                path = entry['path']
                upload_path = "DGNv8_vlakken"
                log.info(f"Upload file {upload_path}/{filename}")
                file_content = fme_utils.download(f'{path}/{filename}', text=False)
                zf.writestr(filename, file_content)
        finally:
            zf.close()

        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        with open(zip_filename, mode='rb') as f:
            store.put_to_objectstore(
                'products/DGNv8_vlakken-latest.zip', f.read(), 'application/octet-stream')
            store.put_to_objectstore(
                f'products/DGNv8_vlakken-{timestamp}.zip', f.read(), 'application/octet-stream')

        os.remove(zip_filename)
    log.info("ZIP and upload DGNv8 vlakken products to BGT objectstore done")


def upload_nlcs_lijnen_files():
    log.info("ZIP and upload DGNv8 lijnen products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    url = 'https://bgt-vicrea-amsterdam-2016.fmecloud.com/fmerest/v2/resources/connections/' \
          'FME_SHAREDRESOURCE_DATA/filesys/DGNv8_lijnen_NLCS/BGT_NLCS_L?accept=json&depth=1&detail=low'

    if not os.path.exists('/tmp/data'):
        os.makedirs('/tmp/data')
    zip_filename = '/tmp/data/DGNv8_lijnen.zip'
    zf = zipfile.ZipFile(zip_filename, mode='w')
    upload_path = "DGNv8_lijnen"

    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        try:
            for entry in json.loads(response.content)['contents']:
                filename = entry['name']
                path = entry['path']
                log.info(f"Upload file {upload_path}/{filename}")
                file_content = fme_utils.download(f'{path}/{filename}', text=False)
                zf.writestr(filename, file_content)
        finally:
            zf.close()

        timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
        with open(zip_filename, mode='rb') as f:
            file_content = f.read()
            store.put_to_objectstore(
                'products/DGNv8_lijnen-latest.zip', file_content, 'application/octet-stream')
            store.put_to_objectstore(
                f'products/DGNv8_lijnen-{timestamp}.zip', file_content, 'application/octet-stream')

        os.remove(zip_filename)
    log.info("ZIP and upload DGNv8 lijnen products to BGT objectstore done")


def upload_over_onderbouw_backup():
    """
    Upload Over- en Onderbouw data

    :return:
    """

    # 1. fetch `GBKA_OVERBOUW.dat from objectstore
    log.info("ZIP and upload DGNv8 lijnen products to BGT objectstore")

    store = ObjectStore('BGT')
    headers = {
        'Content-Type': "application/json",
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=bgt_setup.FME_API),
    }
    # import ipdb;ipdb.set_trace()
    data = store.get_store_object('GBKA_OVERBOUW.dat')

    # 2. cut column [0:4]
    db = create_fme_sql_connection()
    for line in str(data).split('\\r\\n'):
        fields = line.split('|')[3:]
        if len(fields) > 0:
            if int(fields[0]) > 0:
                # overbouw
                sql = "insert into imgeo.\"CFT_Overbouw\" (relatievehoogteligging, bestandsnaam, geometrie) " \
                      "values ({}, 'CFT_Overbouw', ST_GeomFromText('{}', 28992));".format(int(fields[0]), fields[1])
            else:
                # onderbouw
                sql = "insert into imgeo.\"CFT_Onderbouw\" (relatievehoogteligging, bestandsnaam, geometrie) " \
                      "values ({}, 'CFT_Onderbouw', ST_GeomFromText('{}', 28992));".format(int(fields[0]), fields[1])
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
            # removed the printing of progress.
            # done = int(50 * downloaded_length / total_length)
            # sys.stdout.write("\r[%s%s] %s bps" % (
            #     '=' * done, ' ' * (50 - done), downloaded_length // (time.clock() - start)))
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
    import controle db using /tmp/data/*.gml
    make sure sql connections are up
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

        # download_bgt()
        #
        # # upload data and FMW scripts
        # upload_data()
        # upload_script_resources()
        #
        # create_fme_dbschema()
        upload_over_onderbouw_backup()
        # create_fme_shape_views()
        # #
        # fme_utils.wait_for_job_to_complete(start_transformation_db())
        # fme_utils.wait_for_job_to_complete(start_transformation_gebieden())
        # fme_utils.wait_for_job_to_complete(start_transformation_stand_ligplaatsen())
        #
        # # create coordinate search envelopes
        # fme_utils.wait_for_job_to_complete(resolve_chunk_coordinates())
        #
        # # run the `aanmaak_esrishape_uit_DB_BGT` script
        # start_transformation_shapes()
        #
        # # run transformation to `NLCS` format
        #
        #
        # # run transformation to `DGN` format
        # fme_utils.wait_for_job_to_complete(start_transformation_dgn())
        #
        # # upload the resulting shapes an the source GML zip to objectstore
        # upload_pdok_zip_to_objectstore()
        # upload_nlcs_lijnen_files()
        # upload_nlcs_vlakken_files()

        run_before_after_comparisons()
    except Exception as e:
        log.exception("Could not process server jobs {}".format(e))
        raise e
    finally:
        log.info("Stopping FME service")
        server_manager.stop()
