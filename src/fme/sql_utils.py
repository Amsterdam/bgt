import sys
import logging
import psycopg2
import psycopg2.extensions
from setup import FME_SERVER, FME_DBPASS

log = logging.getLogger(__name__)


def run_sql_script(script_name):
    """
    Runs the sql script against the FME database
    :param script_name:
    :return:
    """
    conn = psycopg2.connect(
        "host={} port={} dbname={} user={}  password={}".format(
            FME_SERVER.split('//')[-1], '5432', 'gisdb', 'dbuser', FME_DBPASS))
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    dbcur = conn.cursor()
    try:
        procedures = open(script_name, 'r').read()
        dbcur.execute(procedures)
        dbcur.execute('commit')
    except psycopg2.DatabaseError as e:
        log.debug("Database script exception: procedures :%s" % str(e))
        sys.exit(1)
