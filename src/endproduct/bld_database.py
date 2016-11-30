import zipfile
import logging

import bgt_setup
from fme.sql_utils import SQLRunner
from io import StringIO

from objectstore.objectstore import ObjectStore

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

TOTALCSVNAME = 'csv_totaal.zip'

NAMEMAPPING = {'BGT_LBL_terrein.csv': 'bgt_openbareruimtelabel',
               'BGT_LBL_water.csv': 'bgt_openbareruimtelabel',
               'BGT_LBL_weg.csv': 'bgt_openbareruimtelabel',
               'BGT_LBL_kunstwerk.csv': 'bgt_openbareruimtelabel',
               'BGT_LBL_landschappelijk_gebied.csv': 'bgt_openbareruimtelabel',}

TABLEMAPPING = {'BGTPLUS_BAK': 'imgeo_bak',
                'BGTPLUS_FGD': 'imgeo_functioneelgebied',
                'BGTPLUS_GISE': 'imgeo_gebouwinstallatie',
                'BGTPLUS_ISE': 'imgeo_installatie',
                'BGTPLUS_KDL': 'imgeo_kunstwerkdeel',
                'BGTPLUS_KST': 'imgeo_kast',
                'BGTPLUS_OBW': 'imgeo_overigbouwwerk',
                'BGTPLUS_OSDG': 'imgeo_overigescheiding',
                'BGTPLUS_PAL': 'imgeo_paal',
                'BGTPLUS_PUT': 'imgeo_put',
                'BGTPLUS_SDG': 'imgeo_scheiding',
                'BGTPLUS_SMR': 'imgeo_straatmeubilair',
                'BGTPLUS_VGT': 'imgeo_vegetatieobject',
                'BGTPLUS_WDI': 'imgeo_waterinrichtingselement',
                'BGTPLUS_WGI': 'imgeo_weginrichtingselement',
                'BGTPLUS_LBL': 'bgt_openbareruimtelabel',
                'BGTPLUS_BRD': 'imgeo_bord',
                'BGTPLUS_MST': 'imgeo_mast',
                'BGTPLUS_SSR': 'imgeo_sensor',
                'BGTPLUS_SPR': 'imgeo_spoor',
                'BGT_BTRN': 'bgt_begroeidterreindeel',
                'BGT_KDL': 'imgeo_kunstwerkdeel',
                'BGT_LBL': 'bgt_nummeraanduidingreeks',
                'BGT_OBW': 'imgeo_overigbouwwerk',
                'BGT_ODL': 'bgt_overbruggingsdeel',
                'BGT_OOT': 'bgt_ongeclassificeerdobject',
                'BGT_OTRN': 'bgt_onbegroeidterreindeel',
                'BGT_OWDL': 'bgt_ondersteunendwaterdeel',
                'BGT_OWGL': 'bgt_ondersteunendwegdeel',
                'BGT_PND': 'bgt_pand',
                'BGT_SDG': 'imgeo_scheiding',
                'BGT_SPR': 'imgeo_spoor',
                'BGT_TDL': 'bgt_tunneldeel',
                'BGT_TNL': 'bgt_tunneldeel',
                'BGT_WDL': 'bgt_waterdeel',
                'BGT_WGL': 'bgt_wegdeel',
                }

FIELDMAPPING =    { 'geometry':'geometrie',
                    'hoek':'opr_label_hoek',
                    'label_tekst': 'opr_label_tekst'
                    }

SRID=28992

RESULT_DATABASE_PORT = 5432
RESULT_DATABASE_HOST = 'localhost'
RESULT_DATABASE_dbname = 'bgt'
RESULT_DATABASE_user = 'dbuser'
RESULT_DATABASE_pw = 'insecure'
HOST_DB_pw = '35whiskey'
HOST_DB_postgres = 'postgres'
HOST_DB_user = 'postgres'


