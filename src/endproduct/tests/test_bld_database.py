import pytest
import logging
from unittest.mock import MagicMock, patch

import bgt_setup
from endproduct.bld_database import final_db, TABLEMAPPING

log = logging.getLogger(__name__)
# @pytest.fixture
# def sql_server():
#     s = FMEServer(
#         'http://localhost',
#         '2222',
#         '95b4bd5265c03482n2cb481bf37f29e7a545ab88')
#     s.get_status = MagicMock(return_value='RUNNING')
#     return s


def test_get_zip():
    fdb = final_db(keep_db=False)
    root = bgt_setup.SCRIPT_SRC
    inzip = fdb.get_zip('{app}/endproduct/tests/fixtures/bgt_test.zip'.format(app=bgt_setup.SCRIPT_SRC))
    for process_file_info in inzip.infolist():
        print(process_file_info.filename)
        assert(process_file_info.filename in ('test1.csv', 'test2.csv'))

def test_create_database():
    fdb = final_db()
    loc_bgt_db = fdb.create_database()
    exists = loc_bgt_db.run_sql("SELECT exists(SELECT 1 from "
                                    "pg_catalog.pg_database where datname = "
                                    "'bgt')")[0][0]
    assert(exists)
    loc_bgt_db.commit()
    loc_bgt_db.close()

    fdb = final_db(keep_db=False)
    loc_bgt_db = fdb.create_database()
    exists = loc_bgt_db.run_sql("SELECT exists(SELECT 1 from "
                                    "pg_catalog.pg_database where datname = "
                                    "'bgt')")[0][0]
    assert(exists)
    loc_bgt_db.commit()
    loc_bgt_db.close()

    fdb = final_db(keep_db=True)
    loc_bgt_db = fdb.create_database()
    exists = loc_bgt_db.run_sql("SELECT exists(SELECT 1 from "
                                    "pg_catalog.pg_database where datname = "
                                    "'bgt')")[0][0]
    assert(exists)
    loc_bgt_db.commit()
    loc_bgt_db.close()

def test_tabellen():
    fdb = final_db(keep_db=True)
    loc_bgt_db = fdb.create_database()

    for tablename in TABLEMAPPING.values():
        exists = loc_bgt_db.run_sql("SELECT exists(SELECT 1 from pg_catalog.pg_class c"
                                    " join pg_catalog.pg_namespace n ON n.oid = c.relnamespace"
                                    " where n.nspname = 'imgeo'"
                                    " AND c.relname = '%s')" % tablename)[0][0]

        if not exists:
            print("table %s does not exist" % tablename)
        assert(exists)

def test_load_csv():
    fdb = final_db()
    inzip = '/home/dick/Downloads/csv_totaal.zip'
    # inzip = '{app}/endproduct/tests/fixtures/cvs_totaal.zip'.format(app=bgt_setup.SCRIPT_SRC)
    fdb.bld_sql_db(name=inzip, procfile_name='BGT_SPR_trein.csv')
    #
    # fdb.bld_sql_db(name=inzip)

    # inzip = '/home/dick/Downloads/csv_totaal.zip'
    # fdb.bld_sql_db(name=inzip)
#
test_load_csv()