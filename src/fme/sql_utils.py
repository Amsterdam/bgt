import csv
import datetime
import glob
import io
import logging
import os
import subprocess
import sys

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
            if dbcur.rowcount > 0:
                return dbcur.fetchall()
            return []

        except psycopg2.DatabaseError as e:
            log.debug("Database script exception: procedures :%s" % str(e))
            raise (e)

    def run_sql_script(self, script_name) -> list:
        """
        Runs the sql script against the FME database
        :param script_name:
        :return:
        """
        return self.run_sql(open(script_name, 'r', encoding="utf-8").read())

    def import_csv_fixture(self, filename, table_name, truncate=True,
                           converthdrs=None, emptynone=True, srid=0, dialect=None) -> bool:
        """
        Imports a CSV file in file `filename` to table `table_name`.
        The first line is used to determine the column names and the
        types, to enable a correct import of the data

        :param filename: The CSV file to import, either the complete path or a
                            filelike object
        :param table_name: The table that gets populated
        :param truncate: If True the table is truncated before import
        :param converthdrs: dict which can convert a headername in csv to a field
                            name in sql
        :param emptynone: Convert empty fields to None
        :param srid: Coordinate system of postgis
        :param dialect: Force a specific csv dialect
        :return: bool
        """
        log.info("Import CSV {} to table {}".format(filename, table_name))

        try:
            self.conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
            dbcur = self.conn.cursor()
            rows = 0
            if truncate:
                dbcur.execute('TRUNCATE TABLE {};'.format(table_name))
            if isinstance(filename, str):  # complete path
                with open(filename) as csvfile:
                    rows = self.process_csvfile(csvfile, table_name, dbcur,
                                                converthdrs, emptynone, srid, dialect)
            else:  # file like object
                rows = self.process_csvfile(filename, table_name, dbcur,
                                            converthdrs, emptynone, srid, dialect)
        except psycopg2.DatabaseError as e:
            log.error("Import CSV exception :%s" % str(e))
            return False
        finally:
            log.info("Import CSV succeeded, {} rows imported to {}".format(rows, table_name))
        return True

    def process_csvfile(self, csvfile, table_name, dbcur,
                        converthdrs, emptynone=True, srid=None, dialect=None):
        """
        Process a single CSV file

        :param csvfile: csv file name
        :param table_name: mapped table in SQL
        :param dbcur: postgresql cursor
        :param converthdrs: dict of headers to be converted
        :param emptynone: Translate all empty fields to None values
        :param srid: coordinate system
        :return: number of rows
        """
        csv.field_size_limit(sys.maxsize)  # required for extremely large shapes (BGT_OTRN_erf.csv)
        rows = 0
        if dialect is None:
            data = csvfile.read(1024)
            try:
                dialect = csv.Sniffer().sniff(data)
            except csv.Error as e:
                log.info('CSV Dialect not found by sniffer, fallback to csvshapes dialect')
                csv.register_dialect('csvshapes', delimiter=';', doublequote=False, quoting=csv.QUOTE_NONE)
                dialect = 'csvshapes'

        csvfile.seek(0)
        reader = csv.reader(csvfile, dialect)

        names, dateconvert, geo_dict = self.process_hdr(next(reader), converthdrs, dbcur, table_name)
        # get the first line for the column names and format them for SQL

        for line in reader:
            # insert to db table
            values = self.process_values(line, emptynone, dateconvert, srid, geo_dict)
            placeholders = ['%s'] * len(values)
            for pos, value in [(idx, value) for idx, value in enumerate(values)
                               if isinstance(value, str) and 'ST_GeomFromText' in value]:
                placeholders[pos] = value
                del values[pos]
            sqlstmt = 'insert into {} {} values ({})'.format(
                table_name, names, ','.join(placeholders))
            dbcur.execute(sqlstmt, values)
            rows += 1
        return rows

    def process_values(self, line: list, emptynone: bool, dateconvert: list, srid: int, geo_dict: dict) -> list:
        """
        Process values in a single row in csv, modify them to allow for proper import

        :param line: list of csv values (unicode)
        :param emptynone: Translate empty to None
        :param dateconvert: List of indexnumbers with datefields
        :param srid: Coordinate system of geodata
        :param geo_dict: fields with geodata and type in database
        :return: list of converted values
        """
        newvalues = []
        for idx, value in enumerate(line):
            if value == '' and emptynone:
                newvalues.append(None)
            elif idx in dateconvert:  # datefield
                if len(value) > 12:  # datetime
                    newvalues.append(datetime.datetime(int(value[0:4]), int(value[4:6]),
                                                       int(value[6:8]), int(value[8:10]),
                                                       int(value[10:12]), int(value[12:])))
                else:  # date
                    newvalues.append(
                        datetime.datetime(int(value[0:4]), int(value[4:6]), int(value[6:8])))
            elif idx in geo_dict:  # Geometry fields
                if geo_dict[idx] == 'GEOMETRY':
                    newvalues.append("ST_GeomFromText('{}',{})".format(value, srid))
                elif geo_dict[idx] == 'COMPOUNDCURVE':
                    newvalues.append("ST_GeomFromText('{}({})',{})".format(geo_dict[idx], value, srid))
                else:
                    geometry_values = value[value.index('('):]
                    newvalues.append("ST_GeomFromText('{}{}',{})".format(geo_dict[idx], geometry_values, srid))
            else:
                try:
                    intvalue = int(value)
                    newvalues.append(intvalue)  # integer
                except ValueError:
                    try:
                        flvalue = float(value)  # floate
                        newvalues.append(flvalue)
                    except ValueError:
                        newvalues.append(value)  # string
        return newvalues

    def process_hdr(self, headers: list, converthdrs: dict, dbcur, table_name: str) -> (str, list, dict):
        """
        Convert headers in csv to fieldnames in sql including type information retrieved from
        the database

        :param headers: list of fieldnames in csv
        :param converthdrs: dictionary where fieldnames in cvs are mapped to fieldnames in sql
        :param dbcur: The psycopg2 cursor
        :param table_name: the tablename in sql
        :return:    string usable in insert with sql fieldnames
                    list with the columnnumbers with datefields
                    dict with the columnnumbers and types of the geodata in the sqltable
        """
        if not converthdrs:
            converthdrs = {}
        dfs = []
        columns, datefields, geometry_info = self.get_columninfo(dbcur, table_name)
        unmatched_columns = []
        geo_dict = {}
        error_matching = False
        new_hdr = []
        for idx, h in enumerate(headers):
            h = h.lower().replace('-', '_')  # convert to lowercase
            if h in columns:
                columns[h] = True
                new_hdr.append(h)
            else:
                if h in converthdrs:
                    new_hdr.append(converthdrs[h])
                    columns[converthdrs[h]] = True
                else:
                    unmatched_columns.append(h)
                    error_matching = True
            if len(new_hdr):
                last_column = new_hdr[-1]
                if last_column in datefields:
                    dfs.append(idx)
                if last_column in geometry_info:
                    geo_dict[idx] = geometry_info[last_column]

        if error_matching:
            raise Exception('no match database/csv for field(s) {} in '
                            'table {} skipped'.format(','.join(unmatched_columns), table_name))
        non_matched_fields = [column for column, matched in columns.items() if not matched]
        if len(non_matched_fields):
            log.error('fields %s in table %s not filled; processing continues',
                      ','.join(non_matched_fields), table_name)

        return '("' + '","'.join(new_hdr) + '")', dfs, geo_dict

    def get_columninfo(self, dbcur, table_name: str) -> (dict, list, dict):
        """
        Retrieves columninfo from the database to allow modifying the data properly

        :param dbcur: psycopg2 cursor
        :param table_name: sql tablename to be used
        :return:    dict of columns in table that are to be processed
                    list of columnnames that are datefields
                    dict of geo columnnames with geotype
        """
        dbcur.execute("""SELECT current_schema();""")
        schema = dbcur.fetchall()[0][0]
        column_info_query = \
            """SELECT column_name, data_type FROM information_schema.columns
                WHERE
                table_schema = '{}' AND
                table_name = '{}';""".format(schema, table_name)
        dbcur.execute(column_info_query)
        columninfo = dbcur.fetchall()
        datefields = [column_name for column_name, data_type in columninfo
                      if 'date' in data_type or 'timestamp' in data_type]
        columns = {column_name: False for column_name, data_type in columninfo}
        dbcur.execute("""SELECT f_geometry_column, type from geometry_columns WHERE f_table_name = '{}'
                        and f_table_schema = '{}';""".format(table_name, schema))
        geometry_columns = {column: geometrytype for column, geometrytype in dbcur.fetchall()}
        return columns, datefields, geometry_columns

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
