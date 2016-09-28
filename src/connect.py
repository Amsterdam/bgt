import logging

import requests
import os
import glob
import time
import json
import socket
import subprocess


FME_SERVER_API = os.getenv('FME_SERVER_API', 'secret')
FME_API = os.getenv('FME_API', 'secret')
FME_SERVER = os.getenv('FME_SERVER', 'secret')
INSTANCE_ID = os.getenv('FME_INSTANCE', 'secret')


log = logging.getLogger(__name__)


def fme_url():
    return 'https://api.fmecloud.safe.com/v1/instances/{}'.format(INSTANCE_ID)


def fme_auth():
    return {'Authorization': 'bearer {FME_SERVER_API}'.format(FME_SERVER_API=FME_SERVER_API)}


def fme_api_auth():
    return {'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}


def server_in_dns():
    try:
        socket.gethostbyname(FME_SERVER.split('//')[-1])
        log.debug('DNS is available for server')
        return True
    except:
        log.warn("No DNS available for server")
        return False


def start_server():
    """
    Start the FME instance
    """
    log.debug("Starting server")
    res = requests.get(fme_url(), headers=fme_auth())
    res.raise_for_status()

    if res.json()['state'] != 'RUNNING':
        server_res = requests.put('{}/start'.format(fme_url()), headers=fme_auth())
        server_res.raise_for_status()

    sleep = 10
    while True:
        res = requests.get(fme_url(), headers=fme_auth())
        res.raise_for_status()
        if res.json()['state'] == 'RUNNING':
            break
        log.debug("Waiting for server to start, sleeping for {} seconds".format(sleep))
        time.sleep(sleep)
    log.debug("Server started")
    log.debug("Waiting for DNS availability of server")

    while not server_in_dns():
        time.sleep(2)

    log.debug("Continuing")


def upload_gml_files():
    """
    Step 1: Upload the GML files
    """
    url_connect = 'fmerest/v2/resources/connections'

    # delete directory
    log.debug ("Delete existing `Import_GML` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Import_GML?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        log.debug("Directory not found")
    else:
        log.debug("Directory deleted")

    # create directory
    log.debug("Create new `Import_GML` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    body = {
        'directoryname': 'Import_GML',
        'type': 'DIR',
    }
    repository_res = requests.post(url, data=body, headers=fme_api_auth())
    repository_res.raise_for_status()
    log.debug("Directory created")

    # upload files
    log.debug("Upload files to `Import_GML` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Import_GML?createDirectories=false&detail=low&overwrite=false'.format(
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
    log.debug ("Upload files completed")


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
    payload = {'description': repo_name, 'name': repo_name, }
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

    # delete directory
    log.debug ("Delete existing `Import_XSD` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Import_XSD?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        log.debug("Directory not found")
    else:
        log.debug("Directory deleted")

    # create directory
    log.debug("Create new `Import_XSD` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    body = {
        'directoryname': 'Import_XSD',
        'type': 'DIR',
    }
    repository_res = requests.post(url, data=body, headers=fme_api_auth())
    repository_res.raise_for_status()
    log.debug("Directory created")

    # upload the file
    log.debug("Upload imgeo.xsd to `Import_XSD` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Import_XSD?createDirectories=false&detail=low&overwrite=false'.format(
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
    log.debug ("Upload imgeo.xsd completed")


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
    url_connect = 'fmerest/v2/resources/connections'

    # delete directory
    log.debug ("Delete existing `Export_Shapes` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Export_Shapes?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        log.debug("Directory not found")
    else:
        log.debug("Directory deleted")

    # create directory
    log.debug("Create new `Export_Shapes` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    body = {
        'directoryname': 'Export_Shapes',
        'type': 'DIR',
    }
    repository_res = requests.post(url, data=body, headers=fme_api_auth())
    repository_res.raise_for_status()
    log.debug("Directory created")

    # delete directory
    log.debug ("Delete existing `Export_Shapes_Totaalgebied` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/Export_Shapes_Totaalgebied?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        log.debug("Directory not found")
    else:
        log.debug("Directory deleted")

    # create directory
    log.debug("Create new `Export_Shapes_Totaalgebied` directory")
    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
        FME_SERVER=FME_SERVER, url_connect=url_connect)
    body = {
        'directoryname': 'Export_Shapes_Totaalgebied',
        'type': 'DIR',
    }
    repository_res = requests.post(url, data=body, headers=fme_api_auth())
    repository_res.raise_for_status()
    log.debug("Directory created")

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
    log.debug (os.getcwd())

    subprocess.call("sh aanmaak_schemas_BGT.sh {FME_SERVER} gisdb 5432 dbuser".format(
        FME_SERVER=FME_SERVER.split('//')[-1]), shell=True)
    os.chdir(here)


def aanmaak_db_tabellen_bgt():
    """
    Starts the existing scripts `060_aanmaak_tabel_FV_cntrl_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/060_aanmaak_tabel_FV_cntrl_BGT')
    log.debug (os.getcwd())

    subprocess.call("sh aanmaak_tabellen_BGT.sh {FME_SERVER} gisdb 5432 dbuser".format(
        FME_SERVER=FME_SERVER.split('//')[-1]), shell=True)
    os.chdir(here)


def aanmaak_db_views_shapes_bgt():
    """
    Starts the existing scripts `090_aanmaak_views_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/090_aanmaak_VIEWS_BGT/aanmaak_views_bgt_shp')
    log.debug (os.getcwd())

    subprocess.call("sh aanmaak_DB_views_BGT_SHP.sh {FME_SERVER} gisdb 5432 dbuser".format(
        FME_SERVER=FME_SERVER.split('//')[-1]), shell=True)
    os.chdir(here)


if __name__ == '__main__':
    logging.basicConfig(
        level='DEBUG'
    )
    logging.getLogger('requests').setLevel('WARNING')
    log.debug("Starting")

    # TODO: Download files within python instead of bash/wget
    start_server()
    # create_db_schema_bgt()
    # upload_gml_files()
    # upload_repositories('BGT-DB')
    # upload_fmw_script('BGT-DB', '../app/030_inlezen_BGT/fme', 'inlezen_DB_BGT_uit_citygml.fmw')
    # TODO: Create db connection in FMECLoud
    # upload_imgeo_xsd() # TODO find out what we can do to make the utf-8 error disappear
    # wait_for_job_to_complete(start_transformation_db('BGT-DB', 'inlezen_DB_BGT_uit_citygml.fmw'))
    # aanmaak_db_tabellen_bgt()
    # aanmaak_db_views_shapes_bgt()
    # upload_repositories('BGT-SHAPES')
    # upload_fmw_script('BGT-SHAPES', '../app/100_aanmaak_producten_BGT', 'aanmaak_esrishape_uit_DB_BGT.fmw')

    wait_for_job_to_complete(start_transformation_shapes('BGT-SHAPES', 'aanmaak_esrishape_uit_DB_BGT.fmw'))
    # run transformation
    # download resulting shapes
    # download database
    # 030
    # 040
    # 070
    # 075
    # 080
