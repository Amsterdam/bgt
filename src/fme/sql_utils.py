import csv
import glob
import io
import logging
import os
import subprocess
import sys
import json

import psycopg2
import psycopg2.extensions

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


class SQLRunner(object):
    def __init__(self, host='localhost', port='5432', dbname='postgresql', user='dbuser', password='insecure'):
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
        self.conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        dbcur = self.conn.cursor()
        try:
            dbcur.execute(script)
            if dbcur.rowcount > 0:
                return dbcur.fetchall()
            return []

        except psycopg2.DatabaseError as e:
            log.debug("Database script exception: procedures :%s" % str(e))
            raise Exception(e)

    def run_sql_script(self, script_name) -> list:
        """
        Runs the sql script against the FME database
        :param script_name:
        :return:
        """
        return self.run_sql(open(script_name, 'r').read())

    def import_csv_fixture(self, filename, table_name, truncate=True,
                           converthdrs={}, emptynone=True, datefields=(), srid=0) -> bool:
        """
        Imports a CSV file in file `filename` to table `table_name`.
        The first line is used to determine the column names.

        :param filename: The CSV file to import, either the complete path or a
                            filelike object
        :param table_name: The table that gets populated
        :param truncate: If True the table is truncated before import
        :return: bool
        """
        log.info("Import CSV {} to table {}".format(filename, table_name))

        self.conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        dbcur = self.conn.cursor()
        rows = 0
        # try:
        if truncate:
            dbcur.execute('TRUNCATE TABLE {};'.format(table_name))
        if isinstance(filename, str):       # complete path
            with open(filename) as csvfile:
                rows = self.process_csvfile(csvfile, table_name, dbcur,
                                            converthdrs, emptynone, datefields, srid)
        else:                               # file like object
            rows = self.process_csvfile(filename, table_name, dbcur,
                                        converthdrs, emptynone, datefields, srid)
        # except psycopg2.DatabaseError as e:
        #     log.debug("Import CSV exception :%s" % str(e))
        #     return False
        # finally:
        #     log.info("Import CSV succeeded, {} rows imported to {}".format(rows, table_name))
        return True

    def process_csvfile(self, csvfile, table_name, dbcur,
                        converthdrs={}, emptynone=True, datefields=(), srid=None):
        rows = 0
        data = csvfile.read(1024)
        try:
            dialect = csv.Sniffer().sniff(data)
        except csv.Error as e:
            csv.register_dialect('csvshapes', delimiter=';', doublequote=False, quoting=csv.QUOTE_NONE)
            dialect = 'csvshapes'

        csvfile.seek(0)
        reader = csv.reader(csvfile, dialect)

        names, dateconvert = self.process_hdr(next(reader), converthdrs, datefields)
        # get the first line for the column names and format them for SQL

        for line in reader:
            # insert to db table
            values = self.process_values(line, emptynone, dateconvert, srid)
            sqlstmt = 'insert into {} {} values ({})'.format(
                table_name, names, values)
            dbcur.execute(sqlstmt)
            rows += 1
        return rows

    def process_values(self, line:list, emptynone:bool, dateconvert:list, srid:int) -> str:
        newvalues = []
        for idx, value in enumerate(line):
            if value == '' and emptynone:
                newvalues.append('NULL')
            elif idx in dateconvert and len(value) > 8:
                newvalues.append("'{} {}:{}:{}'".format(value[0:8], value[8:10], value[10:12], value[12:]))
            elif srid and 'MULTIPOLYGON' in value:
                newvalues.append(value.replace("MULTIPOLYGON", "ST_GeomFromText('MULTISURFACE") + "',{})".format(srid))
            elif srid and 'POLYGON' in value:
                newvalues.append(value.replace("POLYGON", "ST_GeomFromText('CURVEPOLYGON") + "',{})".format(srid))
            elif srid and 'MULTIPOINT' in value:
                newvalues.append(value.replace("MULTIPOINT", "ST_GeomFromText('MULTIPOINT") + "',{})".format(srid))
            elif srid and 'POINT' in value:
                newvalues.append(value.replace("POINT", "ST_GeomFromText('POINT") + "',{})".format(srid))
            elif srid and 'LINESTRING' in value:
                newvalues.append(value.replace("LINESTRING", "ST_GeomFromText('LINESTRING") + "',{})".format(srid))
            else:
                newvalues.append("'{}'".format(value))
        return ','.join(newvalues)

    def convert_2_json(self, value):
        value.split()

    def process_hdr(self, headers:list, converthdrs:dict, datefields:tuple) -> (str, list):
        dfs = []
        new_hdr = []
        for idx, h in enumerate(headers):
            if h in converthdrs:
                new_hdr.append(converthdrs[h])
            else:
                new_hdr.append(h.replace('-','_'))
            if new_hdr[-1] in datefields:
                dfs.append(idx)

        return '("' + '","'.join(new_hdr) + '")', dfs

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

    def p_import_gml_control_db(self):
        ON_POSIX = 'posix' in sys.builtin_module_names
        os.putenv('PGCLIENTENCODING', 'UTF8')

        # create a pipe to get data
        input_fd, output_fd = os.pipe()
        # start several subprocesses
        processes = [subprocess.Popen(
            ['ogr2ogr', '-skipfailures', '-overwrite', '-f', 'PostgreSQL',
             'PG:{PG}'.format(PG=self.get_ogr2_ogr_login('imgeo_gml')),
             '-gt', '655360', '-lco', 'SPATIAL_INDEX=OFF', '--config',
             'PG_USE_COPY', 'YES', '{FNAME}'.format(FNAME=fname)],
            stdout=output_fd, close_fds=ON_POSIX) for fname in glob.glob('/tmp/data/*.gml')]
        os.close(output_fd)  # close unused end of the pipe

        # read output line by line as soon as it is available
        with io.open(input_fd, 'r', buffering=1) as file:
            for line in file:
                print(line, end='')
        for p in processes:
            p.wait()
