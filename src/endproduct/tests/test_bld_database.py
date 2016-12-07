import logging

import bgt_setup
from endproduct.bld_database import FinalDB, TABLEMAPPING

log = logging.getLogger(__name__)


def test_get_zip():
    fdb = FinalDB()
    inzip = fdb.get_zip('{app}/endproduct/tests/fixtures/bgt_test.zip'.format(app=bgt_setup.SCRIPT_SRC), 'fs')
    for process_file_info in inzip.infolist():
        print(process_file_info.filename)
        assert (process_file_info.filename in ('test1.csv', 'test2.csv'))


def test_tabellen():
    fdb = FinalDB()
    loc_bgt_db = fdb.create_tables()

    for tablename in TABLEMAPPING.values():
        exists = loc_bgt_db.run_sql("SELECT exists(SELECT 1 from pg_catalog.pg_class c"
                                    " join pg_catalog.pg_namespace n ON n.oid = c.relnamespace"
                                    " where n.nspname = 'bgt'"
                                    " AND c.relname = '%s')" % tablename)[0][0]

        if not exists:
            print("table %s does not exist" % tablename)
        assert (exists)


def test_load_csv():
    fdb = FinalDB()
    inzip = '{app}/endproduct/tests/fixtures/csv_totaal.zip'.format(app=bgt_setup.SCRIPT_SRC)
    fdb.bld_sql_db(name=inzip, location='fs')
