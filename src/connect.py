import glob
import json
import logging
import os
import subprocess
import time
import urllib.parse
import urllib.request
from datetime import datetime
from zipfile import ZipFile

import requests

import fme_server

FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
FME_API = os.getenv('FMEAPI', 'secret')
FME_SERVER = os.getenv('FMESERVER', 'secret')
INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
FME_DBPASS = os.getenv('FMEDBPASS', 'secret')
CONTROLE_DB = os.getenv('database', 'secret')
CONTROLE_USER = os.getenv('DB_USER', 'secret')
CONTROLE_PASS = os.getenv('DB_PASS', 'secret')

log = logging.getLogger(__name__)


def fme_api_auth():
    return {'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}


def delete_directory(directory):
    # delete directory
    log.info("Delete directory %s", directory)

    url = (
        '{FME_SERVER}/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA/filesys/{directory}?detail=low'.format(
            FME_SERVER=FME_SERVER,
            directory=directory
        ))

    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code == 404:
        log.debug("Directory not found")

    repository_res.raise_for_status()
    log.debug("Directory deleted")


def create_directory(directory):
    log.info("Create directory %s", directory)
    url = (
        '{FME_SERVER}/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
            FME_SERVER=FME_SERVER
        ))

    repository_res = requests.post(url, headers=fme_api_auth(), data={
        'directoryname': directory,
        'type': 'DIR',
    })

    repository_res.raise_for_status()
    log.debug("Directory created")



def upload_gml_files():
    """
    Step 1: Upload the GML files
    """
    url_connect = 'fmerest/v2/resources/connections'

    delete_directory('Import_GML')
    create_directory('Import_GML')

    # upload files
    log.debug("Upload files to `Import_GML` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Import_GML?createDirectories=false&detail=low' \
          '&overwrite=false'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    path = 'data'
    for infile in glob.glob(os.path.join('/', 'tmp', path, '*.*')):
        with open(infile, 'rb') as f:
            filename = os.path.split(infile)[-1]
            headers = {
                'Content-Disposition': 'attachment; filename="{}"'.format(filename),
                'Content-Type': 'application/octet-stream',
                'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API),
            }
            log.debug('Uploading {} to {}'.format(infile, filename))
            repository_res = requests.post(url, data=f, headers=headers)
            repository_res.raise_for_status()
    log.debug("Upload files completed")


def upload_repositories(repo_name):
    """
    Step 2: Create/Upload Transformation Repository
    """
    url_repositories = 'fmerest/v2/repositories'

    # delete repository <repo_name>
    url = '{FME_SERVER}/{url_connect}/{repo_name}?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_repositories, repo_name=repo_name)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        log.debug("Repository not found")
    else:
        log.debug("Repository deleted")

    # create repository
    create_url = '{FME_SERVER}/{url_connect}?detail=low&accept=json'.format(
        FME_SERVER=FME_SERVER, url_connect=url_repositories)
    post_headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}
    payload = {'description': repo_name, 'name': repo_name,}
    create_repo_result = requests.post(create_url, headers=post_headers, data=payload)
    create_repo_result.raise_for_status()
    log.debug("Repository created")


def upload_fmw_script(repo_name, filepath, filename):
    """
    Upload the fmw file from `<filepath>/<filename>`
    """
    url_repositories = 'fmerest/v2/repositories'
    log.debug("Delete existing FMW file (if exists)")
    delete_url = '{FME_SERVER}/{url_connect}/{repo_name}/items/{filename}?detail=low&accept=json'.format(
        FME_SERVER=FME_SERVER, url_connect=url_repositories,
        repo_name=repo_name, filename=filename)
    delete_headers = {
        'Accept': 'application/json',
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}
    delete_fmw_result = requests.delete(delete_url, headers=delete_headers)
    if delete_fmw_result.status_code not in [404, 204]:
        delete_fmw_result.raise_for_status()
    elif delete_fmw_result.status_code == 404:
        log.debug("Existing FMW file not found.")
    else:
        log.debug("Existing FMW file deleted.")

    log.debug("Upload FMW file")
    upload_url = '{FME_SERVER}/{url_connect}/{repo_name}/items?detail=low&accept=json'.format(
        FME_SERVER=FME_SERVER, url_connect=url_repositories, repo_name=repo_name)
    post_headers = {
        'Content-Disposition': 'attachment; filename={filename}'.format(filename=filename),
        'Content-Type': 'application/octet-stream',
        'Accept': 'application/json',
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}
    payload = open("{file_path}/{filename}".format(file_path=filepath, filename=filename), encoding="utf-8").read()
    upload_fmw_result = requests.post(upload_url, headers=post_headers, data=payload)
    upload_fmw_result.raise_for_status()
    log.debug("FMW script uploaded")

    # register the service `fmejobsubmitter` to the fmw script
    log.debug("Register `fmejobsubmitter` service")
    reg_service_url = '{FME_SERVER}/{url_connect}/{repo_name}/items/{filename}/services?detail=low&accept=json'.format(
        FME_SERVER=FME_SERVER, url_connect=url_repositories,
        repo_name=repo_name, filename=filename)
    reg_service_headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',

        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}
    reg_service_res = requests.post(reg_service_url, headers=reg_service_headers, data="services=fmejobsubmitter")
    reg_service_res.raise_for_status()
    log.debug("Registered `fmejobsubmitter` service")


