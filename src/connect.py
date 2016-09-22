import requests
import os
import glob
import time
import json
import socket
import subprocess


FMESERVERAPI = os.getenv('FMESERVERAPI', 'secret')
FMEAPI = os.getenv('FMEAPI', 'secret')
FMESERVER = os.getenv('FMESERVER', 'secret')
INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')


def fme_url():
    return 'https://api.fmecloud.safe.com/v1/instances/{}'.format(INSTANCE_ID)


def fme_auth():
    return {'Authorization': 'bearer {FMESERVERAPI}'.format(FMESERVERAPI=FMESERVERAPI)}


def fme_api_auth():
    return {'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI)}


def server_in_dns():
    try:
        socket.gethostbyname(FMESERVER.split('//')[-1])
        print('DNS is available for server')
        return True
    except:
        return False


def start_server():
    """
    Start the FME instance
    """
    print("Starting server")
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
        print("Waiting for server to start, sleeping for {} seconds".format(sleep))
        time.sleep(sleep)
    print("Server started")
    print("Waiting for DNS availability of server")

    while not server_in_dns():
        time.sleep(2)

    print("Continuing")


def upload_gml_files():
    """
    Step 1: Upload the GML files
    """
    urlconnect = 'fmerest/v2/resources/connections'

    # delete directory
    print ("Delete existing `Import_GML` directory")
    url = '{FMESERVER}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/Import_GML?detail=low'.format(
        FMESERVER=FMESERVER, urlconnect=urlconnect)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        print("Directory not found")
    else:
        print("Directory deleted")

    # create directory
    print("Create new `Import_GML` directory")
    url = '{FMESERVER}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
        FMESERVER=FMESERVER, urlconnect=urlconnect)
    body = {
        'directoryname': 'Import_GML',
        'type': 'DIR',
    }
    repository_res = requests.post(url, data=body, headers=fme_api_auth())
    repository_res.raise_for_status()
    print("Directory created")

    # upload files
    print("Upload files to `Import_GML` directory")
    url = '{FMESERVER}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/Import_GML?createDirectories=false&detail=low&overwrite=false'.format(
        FMESERVER=FMESERVER, urlconnect=urlconnect)
    path = 'data'
    for infile in glob.glob(os.path.join('..', path, '*.*')):
        with open(infile, 'rb') as f:
            filename = os.path.split(infile)[-1]
            headers = {
                'Content-Disposition': 'attachment; filename="{}"'.format(filename),
                'Content-Type': 'application/octet-stream',
                'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI),
            }
            print('Uploading', infile, 'to', filename)
            repository_res = requests.post(url, data=f, headers=headers)
            repository_res.raise_for_status()
    print ("Upload files completed")


def upload_repositories():
    """
    Step 2: Create/Upload Transformation Repository
    """
    urlrepositories = 'fmerest/v2/repositories'
    repo_name = 'BGT'

    # delete repository <repo_name>
    url = '{FMESERVER}/{urlconnect}/{repo_name}?detail=low'.format(
        FMESERVER=FMESERVER, urlconnect=urlrepositories, repo_name=repo_name)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        print("Repository not found")
    else:
        print("Repository deleted")

    # create repository
    create_url = '{FMESERVER}/{urlconnect}?detail=low&accept=json'.format(
        FMESERVER=FMESERVER, urlconnect=urlrepositories)
    post_headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
        'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI)}
    payload = {'description': repo_name, 'name': repo_name, }
    create_repo_result = requests.post(create_url, headers=post_headers, data=payload)
    create_repo_result.raise_for_status()
    print("Repository created")


