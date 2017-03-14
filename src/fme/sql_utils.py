import csv
import glob
import logging
import os
import subprocess

import psycopg2
import psycopg2.extensions

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


class SQLRunner(object):
    def __init__(self, host='localhost', port='5432', dbname='postgres', user='dbuser', password='insecure'):
        self.host = host
        self.port = port
        self.dbname = dbname
        self.user = user
        self.password = password
        self.conn = psycopg2.connect("host={} port={} dbname={} user={}  password={}".format(
            host, port, dbname, user, password))

    def commit(self):
        self.conn.commit()

    def close(self):
        self.conn.close()

    def run_sql(self, script) -> list:
        """
        Runs the sql script against the FME database
        :param script:
        :return:
        """
        try:
            self.conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
            dbcur = self.conn.cursor()
            dbcur.execute(script)
            if dbcur.rowcount > 0 and dbcur.lastrowid >= 0:
                return dbcur.fetchall()
            return []

        except psycopg2.DatabaseError as e:
            log.debug("Database script exception: procedures :%s" % str(e))
            raise e

    def run_sql_script(self, script_name) -> list:
        """
        Runs the sql script against the FME database
        :param script_name:
        :return:
        """
        return self.run_sql(open(script_name, 'r', encoding="utf-8").read())

    def import_csv_fixture(self, filename, table_name, truncate=True) -> bool:
        """
        Imports a CSV file in file `filename` to table `table_name`.
        The first line is used to determine the column names.

        :param filename: The CSV file to import
        :param table_name: The table that gets populated
        :param truncate: If True the table is truncated before import
        :return: bool
        """
        log.info("Import CSV {} to table {}".format(filename, table_name))

        self.conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        dbcur = self.conn.cursor()
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
            return False
        finally:
            log.info("Import CSV succeeded, {} rows imported to {}".format(rows, table_name))
            return True

    def get_ogr2_ogr_login(self, schema):
        return "host={} port={} ACTIVE_SCHEMA={} user='dbuser' dbname='gisdb' password={}".format(
            self.host, self.port, schema, self.password)

    def import_gml_control_db(self):
        os.putenv('PGCLIENTENCODING', 'UTF8')

        for file in glob.glob('/tmp/data/*.gml'):
            log.info('Importing {}'.format(file))
            subprocess.call(
                'ogr2ogr -progress -skipfailures -overwrite -f "PostgreSQL" '
                'PG:"{PG}" -gt 655360 {LCO} {CONF} {FNAME}'.format(
                    PG=self.get_ogr2_ogr_login('imgeo_gml'),
                    LCO='-lco SPATIAL_INDEX=OFF',
                    CONF='--config PG_USE_COPY YES',
                    FNAME=file), shell=True)
