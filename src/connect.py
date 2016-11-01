import glob
import json
import logging
import os
import sys
import time
import mimetypes
import subprocess
import psycopg2
import psycopg2.extensions
import urllib.parse
import urllib.request
from datetime import datetime
from zipfile import ZipFile

import requests
import fme_server

DEBUG = os.getenv('DEBUG', False) == '1'
FME_SERVER_API = os.getenv('FMESERVERAPI', 'secret')
FME_API = os.getenv('FMEAPI', 'secret')
FME_SERVER = os.getenv('FMESERVER', 'secret')
INSTANCE_ID = os.getenv('FMEINSTANCE', 'secret')
FME_DBPASS = os.getenv('FMEDBPASS', 'secret')

log = logging.getLogger(__name__)


def fme_api_auth():
    return {'Authorization': 'fmetoken token={FME_API}'.format(FME_API=FME_API)}


def run_sql_script(script_name):
    """
    Runs the sql script against the FME database
    :param script_name:
    :return:
    """
    conn = psycopg2.connect(
        "host={} port={} dbname={} user={}  password={}".format(FME_SERVER.split('//')[-1], '5432', 'gisdb', 'dbuser',
                                                                FME_DBPASS))
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    dbcur = conn.cursor()
    try:
        procedures = open(script_name, 'r').read()
        dbcur.execute(procedures)
        dbcur.execute('commit')
    except psycopg2.DatabaseError as e:
        log.debug("Database script exception: procedures :%s" % str(e))
        sys.exit(1)


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
    repository_res.raise_for_status()
    log.debug("Directory deleted")


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
        log.debug("Directory not found")
    repository_res.raise_for_status()
    log.debug("Directory deleted")


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
        DIR=dir,
        FME_SERVER=FME_SERVER, url_connect=url_connect)

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
    :param recreate_dir: explicitly recreates the desitnation directory
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


def start_transformation_gebieden():
    log.info("Starting transformation")
    return run_transformation_job(
        'BGT-DB',
        'inlezen_gebieden_uit_Shape_en_WFS.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "DB BGT kaartbladen"},
            "publishedParameters": [{"name": "DestDataset_POSTGIS_4", "value": "bgt"},
                                    {"name": "bron_BGT_kaartbladen",
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_kaartbladen/BGT_kaartbladen.shp"]}]})


def start_transformation_db():
    log.info("Starting transformation")
    return run_transformation_job(
        'BGT-DB',
        'inlezen_DB_BGT_uit_citygml.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "DB BGT uit city gml"
                             },
            "publishedParameters": [{"name": "DestDataset_POSTGIS_4", "value": "bgt"},
                                    {"name": "CITYGML_IN_ADE_XSD_DOC_CITYGML",
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_XSD/imgeo.xsd"]},
                                    {"name": "SourceDataset_CITYGML",
                                     "value": ["$(FME_SHAREDRESOURCE_DATA)/Import_GML/bgt_buurt.gml"]}, ]})


def start_transformation_shapes():
    log.info("Starting transformation")

    # update data in `Export shapes` and  `Export_Shapes_Totaalgebied` directories
    delete_directory('Export_Shapes')
    create_directory('Export_Shapes')

    delete_directory('Export_Shapes_Totaalgebied')
    create_directory('Export_Shapes_Totaalgebied')

    return run_transformation_job(
        'BGT-SHAPES',
        'aanmaak_esrishape_uit_DB_BGT.fmw',
        {
            "subsection": "REST_SERVICE",
            "FMEDirectives": {},
            "NMDirectives": {"successTopics": [], "failureTopics": []},
            "TMDirectives": {"tag": "linux", "description": "Aanmaak Shapes uit DB"},
            "publishedParameters": [
                {"name": "SourceDataset_POSTGIS", "value": "bgt"},
                {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
                # TODO: check of dit zorgt voor download ZIP als naam eindigt op .zip.
                {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)/Export_Shapes"},
                {"name": "DestDataset_ESRISHAPE3", "value": "$(FME_SHAREDRESOURCE_DATA)/Export_Shapes_Totaalgebied/"}]})


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


def unzip_pdok_file():
    """
    Unzip the extract_bgt.zip file into the `/tmp/data` directory
    :return:
    """
    log.info("Start unzipping contents")
    with ZipFile('extract_bgt.zip', 'r') as myzip:
        myzip.extractall('/tmp/data/')
    log.info("Unzip complete")
    return 0


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
             "codes": [
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

    download_bgt()
    try:
        server_manager.start()
        run_sql_script("../app/020_create_schema.sql")

        # upload the GML files and FMW scripts
        upload('/tmp/data', 'resources/connections', 'Import_GML', '*.*', recreate_dir=True)
        upload_repository('../app/030_inlezen_BGT/fme', 'repositories', 'BGT-DB', '*.*', register_fmejob=True)

        # TODO: Create db connection in FMECLoud manually - NOT POSSIBLE IN CURRENT API VERSION
        upload('../app/030_inlezen_BGT/xsd', 'resources/connections', 'Import_XSD', 'imgeo.xsd')
        upload('../app/030_inlezen_BGT/bron_shapes', 'resources/connections', 'Import_kaartbladen', '*.*')
        try:
            wait_for_job_to_complete(start_transformation_gebieden())
            wait_for_job_to_complete(start_transformation_db())
        except Exception:
            sys.exit(1)

        run_sql_script("../app/060_aanmaak_tabellen_BGT.sql")

        # aanmaak db-views shapes_bgt
        run_sql_script("../app/090_aanmaak_DB_views_BGT.sql")
        run_sql_script("../app/090_aanmaak_DB_views_IMGEO.sql")

        # upload shapes fmw scripts naar reposiory
        upload_repository('../app/100_aanmaak_producten_BGT', 'BGT-SHAPES', '*.*', register_fmejob=True)

        # run the `aanmaak_esrishape_uit_DB_BGT` scrop
        try:
            wait_for_job_to_complete(start_transformation_shapes())
        except Exception:
            sys.exit(1)

        # TODO: download resulting shapes & upload to objectstore
        # TODO: 1) download db and do telling OR do it on remote database
        # TODO: Telling: 040

        # import controle db
        subprocess.call("../app/070_import_gml_controledb.sh", shell=True)

        # import csv / mapping db
        run_sql_script("../app/075_aanmaak_mapping.sql")

        # TODO: Frequentie verdeling: 080
    except:
        log.exception("Could not process server jobs")
    finally:
        server_manager.stop()
        sys.exit(0)