def upload_imgeo_xsd():
    """
    Upload the fmw file from `030_inlezen_BGT/xsd`to the Import_XSD
    """
    url_connect = 'fmerest/v2/resources/connections'

    delete_directory('Import_XSD')
    create_directory('Import_XSD')

    # upload the file
    log.debug("Upload imgeo.xsd to `Import_XSD` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Import_XSD?createDirectories=false&detail=low' \
          '&overwrite=false'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)

    headers = {
        'Content-Disposition': 'attachment; filename="{}"'.format('imgeo.xsd'),
        'Content-Type': 'application/octet-stream',
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API),
    }

    log.debug('Uploading imgeo.xsd')
    payload = open('../app/030_inlezen_BGT/xsd/imgeo.xsd', encoding='utf-8').read()
    repository_res = requests.post(url, data=payload, headers=headers)
    repository_res.raise_for_status()
    log.debug("Upload imgeo.xsd completed")

def upload_import_kaartbladen():
    """
    Upload the fmw file from `030_inlezen_BGT/bron_shapes`to the Import_XSD
    """
    url_connect = 'fmerest/v2/resources/connections'

    # delete_directory('Import_kaartbladen')
    # create_directory('Import_kaartbladen')

    # upload the file
    log.debug("Upload BGT_kaartbladen.shp to `Import_kaartbladen` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Import_kaartbladen?createDirectories=false&detail=low' \
          '&overwrite=false'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)

    headers = {
        'Content-Disposition': 'attachment; filename="{}"'.format('BGT_kaartbladen.shp'),
        'Content-Type': 'application/octet-stream',
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API),
    }

    log.debug('Uploading BGT_kaartbladen.shp')
    payload = open('../app/030_inlezen_BGT/bron_shapes/BGT_kaartbladen.shp', encoding='utf-8').read()
    repository_res = requests.post(url, data=payload, headers=headers)
    repository_res.raise_for_status()
    log.debug("Upload BGT_kaartbladen.shp completed")


def start_transformation_db(repository, workspace):
    """
    Step 3: Start Transformation Job
    """
    urltransform = 'fmerest/v2/transformations'
    target_url = '{FME_SERVER}/{urltransform}/commands/submit/{repository}/{workspace}?detail=low&accept=json'.format(
        FME_SERVER=FME_SERVER, urltransform=urltransform, repository=repository, workspace=workspace)

    try:
        response = requests.post(
            url=target_url,
            headers={
                "Referer": "{FME_SERVER}/fmerest/v2/apidoc/".format(FME_SERVER=FME_SERVER),
                "Origin": "{FME_SERVER}".format(FME_SERVER=FME_SERVER),
                "Authorization": "fmetoken token={FME_API}".format(FME_API=FME_API),
                "Content-Type": "application/json",
                "Accept": "application/json",
            },

            data=json.dumps({
                "subsection": "REST_SERVICE",
                "FMEDirectives": {},
                "NMDirectives": {
                    "successTopics": [],
                    "failureTopics": []
                },
                "TMDirectives": {
                    "tag": "linux",
                    "description": "DB BGT uit city gml"
                },
                "publishedParameters": [
                    {
                        "name": "DestDataset_POSTGIS_4",
                        "value": "bgt"
                    },
                    {
                        "name": "CITYGML_IN_ADE_XSD_DOC_CITYGML",
                        "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_XSD/imgeo.xsd"]
                    },
                    {
                        "name": "SourceDataset_CITYGML",
                        "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_GML/bgt_buurt.gml"]
                    },
                    {
                        "name": "bron_BGT_kaartbladen",
                        "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_kaartbladen/BGT_kaartbladen.shp"]
                    }
                ]
            })
        )

        log.debug('Response HTTP Status Code: {status_code}'.format(status_code=response.status_code))
        log.debug('Response HTTP Response Body: {content}'.format(content=response.content))

        res = response.json()
        log.debug('Job started! Job ID: {}'.format(res['id']))
        return {'jobid': res['id'], 'urltransform': urltransform}

    except requests.exceptions.RequestException:
        log.debug('HTTP Request failed')


