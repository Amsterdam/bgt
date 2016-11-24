import zipfile
import logging
from fme.sql_utils import SQLRunner

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

TOTALCSVNAME = 'csv_totaal.zip'
TABLEMAPPING = {''}

from objectstore.objectstore import ObjectStore



def bld_sql_db(loc_pgsql, table_name, name=None, procfile_name=None):

    inzip = get_name(name)
    for process_file_info in inzip.infolist():
        if procfile_name and process_file_info.filename == procfile_name:
            process_file(loc_pgsql, process_file_info, inzip)
            break
        else:
            process_file(process_file_info, inzip)

def process_file(loc_pgsql, process_file_info, inzip):
    try:
        table_name = TABLEMAPPING[process_file_info.filename]
    except KeyError:
        table_name = process_file_info.filename

    with inzip.open(process_file_info) as file_in_zip:
        loc_pgsql.import_csv_fixture(file_in_zip, table_name, truncate=True)

def get_name(name):
    if not name:
        name = TOTALCSVNAME

    if not name[0] == '/':
        store = ObjectStore('BGT')
        log.info("Download BGT source csv zip")
        name = store.get_store_object(name)

    return zipfile.ZipFile(name)



