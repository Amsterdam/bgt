import logging

import pytest

import bgt_setup
from fme.sql_utils import SQLRunner

log = logging.getLogger(__name__)


@pytest.fixture
def sql_runner():
    # 5401 / localhost
    runner = SQLRunner(
        host=bgt_setup.DB_FME_HOST, port=bgt_setup.DB_FME_PORT,
        dbname=bgt_setup.DB_FME_DBNAME, user=bgt_setup.DB_FME_USER)
    runner.run_sql("DROP TABLE IF EXISTS public.sql_utils;")
    return runner

@pytest.mark.skip(reason='integration test')
def test_sql_runner_run_sql(sql_runner):
    dml_tekst = "CREATE TABLE public.sql_utils(field1 CHARACTER VARYING(8), field2 CHARACTER VARYING(38), field3 DATE);"
    sql_runner.run_sql(dml_tekst)

    res = sql_runner.run_sql('SELECT * FROM public.sql_utils')
    assert len(res) == 0

    res = sql_runner.run_sql(
        "INSERT INTO public.sql_utils (field1, field2, field3)"
        "VALUES  ('1', '2', '2016-01-01'), ('4', '5', '2016-01-01');COMMIT;")
    res = sql_runner.run_sql('SELECT * FROM public.sql_utils;')
    assert len(res) == 2


@pytest.mark.skip(reason='integration test')
def test_run_sql_script(sql_runner):
    res = sql_runner.run_sql_script('{app}/fme/tests/fixtures/test_pg.sql'.format(app=bgt_setup.SCRIPT_SRC))
    assert len(res) == 0
    res = sql_runner.run_sql('SELECT * FROM public.sql_utils;')
    assert len(res) == 2


@pytest.mark.skip(reason='integration test')
def test_failing_query(sql_runner):
    with pytest.raises(Exception) as e:
        res = sql_runner.run_sql("SELECT * FROM unknown_table")
        print(res)


@pytest.mark.skip(reason='tests for test environment')
def test_ogr2ogr_login(sql_runner):
    res = sql_runner.get_ogr2_ogr_login('public')
    assert res == "host=database port=5432 ACTIVE_SCHEMA=public user='dbuser' dbname='gisdb' password=insecure"