def start_transformation_shapes(repository, workspace):
    """
    Step 3: Start Transformation Job
    """
    log.info("Starting transformation")

    # delete_directory('Export_Shapes')
    # create_directory('Export_Shapes')

    # delete_directory('Export_Shapes_Totaalgebied')
    # create_directory('Export_Shapes_Totaalgebied')

    urltransform = 'fmerest/v2/transformations'
    target_url = '{FME_SERVER}/{urltransform}/commands/submit/{repository}/{workspace}?detail=low&accept=json'.format(
        FME_SERVER=FME_SERVER, urltransform=urltransform, repository=repository, workspace=workspace)

    response = requests.post(
        url=target_url,
        headers={
            "Referer": "{FME_SERVER}/fmerest/v2/apidoc/".format(FME_SERVER=FME_SERVER),
            "Origin": "{FME_SERVER}".format(FME_SERVER=FME_SERVER),
            "Authorization": "fmetoken token={FME_API}".format(FME_API=FME_API),
            "Content-Type": "application/json",
            "Accept": "application/json",
        },

        data=json.dumps({
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {
                "successTopics": [],
                "failureTopics": []
            },
            "TMDirectives": {
                "tag": "linux",
                "description": "Aanmaak Shapes uit DB"
            },
            "publishedParameters": [
                {
                    "name": "SourceDataset_POSTGIS",
                    "value": "bgt"
                },
                {
                    "name": "SourceDataset_POSTGIS_3",
                    "value": "bgt"
                },
                {
                    "name": "DestDataset_ESRISHAPE2",
                    "value": "$(FME_SHAREDRESOURCE_DATA)/Export_Shapes/"
                },
                {
                    "name": "DestDataset_ESRISHAPE3",
                    "value": "$(FME_SHAREDRESOURCE_DATA)/Export_Shapes_Totaalgebied/"
                }
            ]
        })
    )

    log.debug('Response HTTP Status Code: {status_code}'.format(status_code=response.status_code))
    log.debug('Response HTTP Response Body: {content}'.format(content=response.content))

    response.raise_for_status()

    res = response.json()
    log.debug('Job started! Job: {}'.format(res))
    return {'jobid': res['id'], 'urltransform': urltransform}


def _get_job_status(job):
    url = '{FME_SERVER}/{urltransform}/jobs/id/{jobid}?detail=low'.format(
        FME_SERVER=FME_SERVER, urltransform=job['urltransform'], jobid=job['jobid'])
    res = requests.get(url, headers=fme_api_auth())
    res.raise_for_status()

    status = res.json()['status']

    log.debug("Status for job %s: %s", job, status)
    return status


def wait_for_job_to_complete(job):
    """
    Step 3: Now wait for the job to be completed
    """
    time.sleep(300)

    while _get_job_status(job) != 'SUCCESS':
        time.sleep(300)

    log.debug("Job completed!")


def create_db_schema_bgt():
    """
    Starts the existing scripts `020_aanmaak_DB_schemas_BGT`
    """
    here = os.getcwd()
    os.chdir('../app')
    log.debug(os.getcwd())
    os.putenv('PGPASSWORD',FME_DBPASS)
    sql_script = "020_create_schema.sql"
    # psql -h ${1} -d ${2} -p ${3} -U ${4} -f 020_create_schema.sql
    subprocess.call("psql -h {FME_SERVER} -d gisdb -p 5432 -U dbuser -f {SQL}".format(
        FME_SERVER=FME_SERVER.split('//')[-1], SQL=sql_script), shell=True)
    os.chdir(here)