class final_db:
    def __init__(self,  port=RESULT_DATABASE_PORT,
                        host=RESULT_DATABASE_HOST,
                        dbname=RESULT_DATABASE_dbname,
                        user = RESULT_DATABASE_user,
                        password=RESULT_DATABASE_pw,
                        keep_db=False):

        """
        Create destination database for bgt
        """
        self.keep_db = keep_db
        self.dbname = dbname
        self.port = port
        self.host = host
        self.password = password
        self.user = user
        self.bgt_loc_pgsql = None

    def connect_to_postgresdb(self):
        return SQLRunner(port=self.port, host=self.host,
                                dbname=HOST_DB_postgres, user=HOST_DB_user, password=HOST_DB_pw)

    def connect_to_bgtdb(self):
        return SQLRunner(port=self.port, host=self.host,
                                dbname=self.dbname, user=self.user, password=self.password)

    def create_database(self, cleardb=False):
        pub_loc_pgsql = self.connect_to_postgresdb()
        exists = pub_loc_pgsql.run_sql("SELECT exists(SELECT 1 from "
                                        "pg_catalog.pg_database where datname = "
                                        "'{dbname}')".format(dbname=self.dbname))[0][0]
        if exists:
            if not self.keep_db:
                pub_loc_pgsql.run_sql('DROP DATABASE {dbname}'.format(dbname=self.dbname))
                exists = False
        if not exists:
            pub_loc_pgsql.run_sql('CREATE DATABASE {dbname}'.format(dbname=self.dbname))

        pub_loc_pgsql.commit()
        pub_loc_pgsql.close()

        bgt_loc_pgsql = self.create_tables(exists)

        if exists and cleardb:
            for tablename in TABLEMAPPING.values():
                bgt_loc_pgsql.run_sql("TRUNCATE  TABLE {};".format(tablename))
        return bgt_loc_pgsql


    def create_tables(self, exists):
        # Connect to the newly created database
        bgt_loc_pgsql = self.connect_to_bgtdb()

        if not exists:
            try:
                bgt_loc_pgsql.run_sql('CREATE EXTENSION postgis')
            except Exception as e:
                pass
            root = bgt_setup.SCRIPT_ROOT
            bgt_loc_pgsql.run_sql_script("{app}/source_sql/010_create_database.sql".format(app=root))

        return bgt_loc_pgsql

    def bld_sql_db(self, name=None, procfile_name=None, clear_db=False):
        """
        Create bgt database and load all shapes into it

        :param name: Load a csv/zip
        :param procfile_name: Load this specific csv file
        :param clear_db: Switch to clear the tables before load
        :return: success
        """

        self.bgt_loc_pgsql = self.create_database(clear_db)

        inzip = self.get_zip(name)
        for process_file_info in inzip.infolist():
            if procfile_name:
                if process_file_info.filename == procfile_name:
                    self.process_file(process_file_info, inzip)
                    break
            else:
                self.process_file(process_file_info, inzip)

        self.bgt_loc_pgsql.commit()
        self.bgt_loc_pgsql.close()

    def process_file(self, process_file_info, inzip, ignore_not_found=True):
        """

        :param loc_pgsql: Postgresql connection
        :param process_file_info: Processfile info as retrieved from zipfile for
                                  specific file
        :param inzip: ZipFile object
        :return:
        """
        table_name = self.map_csv_to_table(process_file_info.filename, ignore_not_found)
        if table_name:
            log.info("Table %s verwerking naar sql-tabel %s", process_file_info.filename, table_name)

            with StringIO(self.decodedata(inzip.read(process_file_info.filename))) as file_in_zip:
                try:
                    self.bgt_loc_pgsql.import_csv_fixture(file_in_zip, table_name, truncate=False,
                                                  converthdrs=FIELDMAPPING,
                                                  srid=SRID)
                except Exception as e:
                    log.error('\n' + str(e) + '\n')

    def decodedata(self, filebytes):
        encodings = ('UTF-8', 'LATIN-1', 'LATIN-2', 'LATIN-3')
        stringdata = None
        for encode in encodings:
            try:
                stringdata = filebytes.decode(encode)
                break
            except UnicodeDecodeError:
                pass
        if not stringdata:
            raise UnicodeDecodeError
        return stringdata

    def get_zip(self, name=None):
        """
        Get zip from either local disk (for testing purposes) or from Objectstore

        :param name: Name of
        :return: ZipFile object
        """
        if not name:
            name = TOTALCSVNAME

        if not name[0] == '/':
            store = ObjectStore('BGT')
            log.info("Download BGT source csv zip")
            name = store.get_store_object(name)

        return zipfile.ZipFile(name)

    def map_csv_to_table(self, csvname:str, ignore_not_found:bool) -> str:
        """
        Translate found tablename in csv to sqlname

        :param csvname:
        :param ignore_not_found:
        :return: mapped_name is name to be used in SQL database
        """
        mapped_name = None
        if csvname in NAMEMAPPING:
            mapped_name = NAMEMAPPING[csvname]
        else:
            cs = csvname.split('_')
            cnsplit = '_'.join(cs[0:2])
            try:
                mapped_name = TABLEMAPPING[cnsplit]
            except KeyError:
                if not ignore_not_found:
                    mapped_name = csvname
        return mapped_name

