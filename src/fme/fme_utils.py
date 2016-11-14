import glob
import time
import mimetypes
import os
import os.path
import json
import requests
import logging
from bgt_setup import FME_API, FME_SERVER

log = logging.getLogger(__name__)


def fme_api_auth():
    return {'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}


def delete_directory(directory):
    """
    Deletes a FME directory or FME repository
    :param directory: the directory name to delete
    :return:
    """
    log.info("Delete directory %s", directory)
    url = (
        '{FME_SERVER}/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA/filesys/{directory}?detail=low'.format(
            FME_SERVER=FME_SERVER, directory=directory))
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code == 404:
        log.debug("Directory not found")
        return repository_res.status_code
    repository_res.raise_for_status()
    log.debug("Directory deleted")
    return repository_res.status_code


def delete_repository(repo):
    """
    Deletes a FME repository
    :param repo: the repository name to delete
    :return:
    """
    log.info("Delete repository %s", repo)
    url = ('{FME_SERVER}/fmerest/v2/repositories/{repo}?detail=low'.format(FME_SERVER=FME_SERVER, repo=repo))
    repository_res = requests.delete(url, headers=fme_api_auth())
    if repository_res.status_code == 404:
        log.debug("Repository not found")
        return repository_res.status_code
    repository_res.raise_for_status()
    log.debug("Repository deleted")
    return repository_res.status_code


def create_directory(directory):
    """
    Creates a FME data directory
    :param directory: the directory name to delete
    :return:
    """
    log.info("Create directory %s", directory)
    url = ('{FME_SERVER}/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA'
           '/filesys/?detail=low'.format(FME_SERVER=FME_SERVER))
    res = requests.post(url, headers=fme_api_auth(), data={'directoryname': directory, 'type': 'DIR',})
    res.raise_for_status()
    log.debug("Directory created")


def create_repository(repo):
    """
    Creates a FME repository
    :param directory: the directory name to delete
    :return:
    """
    log.info("Create repository %s", repo)
    url = ('{FME_SERVER}/fmerest/v2/repositories/?detail=low'.format(FME_SERVER=FME_SERVER))
    res = requests.post(url, headers=fme_api_auth(), data={'name': repo})

    res.raise_for_status()
    log.debug("Directory created")


def _post_file(url, full_path, filename, payload):
    """
    HTTP Post file to FME server
    :param url: The url to post to
    :param full_path: the path to the local file
    :param filename:
    :param payload: the payload data
    :return:
    """
    content_type = mimetypes.MimeTypes().guess_type(str(payload))[0]
    if not content_type:
        content_type = "application/octet-stream"

    headers = {
        'Content-Disposition': 'attachment; filename="{}"'.format(filename),
        'Content-Type': content_type,
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API),
    }
    log.debug('Uploading {} to {}'.format(full_path, filename))
    repository_res = requests.post(url, data=payload, headers=headers)
    repository_res.raise_for_status()


def _register_fmejobsubmitter_service(repo_name, filename):
    """
    Register FME Job submitter
    :param repo_name:
    :param filename:
    :return:
    """
    # register the service `fmejobsubmitter` to a fmw script
    result = False
    url_repositories = 'fmerest/v2/repositories'

    log.debug("Register `fmejobsubmitter` service")
    reg_service_url = '{FME_SERVER}/{url_connect}/{repo_name}/items/{filename}/services?detail=low&accept=json'.format(
        FME_SERVER=FME_SERVER, url_connect=url_repositories, repo_name=repo_name, filename=filename)
    reg_service_headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)
    }
    reg_service_res = requests.post(reg_service_url, headers=reg_service_headers, data="services=fmejobsubmitter")
    reg_service_res.raise_for_status()
    result = True
    log.debug("Registered `fmejobsubmitter` service")
    return result