def upload_fmw_script():
    """
    Upload the fmw file from `030_inlezen_BGT/fme`
    """
    urlrepositories = 'fmerest/v2/repositories'
    repo_name = 'BGT'
    print("Delete existing FMW file (if exists)")
    delete_url = '{FMESERVER}/{urlconnect}/{repo_name}/items/{filename}?detail=low&accept=json'.format(
        FMESERVER=FMESERVER, urlconnect=urlrepositories,
        repo_name=repo_name, filename='inlezen_DB_BGT_uit_citygml.fmw')
    delete_headers = {
        'Accept': 'application/json',
        'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI)}
    delete_fmw_result = requests.delete(delete_url, headers=delete_headers)
    if delete_fmw_result.status_code not in [404, 204]:
        delete_fmw_result.raise_for_status()
    elif delete_fmw_result.status_code == 404:
        print("Existing FMW file not found.")
    else:
        print("Existing FMW file deleted.")

    print("Upload FMW file")
    upload_url = '{FMESERVER}/{urlconnect}/{repo_name}/items?detail=low&accept=json'.format(
        FMESERVER=FMESERVER, urlconnect=urlrepositories, repo_name=repo_name)
    post_headers = {
        'Content-Disposition': 'attachment; filename="inlezen_DB_BGT_uit_citygml.fmw"',
        'Content-Type': 'application/octet-stream',
        'Accept': 'application/json',
        'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI)}
    payload = open("../app/030_inlezen_BGT/fme/inlezen_DB_BGT_uit_citygml.fmw", encoding="utf-8").read()
    upload_fmw_result = requests.post(upload_url, headers=post_headers, data=payload)
    upload_fmw_result.raise_for_status()
    print("FMW script uploaded")

    # register the service `fmejobsubmitter` to the fmw script
    print("Register `fmejobsubmitter` service")
    reg_service_url = '{FMESERVER}/{urlconnect}/{repo_name}/items/{filename}/services?detail=low&accept=json'.format(
        FMESERVER=FMESERVER, urlconnect=urlrepositories,
        repo_name=repo_name, filename='inlezen_DB_BGT_uit_citygml.fmw')
    reg_service_headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',

        'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI)}
    reg_service_res = requests.post(reg_service_url, headers=reg_service_headers, data="services=fmejobsubmitter")
    reg_service_res.raise_for_status()
    print("Registered `fmejobsubmitter` service")


def upload_imgeo_xsd():
    """
    Upload the fmw file from `030_inlezen_BGT/xsd`to the Import_XSD
    """
    urlconnect = 'fmerest/v2/resources/connections'

    # delete directory
    print ("Delete existing `Import_XSD` directory")
    url = '{FMESERVER}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/Import_XSD?detail=low'.format(
        FMESERVER=FMESERVER, urlconnect=urlconnect)
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code not in [404, 204]:
        repository_res.raise_for_status()
    elif repository_res.status_code == 404:
        print("Directory not found")
    else:
        print("Directory deleted")

    # create directory
    print("Create new `Import_XSD` directory")
    url = '{FMESERVER}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/?detail=low'.format(
        FMESERVER=FMESERVER, urlconnect=urlconnect)
    body = {
        'directoryname': 'Import_XSD',
        'type': 'DIR',
    }
    repository_res = requests.post(url, data=body, headers=fme_api_auth())
    repository_res.raise_for_status()
    print("Directory created")

    # upload the file
    print("Upload imgeo.xsd to `Import_XSD` directory")
    url = '{FMESERVER}/{urlconnect}/FME_SHAREDRESOURCE_DATA/filesys/Import_XSD?createDirectories=false&detail=low&overwrite=false'.format(
        FMESERVER=FMESERVER, urlconnect=urlconnect)

    headers = {
        'Content-Disposition': 'attachment; filename="{}"'.format('imgeo.xsd'),
        'Content-Type': 'application/octet-stream',
        'Authorization': 'fmetoken token={FMEAPI}'.format(FMEAPI=FMEAPI),
    }

    print('Uploading imgeo.xsd')
    payload = open('../app/030_inlezen_BGT/xsd/imgeo.xsd', encoding='utf-8').read()
    repository_res = requests.post(url, data=payload, headers=headers)
    repository_res.raise_for_status()
    print ("Upload imgeo.xsd completed")


def start_transformation(repository, workspace):
    """
    Step 3: Start Transformation Job
    """
    urltransform = 'fmerest/v2/transformations'
    target_url = '{FMESERVER}/{urltransform}/commands/submit/{repository}/{workspace}?detail=low&accept=json'.format(
        FMESERVER=FMESERVER, urltransform=urltransform, repository=repository, workspace=workspace)

    try:
        response = requests.post(
            url=target_url,
            headers={
                "Referer": "{FMESERVER}/fmerest/v2/apidoc/".format(FMESERVER=FMESERVER),
                "Origin": "{FMESERVER}".format(FMESERVER=FMESERVER),
                "Authorization": "fmetoken token={FMEAPI}".format(FMEAPI=FMEAPI),
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

        print('Response HTTP Status Code: {status_code}'.format(status_code=response.status_code))
        print('Response HTTP Response Body: {content}'.format(content=response.content))

        res = response.json()
        print('Job started! Job ID: {}'.format(res['id']))
        return {'jobid': res['id'], 'urltransform': urltransform}

    except requests.exceptions.RequestException:
        print('HTTP Request failed')


def wait_for_job_to_complete(job):
    """
    Step 3: Now wait for the job to be completed
    """
    print("Wait 2 hours until polling for completion")
    time.sleep(7200)
    print("2 hours have passed, now checking every 5 minutes")
    sleep = 300
    url = '{FMESERVER}/{urltransform}/jobs/id/{jobid}/result?detail=low'.format(
        FMESERVER=FMESERVER, urltransform=job['urltransform'], jobid=job['jobid'])

    while True:
        res = requests.get(url, headers=fme_api_auth())
        res.raise_for_status()
        if res.json()['status'] == 'SUCCESS':
            break
        print("Still processing, sleeping for {}".format(sleep))
        time.sleep(sleep)
    print("Job completed!")


def create_db_schema_bgt():
    """
    Starts the existing scripts `020_aanmaak_DB_schemas_BGT`
    """
    here = os.getcwd()
    os.chdir('../app/020_aanmaak_DB_schemas_BGT')
    print (os.getcwd())

    subprocess.call("sh START_SH_aanmaak_schemas_BGT.sh {FMESERVER} gisdb 5432 dbuser".format(
        FMESERVER=FMESERVER.split('//')[-1]), shell=True)
    os.chdir(here)


if __name__ == '__main__':
    print("Running")
    start_server()
    create_db_schema_bgt()
    # upload_gml_files()
    upload_repositories()
    upload_fmw_script()
    # upload_imgeo_xsd() # TODO find out what we can do to make the utf-8 error disappear
    wait_for_job_to_complete(start_transformation('BGT', 'inlezen_DB_BGT_uit_citygml.fmw'))

