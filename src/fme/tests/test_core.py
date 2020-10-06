import fme.polygon as polygon

from unittest import TestCase
from unittest.mock import patch, call, MagicMock

from fme.core import get_gob_over_onderbouw_files, upload_over_onderbouw_backup, get_pdok_feature_types, pdok_url
from bgt_setup import GOB_OBJECTSTORE_CONTAINER, PDOK_DOWNLOAD_API, PDOK_DOWNLOAD_API_HOST


class TestOverOnderbouwFromGOB(TestCase):

    @patch("fme.core.ObjectStore")
    @patch("fme.core.os")
    @patch("builtins.open")
    def test_get_over_onderbouw_files(self, mock_open, mock_os, mock_objectstore):
        mock_objectstore.return_value.get_store_object = lambda x: 'stored_' + x

        result = get_gob_over_onderbouw_files()

        mock_objectstore.assert_called_with('GOB', GOB_OBJECTSTORE_CONTAINER)
        mock_open.return_value.__enter__.return_value.write.assert_has_calls([
            call('stored_bgt/CSV_Actueel/CFT_onderbouw.csv'),
            call('stored_bgt/CSV_Actueel/CFT_overbouw.csv'),
        ])
        self.assertEqual([
            ('/tmp/data/CFT_onderbouw.csv', 'CFT_Onderbouw'),
            ('/tmp/data/CFT_overbouw.csv', 'CFT_Overbouw'),
        ], result)

    @patch("fme.core.get_gob_over_onderbouw_files")
    @patch("fme.core.create_fme_sql_connection")
    @patch("fme.core.csv.reader")
    @patch("builtins.open")
    def test_upload_over_onderbouw_backup(self, mock_open, mock_reader, mock_fme_connection, mock_get_files):

        mock_get_files.return_value = [
            ('file/location/a.csv', 'ObjectTypeA'),
            ('file/location/b.csv', 'ObjectTypeB')
        ]

        mock_reader.side_effect = iter([
            iter([
                ('guid', 'begin_geldigheid', 'eind_geldigheid', 'relatievehoogteligging', 'geometrie'),
                ('guid1', '', '', '1', 'geometrie1'),
                ('guid2', '', '', '-2', 'geometrie1'),
            ]),
            iter([
                ('guid', 'begin_geldigheid', 'eind_geldigheid', 'relatievehoogteligging', 'geometrie'),
                ('guid1', '', '', '3', 'geometrie1'),
                ('guid2', '', '', '-5', 'geometrie1'),
            ])
        ])

        upload_over_onderbouw_backup()

        mock_fme_connection.return_value.run_sql.assert_has_calls([
            call(
                "INSERT INTO imgeo.\"ObjectTypeA\" (guid, relatievehoogteligging, bestandsnaam, geometrie) "
                "VALUES ('guid1', 1, 'ObjectTypeA', ST_GeomFromText('geometrie1', 28992));"),
            call(
                "INSERT INTO imgeo.\"ObjectTypeA\" (guid, relatievehoogteligging, bestandsnaam, geometrie) "
                "VALUES ('guid2', -2, 'ObjectTypeA', ST_GeomFromText('geometrie1', 28992));"),
            call(
                "INSERT INTO imgeo.\"ObjectTypeB\" (guid, relatievehoogteligging, bestandsnaam, geometrie) "
                "VALUES ('guid1', 3, 'ObjectTypeB', ST_GeomFromText('geometrie1', 28992));"),
            call(
                "INSERT INTO imgeo.\"ObjectTypeB\" (guid, relatievehoogteligging, bestandsnaam, geometrie) "
                "VALUES ('guid2', -5, 'ObjectTypeB', ST_GeomFromText('geometrie1', 28992));"),
        ])

    @patch("fme.core.requests")
    def test_get_pdok_feature_types(self, mock_requests):
        mock_requests.get.return_value.json.return_value = {
            'timeliness': [
                {'featuretype': 'feature type a'},
                {'featuretype': 'feature type b'},
            ],
        }

        self.assertEqual(['feature type a', 'feature type b'], get_pdok_feature_types())
        mock_requests.get().raise_for_status.assert_called_once()

    @patch("fme.core.time.sleep")
    @patch("fme.core.get_pdok_feature_types")
    @patch("fme.core.requests")
    def test_pdok_url(self, mock_requests, mock_get_feature_types, mock_sleep):
        mock_get_feature_types.return_value = ['feature a', 'feature b', 'plaatsbepalingspunt', 'feature d']

        mock_requests.post.return_value.json.return_value = {
            'downloadRequestId': 'the download request id',
        }

        in_progress_response = MagicMock()
        in_progress_response.status_code = 200
        in_progress_response.json.return_value = {'progress': 48}

        in_progress_response2 = MagicMock()
        in_progress_response2.status_code = 200
        in_progress_response2.json.return_value = {'progress': 76}

        complete_response = MagicMock()
        complete_response.status_code = 201
        complete_response.json.return_value = {'_links': {'download': {'href': '/the/download/url'}}}

        mock_requests.get.side_effect = [in_progress_response, in_progress_response2, complete_response]

        res = pdok_url()
        mock_requests.post.assert_called_with(f"{PDOK_DOWNLOAD_API}/full/custom", json={
            'featuretypes': ['feature a', 'feature b', 'feature d'],
            'format': 'citygml',
            'geofilter': polygon.full,
        })

        mock_requests.get.assert_called_with(f"{PDOK_DOWNLOAD_API}/full/custom/the download request id/status")
        self.assertEqual(3, mock_requests.get.call_count)
        self.assertEqual(f"{PDOK_DOWNLOAD_API_HOST}/the/download/url", res)