def aanmaak_db_tabellen_bgt():
    """
    Starts the existing scripts `060_aanmaak_tabel_BGT_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/')
    log.debug(os.getcwd())
    sql_script = "060_aanmaak_tabellen_BGT.sql"
    subprocess.call("psql -h {FME_SERVER} -d gisdb -p 5432 -U dbuser -f {SQL}".format(
        FME_SERVER=FME_SERVER.split('//')[-1], SQL=sql_script), shell=True)
    os.chdir(here)

def aanmaak_db_mapping():
    """
    Add mapping file
    """
    here = os.getcwd()
    os.chdir('../app/')
    log.debug(os.getcwd())
    sql_script = "060_aanmaak_mapping.sql"
    subprocess.call("psql -h {FME_SERVER} -d gisdb -p 5432 -U dbuser -f {SQL}".format(
        FME_SERVER=FME_SERVER.split('//')[-1], SQL=sql_script), shell=True)
    os.chdir(here)


def aanmaak_db_views_shapes_bgt():
    """
    Starts the existing scripts `090_aanmaak_views_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/')
    log.debug(os.getcwd())

    sql_script = "090_aanmaak_DB_views_BGT.sql"
    subprocess.call("psql -h {FME_SERVER} -d gisdb -p 5432 -U dbuser -f {SQL}".format(
        FME_SERVER=FME_SERVER.split('//')[-1], SQL=sql_script), shell=True)
    sql_script = "090_aanmaak_DB_views_IMGEO.sql"
    subprocess.call("psql -h {FME_SERVER} -d gisdb -p 5432 -U dbuser -f {SQL}".format(
        FME_SERVER=FME_SERVER.split('//')[-1], SQL=sql_script), shell=True)
    os.chdir(here)

def import_gml_controledb():
    """
    Starts the existing scripts `070_import_controledb`
    """
    here = os.getcwd()
    os.chdir('../app/')
    log.debug(os.getcwd())
    subprocess.call("sh 070_import_gml_controledb.sh {FME_SERVER} gisdb 5432 dbuser".format(
        FME_SERVER=FME_SERVER.split('//')[-1]), shell=True)
    os.chdir(here)


def unzip_pdok_file():
    """
    Unzip the extract_bgt.zip file into the `/tmp/data` directory
    :return:
    """
    log.info("Start unzipping contents")
    with ZipFile('extract_bgt.zip', 'r') as myzip:
        myzip.extractall('/tmp/data/')
    log.info("Unzip complete")
    return  0


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
             "codes": [38121,38115,38120,38077,38076,38078,38079,38421,38423,38429,38431,38474,38475,38478,38479,38490,
                       38491,38494,38516,38518,38690,38525,38696,38688,38666,38667,38670,38671,38682,38680,38681,38675,
                       38673,38331,38329,38323,38321,38299,38298,38287,38285,38284,38281,38275,38274,38103,38109,38280,
                       38108,38105,38104,38093,38092,38094,38116,38674,38672,38330,38328,38317,38476,38477,38488,38489,
                       38492,38493,38495,38664,38665,38668,38517,38466,38467,38118,38119,38117,38095,38106,38107,38110,
                       38111,38282,38283,38316,38319,38472,38464,38465,38122,38470,38471,38468,38469,38126,38127,38124,
                       38125,38482,38480,38138,38136,38483,38481,38139,38140,38142,38484,38486,38487,38485,38143,38141,
                       38134,38132,38133,38135,38306,38304,38312,38314,38130,38128,38129,38131,38137,38313,38307,38308,
                       38310,38315,38318,38656,38658,38659,38657,38662,38660,38661,38663,38311,38309,38320,38322]
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

    # download_bgt()
    try:
        server_manager.start()
        # create_db_schema_bgt()
        # upload_gml_files()
        # upload_repositories('BGT-DB')
        # upload_fmw_script('BGT-DB', '../app/030_inlezen_BGT/fme', 'inlezen_DB_BGT_uit_citygml.fmw')
        # TODO: Create db connection in FMECLoud manually - NOT POSSIBLE IN CURRENT API VERSION
        # TODO: When uploading XSD the error is: Multi-byte error - NOW DONE MANUALLY
        # upload_imgeo_xsd()
        # TODO: FIX IMport kaartbladen - upload ALL files, some are binary & also allow create/delete to work
        # upload_import_kaartbladen()
        # try:
        #     wait_for_job_to_complete(start_transformation_db('BGT-DB', 'inlezen_DB_BGT_uit_citygml.fmw'))
        # except Exception:
        #     exit(0)
        # TODO When FME_FAILURE -> stop job and dump FME logs?
        os.putenv('PGPASSWORD',FME_DBPASS)
        # aanmaak_db_tabellen_bgt()
        # aanmaak_db_views_shapes_bgt()
        upload_repositories('BGT-SHAPES')
        upload_fmw_script('BGT-SHAPES', '../app/100_aanmaak_producten_BGT', 'aanmaak_esrishape_uit_DB_BGT.fmw')
        # TODO: for start_transformation_shapes: allow create/delete to work
        try:
            wait_for_job_to_complete(start_transformation_shapes('BGT-SHAPES', 'aanmaak_esrishape_uit_DB_BGT.fmw'))
        except Exception:
            exit(0)

        # TODO: download resulting shapes & upload to objectstore

        # TODO: 1) download db and do telling OR do it on remote database
        # TODO: Telling: 040
        import_gml_controledb()
        aanmaak_db_mapping()
        # TODO: Frequentie verdeling: 080
    except:
        log.exception("Could not process server jobs")
    finally:
        # server_manager.stop()
        pass
