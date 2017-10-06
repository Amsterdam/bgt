import logging
import shutil
from datetime import datetime
from zipfile import ZipFile

import os
import requests

import bgt_setup
import fme.fme_utils as fme_utils
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
    'imgeo_extractie.vw_lps_nummeraanduiding',
    'imgeo_extractie.vw_sps_nummeraanduiding',
]


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


def download_shape_files(shape_type):
    log.info(f"download shape results for {shape_type}")

    for filename in collect_shape_files_to_fetch():

        dirname = '/'.join(filename.split('/')[:-1])
        directory = f'/tmp/data/shaperesults{dirname}'
        if not os.path.exists(directory):
            os.makedirs(directory)

        with open(f'/tmp/data/shaperesults{filename}', 'wb') as file:
            file.write(fme_utils.download(filename, text=False))

    log.info(f"downloaded shape results for {shape_type}")


def collect_shape_files_to_fetch():
    """
    Get the filenames of all the shapefiles in fme cloud
    :return:
    """

    def get_paths(dir_tree):
        res = []
        for file_object in dir_tree:
            if [file_object['type'] == 'FILE']:
                res.append('{}{}'.format(file_object['path'], file_object['name']))
        return res

    def get_paths2(dir_tree):
        res = []
        for dir_object in dir_tree:
            if [dir_object['type'] == 'DIR']:
                for file_object in dir_object['contents']:
                    res.append('{}{}'.format(file_object['path'], file_object['name']))
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
            if '_gebieden' in folder:
                files_to_fetch += get_paths2(response.json()['contents'])
            else:
                files_to_fetch += get_paths(response.json()['contents'])
    return files_to_fetch


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
            with open(zipfile_name, 'rb') as uploadfile:
                store.put_to_objectstore(
                    'products/{}-{}.zip'.format(folder, name),
                    uploadfile,
                    'application/octet-stream')

    os.chdir(cwd)
    log.info("Clean up results")
    shutil.rmtree('/tmp/data/shaperesults', ignore_errors=True)
    log.info("Zipped results and uploaded them to the objectstore")


def start_transformation_shapes():
    """
    Transform the shapes per shape object type
    :return:
    """
    log.info("Start transformation of shapes")
    for shape_type in shape_object_types:
        fme_utils.wait_for_job_to_complete(start_transformation_shapes_for(shape_type), sleep_time=1)
        download_shape_files(shape_type)
        remove_shape_results(shape_type)

    # upload and cleanup results
    zip_upload_and_cleanup_shape_results()
