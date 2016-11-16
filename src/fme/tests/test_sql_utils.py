import logging

import pytest

from fme.sql_utils import SQLRunner

log = logging.getLogger(__name__)


@pytest.fixture
def sql_runner():
    runner = SQLRunner(port='5401', dbname='gisdb', user='dbuser')
    runner.run_sql("DROP TABLE IF EXISTS public.sql_utils;")
    return runner


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


def test_run_sql_script(sql_runner):
    res = sql_runner.run_sql_script('fme/tests/fixtures/test_pg.sql')
    assert len(res) == 0
    res = sql_runner.run_sql('SELECT * FROM public.sql_utils;')
    assert len(res) == 2


def test_failing_query(sql_runner):
    with pytest.raises(Exception) as e:
        res = sql_runner.run_sql("SELECT * FROM unknown_table")
        print(res)


def test_ogr2ogr_login(sql_runner):
    res = sql_runner.get_ogr2_ogr_login('public')
    assert res == "host=localhost port=5401 ACTIVE_SCHEMA=public user='dbuser' dbname='gisdb' password=insecure"
