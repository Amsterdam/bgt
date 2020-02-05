from unittest import TestCase
from unittest.mock import patch, call

from fme.core import get_gob_over_onderbouw_files, upload_over_onderbouw_backup
from bgt_setup import GOB_OBJECTSTORE_BASE


class TestOverOnderbouwFromGOB(TestCase):

    @patch("fme.core.ObjectStore")
    @patch("fme.core.os")
    @patch("builtins.open")
    def test_get_over_onderbouw_files(self, mock_open, mock_os, mock_objectstore):
        mock_objectstore.return_value.get_store_object = lambda x: 'stored_' + x

        result = get_gob_over_onderbouw_files()

        mock_objectstore.assert_called_with('GOB', GOB_OBJECTSTORE_BASE)
        mock_open.return_value.__enter__.return_value.write.assert_has_calls([
            call('stored_bgt/CSV_Actueel/CFT_onderbouw.csv'),
            call('stored_bgt/CSV_Actueel/CFT_overbouw.csv'),
        ])

        self.assertEquals({
            '/tmp/data/CFT_onderbouw.csv': 'CFT_Onderbouw',
            '/tmp/data/CFT_overbouw.csv': 'CFT_Overbouw',
        }, result)

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
