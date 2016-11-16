import os
import sys
import io
import csv
import glob
import subprocess
import logging
import psycopg2
import psycopg2.extensions

from bgt_setup import FME_SERVER, FME_DBPASS

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


_fme_connect = "host={} port={} dbname={} user={}  password={}".format(FME_SERVER.split('//')[-1],
                                                                       '5432', 'gisdb', 'dbuser', FME_DBPASS)
_local_connect = "host={} port={} dbname={} user={}  password={}".format('localhost',
                                                                         '5401', 'gisdb', 'dbuser', 'insecure')

def run_sql(script, tx=False):
    """
    Runs the sql script against the FME database
    :param script:
    :return:
    """
    conn = psycopg2.connect(
        "host={} port={} dbname={} user={}  password={}".format(
            FME_SERVER.split('//')[-1], '5432', 'gisdb', 'dbuser', FME_DBPASS))
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    dbcur = conn.cursor()
    try:
        dbcur.execute(script)
        if tx:
            dbcur.execute('commit')
    except psycopg2.DatabaseError as e:
        log.debug("Database script exception: procedures :%s" % str(e))
        sys.exit(1)


def run_sql_script(script_name, tx=False):
    """
    Runs the sql script against the FME database
    :param script_name:
    :return:
    """
    return run_sql(open(script_name, 'r').read(), tx)


def run_local_sql_script(script_name, tx=False):
    """
    Runs the sql script against the FME database
    :param script_name:
    :return:
    """
    return run_local_sql(open(script_name, 'r').read(), tx)


def run_local_sql(script, tx=False):
    conn = psycopg2.connect(
        "host={} port={} dbname={} user={}  password={}".format(
            'localhost', '5401', 'gisdb', 'dbuser', 'insecure'))
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    dbcur = conn.cursor()
    try:
        dbcur.execute(script)
        records = []
        if dbcur.rowcount > 0:
            records = dbcur.fetchall()
        if tx:
            dbcur.execute('commit')
        return records
    except psycopg2.DatabaseError as e:
        log.exception("Database script exception: procedures :%s" % str(e))
        return []


def import_csv_fixture(filename, table_name, host, port=5432, password='insecure', truncate=True):
    """
    Imports a CSV file in file `filename` to table `tablename`. The first line is used to determine the column names.
    dbname = 'gisdb' and user - 'dbuser'

    :param filename: The CSV file to import
    :param table_name: The table that gets populated
    :param host: The DB hostname
    :param port: The DB port
    :param password: The password for the database
    :param truncate: If True the table is truncated before import
    :return:
    """
    log.info("Import CSV {} to table {}".format(filename, table_name))

    conn = psycopg2.connect(
        "host={} port={} dbname={} user={}  password={}".format(
            host, port, 'gisdb', 'dbuser', password))
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    dbcur = conn.cursor()
    rows = 0
    try:
        if truncate:
            dbcur.execute('TRUNCATE TABLE {};'.format(table_name))
        with open(filename) as csvfile:
            dialect = csv.Sniffer().sniff(csvfile.read(1024))
            csvfile.seek(0)
            reader = csv.reader(csvfile, dialect)

            # get the first line for the column names and format them for SQL
            names = '({})'.format(','.join(next(reader)))
            for line in reader:
                # insert to db table
                dbcur.execute('insert into {} {} values ({})'.format(
                    table_name, names, ','.join("'{}'".format(f) for f in line)))
                rows += 1
    except psycopg2.DatabaseError as e:
        log.debug("Import CSV exception :%s" % str(e))
        sys.exit(1)
    finally:
        log.info("Import CSV succeeded, {} rows imported to {}".format(rows, table_name))


def import_gml_control_db(host, port=5432, password='insecure'):
    os.putenv('PGCLIENTENCODING', 'UTF8')
    postgres_conn = "host={} port={} ACTIVE_SCHEMA=imgeo_gml user='dbuser' dbname='gisdb' password={}".format(
        host,
        port,
        password)
    for file in glob.glob('/tmp/data/*.gml'):
        log.info('Importing {}'.format(file))
        subprocess.call(
            'ogr2ogr -progress -skipfailures -overwrite -f "PostgreSQL" '
            'PG:"{PG}" -gt 655360 {LCO} {CONF} {FNAME}'.format(
                PG=postgres_conn,
                LCO='-lco SPATIAL_INDEX=OFF',
                CONF='--config PG_USE_COPY YES',
                FNAME=file), shell=True)


def p_import_gml_control_db(host, port=5432, password='insecure'):
    ON_POSIX = 'posix' in sys.builtin_module_names
    os.putenv('PGCLIENTENCODING', 'UTF8')
    postgres_conn = "host={} port={} ACTIVE_SCHEMA=imgeo_gml user='dbuser' dbname='gisdb' password={}".format(
        host,
        port,
        password)

    # create a pipe to get data
    input_fd, output_fd = os.pipe()
    # start several subprocesses
    processes = [subprocess.Popen(
        ['ogr2ogr', '-skipfailures', '-overwrite', '-f', 'PostgreSQL',
         'PG:{PG}'.format(PG=postgres_conn), '-gt', '655360', '-lco', 'SPATIAL_INDEX=OFF', '--config',
         'PG_USE_COPY', 'YES', '{FNAME}'.format(FNAME=fname)],
        stdout=output_fd, close_fds=ON_POSIX) for fname in glob.glob('/tmp/data/*.gml')]
    os.close(output_fd)  # close unused end of the pipe

    # read output line by line as soon as it is available
    with io.open(input_fd, 'r', buffering=1) as file:
        for line in file:
            print(line, end='')
    for p in processes:
        p.wait()
