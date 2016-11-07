import pytest
import requests

from unittest.mock import MagicMock, create_autospec
import fme.fme_utils as fme_utils


@pytest.fixture
def requests_delete(mocker):
    return mocker.patch('requests.delete')


@pytest.fixture
def requests_post(mocker):
    return mocker.patch('requests.post')


@pytest.fixture
def fme_utils_log(mocker):
    return mocker.patch('fme.fme_utils.log')


def test_fme_ap_auth():
    assert {'Authorization': 'fmetoken token=secret'} == fme_utils.fme_api_auth()


def test_delete_directory_fails(requests_delete, fme_utils_log):
    requests_delete.return_value = MagicMock(status_code=404)
    fme_utils.delete_directory('test')
    requests_delete.assert_called_once_with(
        'secret/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA/filesys/test?detail=low',
        headers={'Authorization': 'fmetoken token=secret'})
    fme_utils_log.debug.assert_called_once_with("Directory not found")


def test_delete_directory(requests_delete, fme_utils_log):
    requests_delete.returnvalue = MagicMock(status_code=204)
    fme_utils.delete_directory('test', )
    requests_delete.assert_called_once_with(
        'secret/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA/filesys/test?detail=low',
        headers={'Authorization': 'fmetoken token=secret'})
    fme_utils_log.debug.assert_called_once_with("Directory deleted")


def test_delete_repository_fails(requests_delete, fme_utils_log):
    requests_delete.return_value = MagicMock(status_code=404)
    fme_utils.delete_repository('test')
    requests_delete.assert_called_once_with(
        'secret/fmerest/v2/repositories/test?detail=low',
        headers={'Authorization': 'fmetoken token=secret'})
    fme_utils_log.debug.assert_called_once_with("Repository not found")


def test_delete_repository(requests_delete, fme_utils_log):
    requests_delete.return_value = MagicMock(status_code=204)
    fme_utils.delete_repository('test')
    requests_delete.assert_called_once_with(
        'secret/fmerest/v2/repositories/test?detail=low',
        headers={'Authorization': 'fmetoken token=secret'})
    fme_utils_log.debug.assert_called_once_with("Repository deleted")


def test_create_directory_fails(requests_post, fme_utils_log):
    requests_post.return_value = MagicMock(status_code=403)
    fme_utils.create_directory('test/directory')
    requests_post.assert_called_once_with(
        'secret/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA/filesys/?detail=low',
        headers={'Authorization': 'fmetoken token=secret'},
        data={'directoryname': 'test/directory', 'type': 'DIR'})
    fme_utils_log.debug.assert_called_once_with("Directory created")


def test_create_directory(requests_post, fme_utils_log):
    requests_post.return_value = create_autospec(requests.Response, status_code=201)
    fme_utils.create_directory('test/directory')
    requests_post.assert_called_once_with(
        'secret/fmerest/v2/resources/connections/FME_SHAREDRESOURCE_DATA/filesys/?detail=low',
        headers={'Authorization': 'fmetoken token=secret'},
        data={'directoryname': 'test/directory', 'type': 'DIR'})
    fme_utils_log.debug.assert_called_once_with("Directory created")


def test_create_repository(requests_post, fme_utils_log):
    requests_post.return_value = create_autospec(requests.Response, status_code=201)
    fme_utils.create_repository('test/repo')
    requests_post.assert_called_once_with(
        'secret/fmerest/v2/repositories/?detail=low',
        headers={'Authorization': 'fmetoken token=secret'},
        data={'name': 'test/repo'})
    fme_utils_log.debug.assert_called_once_with("Directory created")


def test_upload(requests_post, fme_utils_log):
    requests_post.return_value = create_autospec(requests.Response, status_code=201)
    fme_utils.upload('fixtures', 'resources/connections', 'RemoteData', '*.fmw', recreate_dir=False)
    fme_utils_log.debug.assert_called_once_with("Upload *.fmw completed")


def test_upload_repository(requests_post, fme_utils_log):
    requests_post.return_value = create_autospec(requests.Response, status_code=201)
    fme_utils.upload_repository('fixtures', 'repositories', 'test_repo.*', recreate_repo=False, register_fmejob=False)
    fme_utils_log.debug.assert_called_once_with("Upload test_repo.* completed")

# def test_run_transformation_job(requests_post, fme_utils_log):
#     requests_post.return_value = create_autospec(requests.Response, status_code=201)
#     fme_utils.run_transformation_job(
#         'BGT-SHAPES',
#         'aanmaak_esrishape_test_zip.fmw',
#         {
#             "subsection": "REST_SERVICE",
#             "FMEDirectives": {},
#             "NMDirectives": {"successTopics": [], "failureTopics": []},
#             "TMDirectives": {"tag": "linux", "description": "Aanmaak Shapes uit DB"},
#             "publishedParameters": [
#                 {"name": "SourceDataset_POSTGIS", "value": "bgt"},
#                 {"name": "SourceDataset_POSTGIS_3", "value": "bgt"},
#                 {"name": "DestDataset_ESRISHAPE2", "value": "$(FME_SHAREDRESOURCE_DATA)/TestExport.zip"},
#                 {"name": "DestDataset_ESRISHAPE3", "value":
#                     "$(FME_SHAREDRESOURCE_DATA)/TestExportTotaalgebied.zip"}]})
#     fme_utils_log.debug.assert_called_once_with("Upload test_repo.* completed")
