import glob
import json
import logging
import os
import subprocess
import time
import urllib.parse
import urllib.request
from datetime import datetime

import requests

import fme_server

FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
FME_API = os.getenv('FMEAPI', 'secret')
FME_SERVER = os.getenv('FMESERVER', 'secret')
INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')

log = logging.getLogger(__name__)


def fme_api_auth():
    return {'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}


def delete_directory(directory):
    # delete directory
    log.info("Delete directory %s", directory)

    url = ('{FME_SERVER}/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA' +
           '/filesys/{directory}?detail=low'.format(FME_SERVER=FME_SERVER, directory=directory))

    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code == 404:
        log.debug("Directory not found")

    repository_res.raise_for_status()
    log.debug("Directory deleted")


def create_directory(directory):
    log.info("Create directory %s", directory)
    url = ('{FME_SERVER}/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA' +
           '/filesys/?detail=low'.format(FME_SERVER=FME_SERVER))

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
    for infile in glob.glob(os.path.join('..', path, '*.*')):
        with open(infile, 'rb') as f:
            filename = os.path.split(infile)[-1]
            headers = {
                'Content-Disposition': 'attachment; filename="{}"'.format(filename),
                'Content-Type': 'application/octet-stream',
                'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API),
            }
            log.debug('Uploading', infile, 'to', filename)
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
                        "value": "DestDataset_POSTGIS_4"
                    },
                    {
                        "name": "CITYGML_IN_ADE_XSD_DOC_CITYGML",
                        "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_XSD/imgeo.xsd"]
                    },
                    {
                        "name": "SourceDataset_CITYGML",
                        "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_GML/*.gml"]
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
    delete_directory('Export_Shapes')
    create_directory('Export_Shapes')

    delete_directory('Export_Shapes_Totaalgebied')
    create_directory('Export_Shapes_Totaalgebied')

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
                    "description": "Aanmaak Shapes uit DB"
                },
                "publishedParameters": [
                    {
                        "name": "SourceDataset_POSTGIS",
                        "value": "DestDataset_POSTGIS_4"
                    },
                    {
                        "name": "DestDataset_ESRISHAPE2",
                        "value": ["$(FME_SHAREDRESOURCE_DATA)/Export_Shapes/"]
                    },
                    {
                        "name": "DestDataset_ESRISHAPE3",
                        "value": ["$(FME_SHAREDRESOURCE_DATA)/Export_Shapes_Totaalgebied/"]
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


def wait_for_job_to_complete(job):
    """
    Step 3: Now wait for the job to be completed
    """
    log.debug("Wait 2 hours until polling for completion")
    time.sleep(7200)
    log.debug("2 hours have passed, now checking every 5 minutes")
    sleep = 300
    url = '{FME_SERVER}/{urltransform}/jobs/id/{jobid}/result?detail=low'.format(
        FME_SERVER=FME_SERVER, urltransform=job['urltransform'], jobid=job['jobid'])

    while True:
        res = requests.get(url, headers=fme_api_auth())
        res.raise_for_status()
        if res.json()['status'] == 'SUCCESS':
            break
        log.debug("Still processing, sleeping for {}".format(sleep))
        time.sleep(sleep)
    log.debug("Job completed!")


def create_db_schema_bgt():
    """
    Starts the existing scripts `020_aanmaak_DB_schemas_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/020_aanmaak_DB_schemas_BGT')
    log.debug(os.getcwd())

    subprocess.call("sh aanmaak_schemas_BGT.sh {FME_SERVER} gisdb 5432 dbuser".format(
        FME_SERVER=FME_SERVER.split('//')[-1]), shell=True)
    os.chdir(here)


def aanmaak_db_tabellen_bgt():
    """
    Starts the existing scripts `060_aanmaak_tabel_FV_cntrl_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/060_aanmaak_tabel_FV_cntrl_BGT')
    log.debug(os.getcwd())

    subprocess.call("sh aanmaak_tabellen_BGT.sh {FME_SERVER} gisdb 5432 dbuser".format(
        FME_SERVER=FME_SERVER.split('//')[-1]), shell=True)
    os.chdir(here)


def aanmaak_db_views_shapes_bgt():
    """
    Starts the existing scripts `090_aanmaak_views_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/090_aanmaak_VIEWS_BGT/aanmaak_views_bgt_shp')
    log.debug(os.getcwd())

    subprocess.call("sh aanmaak_DB_views_BGT_SHP.sh {FME_SERVER} gisdb 5432 dbuser".format(
        FME_SERVER=FME_SERVER.split('//')[-1]), shell=True)
    os.chdir(here)


def download_bgt():
    target = "extract_bgt.zip"
    pdok_extract = "https://www.pdok.nl/download/service/extract.zip"
    tiles = {
        "layers": [
            {"aggregateLevel": 0,
             "codes": [38519, 38690, 38517, 38495, 38666, 38688, 38516, 38494, 38664, 38665, 38668, 38669, 38493, 38492,
                       38489,
                       38488, 38477, 38476, 38473, 38472, 38429, 38423, 38421, 38079, 38077, 38076, 38070, 38071, 38114,
                       38115,
                       38113, 38116, 38094, 38092, 38086, 38087, 38098, 38099, 38102, 38103, 38101, 38272, 38273, 38275,
                       38278,
                       38279, 38285, 38296, 38297, 38299, 38321, 38323, 38329, 38331, 38673, 38675, 38674, 38680, 38663,
                       38662,
                       38659, 38658, 38487, 38486, 38483, 38482, 38471, 38470, 38468, 38469, 38465, 38467, 38466, 38464,
                       38122,
                       38120, 38121, 38123, 38126, 38124, 38118, 38127, 38125, 38119, 38480, 38138, 38136, 38130, 38128,
                       38117,
                       38481, 38484, 38485, 38656, 38139, 38142, 38143, 38314, 38137, 38140, 38141, 38312, 38131, 38134,
                       38135,
                       38306, 38095, 38093, 38106, 38104, 38129, 38107, 38105, 38132, 38110, 38108, 38133, 38111, 38109,
                       38304,
                       38282, 38280, 38274, 38657, 38315, 38313, 38660, 38318, 38316, 38310, 38307, 38661, 38672, 38319,
                       38330,
                       38317, 38328, 38311, 38322, 38320, 38298, 38287, 38309, 38305, 38308, 38283, 38286, 38281, 38284]
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

    log.info("Download complete")


if __name__ == '__main__':
    logging.basicConfig(
        level='DEBUG'
    )
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
        # TODO: Create db connection in FMECLoud
        upload_imgeo_xsd()
        # wait_for_job_to_complete(start_transformation_db('BGT-DB', 'inlezen_DB_BGT_uit_citygml.fmw'))
        # aanmaak_db_tabellen_bgt()
        # aanmaak_db_views_shapes_bgt()
        # upload_repositories('BGT-SHAPES')
        # upload_fmw_script('BGT-SHAPES', '../app/100_aanmaak_producten_BGT', 'aanmaak_esrishape_uit_DB_BGT.fmw')

        transformation_job = start_transformation_shapes('BGT-SHAPES', 'aanmaak_esrishape_uit_DB_BGT.fmw')
        wait_for_job_to_complete(transformation_job)
        # run transformation
        # download resulting shapes
        # download database
        # 030
        # 040
        # 070
        # 075
        # 080
    finally:
        # pass
        server_manager.stop()