def upload(source_directory, repo, dir, files, recreate_dir=True):
    """
    Upload one or more files to FME
    :param source_directory: the local source directory
    :param repo: the FME repo
    :param dir: the FME directory in repo
    :param files: string with filename or wildcard expression
    :param recreate_dir: explicitly recreates the desitnation directory
    :return: bool
    """
    url_connect = 'fmerest/v2/{}'.format(repo)

    if recreate_dir:
        delete_directory(dir)
        create_directory(dir)

    url = '{FME_SERVER}/{url_connect}/FME_SHAREDRESOURCE_DATA/filesys/{DIR}?' \
          'createDirectories=false&detail=low&overwrite=false'.format(
        DIR=dir, FME_SERVER=FME_SERVER, url_connect=url_connect)

    for infile in glob.glob(os.path.join(source_directory, files)):
        log.debug('upload {}'.format(infile))
        with open(infile, 'rb') as f:
            _post_file(url, infile, os.path.split(infile)[-1], f.read())

    log.debug("Upload {} completed".format(files))


def upload_repository(source_directory, dir, files, recreate_repo=True, register_fmejob=False):
    """
    Upload one or more files to FME
    :param source_directory: the local source directory
    :param repo: the FME repo
    :param dir: the FME directory in repo
    :param files: string with filename or wildcard expression
    :param recreate_dir: explicitly recreates the destination directory
    :return: bool
    """
    url_connect = 'fmerest/v2/repositories/{}'.format(dir)

    if recreate_repo:
        delete_repository(dir)
        create_repository(dir)

    for infile in glob.glob(os.path.join(source_directory, files)):
        print(infile)
        with open(infile, 'rb') as f:
            url = '{FME_SERVER}/{url_connect}/items?detail=low&accept=json'.format(
                FME_SERVER=FME_SERVER, url_connect=url_connect)
            _post_file(url, infile, os.path.split(infile)[-1], f.read())
            if register_fmejob:
                _register_fmejobsubmitter_service(dir, os.path.split(infile)[-1])

    log.debug("Upload {} completed".format(files))


def run_transformation_job(repository, workspace, params):
    """
    Run transformation job on FME cloud
    :param repository: FME repository name
    :param workspace:  FME workspace name
    :param params: dict with params for the job `Run params can be found in FME with FMW file`.
    :return:
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
                "Accept": "application/json"}, data=json.dumps(params))

        log.debug('Response HTTP Status Code: {status_code}'.format(status_code=response.status_code))
        log.debug('Response HTTP Response Body: {content}'.format(content=response.content))
        res = response.json()
        log.debug('Job started! Job ID: {}'.format(res['id']))
        return {'jobid': res['id'], 'urltransform': urltransform}
    except requests.exceptions.RequestException:
        log.debug('HTTP Request failed')

def fetch_log_for_job(job):
    """
    Fetches the logfile for job `job`
    :param job:
    :return:
    """
    url = '{FME_SERVER}/{urltransform}/jobs/id/{jobid}/log?detail=low'.format(
        FME_SERVER=FME_SERVER, urltransform=job['urltransform'], jobid=job['jobid'])
    res = requests.get(url, headers=fme_api_auth())
    res.raise_for_status()
    return res.content.decode(encoding='utf-8')


def get_job_status(job):
    """
    Fetches the job status for job `job`
    :param job:
    :return:
    """
    url = '{FME_SERVER}/{urltransform}/jobs/id/{jobid}?detail=low'.format(
        FME_SERVER=FME_SERVER, urltransform=job['urltransform'], jobid=job['jobid'])
    res = requests.get(url, headers=fme_api_auth())
    res.raise_for_status()
    status = res.json()['status']
    log.debug("Status for job %s: %s", job, status)
    return status
    return status


def wait_for_job_to_complete(job):
    """
    Monitors the job, waits for it to complete and reports in log.
    :param job:  dictionary with `jobid` and `urltransform`
    :return:
    """
    while get_job_status(job) in ['SUBMITTED', 'QUEUED', 'PULLED']:
        time.sleep(60)

    # Job is completed or has failed, check and report
    job_status = get_job_status(job)
    log.debug("Job completed with status: {}".format(job_status))

    if job_status != 'SUCCESS':
        for line in fetch_log_for_job(job).split('\n'):
            log.debug("Log for job {} {}".format(job['jobid'], line))

    log.debug("Job {} finished with status {}".format(job['jobid'], job_status))
