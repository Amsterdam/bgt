import zipfile
import logging

import bgt_setup
from fme.sql_utils import SQLRunner
from io import StringIO, BytesIO
import csv

from objectstore.objectstore import ObjectStore

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

TOTALCSVNAME = 'shapes/csv-latest.zip'

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

RESULT_DATABASE_dbname = 'bgt'


class FinalDB:
    def __init__(self):

        """
        Create destination database for bgt
        """
        self.user = bgt_setup.DEBUG
        self.password = bgt_setup.BGT_DBPASS
        self.dbname = bgt_setup.BGT_DBNAME
        self.dbuser = bgt_setup.BGT_USER
        self.host = bgt_setup.BGT_HOST
        self.port = bgt_setup.BGT_PORT
        self.bgt_loc_pgsql = None


    def create_tables(self):
        """
        Create tables in the database including postgis extension

        :return: connection to database
        """
        bgt_loc_pgsql = SQLRunner(host=self.host, dbname=self.dbname, user=self.dbuser,
                         password=self.password, port=self.port)

        root = bgt_setup.SCRIPT_ROOT
        bgt_loc_pgsql.run_sql_script("{app}/bgt_source_sql/010_create_database.sql".format(app=root))

        return bgt_loc_pgsql

    def bld_sql_db(self, name=TOTALCSVNAME, procfile_name=None, location='os'):
        """
        Create bgt database and load all shapes into it

        :param name: Load a csv/zip
        :param procfile_name: Load this specific csv file
        :param location: Load file from this location (os = objectstore, fs=filesystem)
        :return: success
        """

        self.bgt_loc_pgsql = self.create_tables()

        inzip = self.get_zip(name, location)
        if procfile_name:
            self.process_file(procfile_name, inzip)
        else:
            processed_files = []
            for process_file_info in inzip.infolist():
                self.process_file(process_file_info, inzip)
                processed_files.append(process_file_info.filename)

        self.bgt_loc_pgsql.commit()
        self.bgt_loc_pgsql.close()

    def process_file(self, process_file_info, inzip):
        """
        Process a specific csv file to be imported into the database
        Note that the zipfile is used as StringIO!

        :param process_file_info: Processfile info as retrieved from zipfile for
                                  specific file
        :param inzip: ZipFile object
        :return:
        """
        table_name = self.map_csv_to_table(process_file_info.filename)
        if table_name:
            log.info("Table %s verwerking naar sql-tabel %s", process_file_info.filename, table_name)

            csv.register_dialect('csvshapes', delimiter=';', doublequote=False, quoting=csv.QUOTE_NONE)
            dialect = 'csvshapes'

            with StringIO(self.decodedata(inzip.read(process_file_info.filename))) as file_in_zip:
                self.bgt_loc_pgsql.import_csv_fixture(file_in_zip, table_name, truncate=False,
                                                  converthdrs=FIELDMAPPING,
                                                  srid=SRID, dialect=dialect)

    def decodedata(self, filebytes):
        """
        The csv can be in UTF-8 or LATIN- 1, 2, or 3 depending on the producing
        machine.

        :param filebytes:
        :return: decoded string
        """
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

    def get_zip(self, name, location):
        """
        Get zip from either local disk (for testing purposes) or from Objectstore

        :param name: Name of
        :return: ZipFile object
        """
        if location == 'os':
            store = ObjectStore('BGT')
            log.info("Download BGT source csv zip")
            content = BytesIO(store.get_store_object(name))
        else:
            content = name

        return zipfile.ZipFile(content)

    def map_csv_to_table(self, csvname:str) -> str:
        """
        Translate found tablename in csv to sqlname

        :param csvname:
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
                log.error('%s not found in mapping, file ignored', csvname)
        return mapped_name

if __name__ == '__main__':
    logging.basicConfig(level='DEBUG')
    logging.getLogger('requests').setLevel('WARNING')
    log.info("Starting create endproduct script")
    fdb = FinalDB()
    fdb.bld_sql_db()