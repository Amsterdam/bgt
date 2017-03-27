import csv
import logging
import os
from datetime import datetime
from subprocess import Popen, PIPE, STDOUT

import psycopg2

import bgt_setup
import fme.sql_utils as fme_sql_utils

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)


def create_work_dir():
    workdir = '{}/work'.format(bgt_setup.SCRIPT_ROOT)
    if not os.path.exists('{}/results'.format(workdir)):
        os.makedirs('{}/results'.format(workdir))
    return workdir


def compare_before_after_counts_csv(host, port, dbname, user, password):
    log.info('Aanmaken csv bestand met vergelijking aantallen database vs. gml bstanden.')
    workdir = create_work_dir()
    csv_name = '{}/results/vergelijkings_resultaat-{}.csv'.format(workdir, datetime.now().strftime("%Y%m%d-%H%M%S"))
    results_table = [[k, v['db'], v['file']] for k, v in _compare_counts(host, port, dbname, user, password).items()]
    with open(csv_name, 'w') as csvfile:
        my_writer = csv.writer(csvfile, delimiter=';', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        my_writer.writerow(['name', 'database', 'file'])
        for row in sorted(results_table, key=lambda x: x[0]):
            my_writer.writerow(row)
    log.info('csv bestand {} aangemaakt'.format(csv_name))


def _compare_counts(host, port, dbname, user, password):
    workdir = create_work_dir()
    gml_dispatch = {
        'bgt_begroeidterreindeel': ['plantcover', 'bgt_begroeidterreindeel'],
        'bgt_onbegroeidterreindeel': ['onbegroeidterreindeel', 'bgt_onbegroeidterreindeel'],
        'bgt_ondersteunendwaterdeel': ['ondersteunendwaterdeel', 'bgt_ondersteunendwaterdeel'],
        'bgt_ondersteunendwegdeel': ['auxiliarytrafficarea', 'bgt_ondersteunendwegdeel'],
        'bgt_ongeclassificeerdobject': ['ongeclassificeerdobject', 'bgt_ongeclassificeerdobject'],
        'bgt_openbareruimtelabel': ['openbareruimtelabel', 'bgt_openbareruimtelabel'],
        'bgt_overbruggingsdeel': ['bridgeconstructionelement', 'bgt_overbruggingsdeel'],
        'bgt_pand': ['buildingpart', 'bgt_pand'],
        'bgt_plaatsbepalingspunt': ['plaatsbepalingspunt', 'bgt_plaatsbepalingspunt'],
        'bgt_tunneldeel': ['tunnelpart', 'bgt_tunneldeel'],
        'bgt_waterdeel': ['waterdeel', 'bgt_waterdeel'],
        'bgt_wegdeel': ['trafficarea', 'bgt_wegdeel'],
        'bgt_bak': ['bak', 'imgeo_bak'],
        'bgt_bord': ['bord', 'imgeo_bord'],
        'bgt_functioneelgebied': ['functioneelgebied', 'imgeo_functioneelgebied'],
        'bgt_gebouwinstallatie': ['buildingInstallation', 'imgeo_gebouwinstallatie'],
        'bgt_installatie': ['installatie', 'imgeo_installatie'],
        'bgt_kast': ['kast', 'imgeo_kast'],
        'bgt_kunstwerkdeel': ['kunstwerkdeel', 'imgeo_kunstwerkdeel'],
        'bgt_mast': ['mast', 'imgeo_mast'],
        'bgt_overigbouwwerk': ['overigbouwwerk', 'imgeo_overigbouwwerk'],
        'bgt_overigescheiding': ['overigescheiding', 'imgeo_overigescheiding'],
        'bgt_paal': ['paal', 'imgeo_paal'],
        'bgt_put': ['put', 'imgeo_put'],
        'bgt_scheiding': ['scheiding', 'imgeo_scheiding'],
        'bgt_sensor': ['sensor', 'imgeo_sensor'],
        'bgt_spoor': ['railway', 'imgeo_spoor'],
        'bgt_straatmeubilair': ['straatmeubilair', 'imgeo_straatmeubilair'],
        'bgt_vegetatieobject': ['solitaryvegetationobject', 'imgeo_vegetatieobject'],
        'bgt_waterinrichtingselement': ['waterinrichtingselement', 'imgeo_waterinrichtingselement'],
        'bgt_weginrichtingselement': ['weginrichtingselement', 'imgeo_weginrichtingselement']
    }

    def count_table_rows(table, host=host, port=port, database=dbname, user=user, password=password):
        res = -1
        conn = psycopg2.connect(
            "host={} port={} dbname={} user={}  password={}".format(host, port, database, user, password)
        )
        dbcur = conn.cursor()
        try:
            dbcur.execute("SELECT count(*) FROM imgeo.{};".format(table))
            for row in dbcur:
                res = row[0]
        except psycopg2.DatabaseError as e:
            log.debug("Database exception: command :%s" % str(e))
        return res

    def count_file_object(filename, object):
        logfile = '{WORK}/log/tel_bestand_object_gml.{GML}.{OBJ}.{TIMESTAMP}'.format(
            WORK=workdir, GML=filename, OBJ=object, TIMESTAMP=datetime.now().strftime("%Y%m%d-%H%M%S"))
        gml_location = '{WORK}/GML/{GML}.gml'.format(WORK=workdir, GML=filename)
        cmd = 'ogrinfo -q {GML} -sql "select count(*) from {OBJ}"'.format(GML=gml_location, OBJ=object)
        p = Popen(cmd, shell=True, stdout=PIPE, stderr=STDOUT)
        output = str(p.stdout.read(), encoding='utf-8')
        f = open(logfile, 'w')
        f.write(output)
        f.close()
        if output.split('\n')[0] == 'FAILURE:':
            res = -1
        else:
            res = int(output.split('\n')[-3].split(' = ')[-1])
        return res

    # create log
    if not os.path.exists('{}/log'.format(workdir)):
        os.makedirs('{}/log'.format(workdir))

    result_items = {}
    for k, v in gml_dispatch.items():
        result_items[k] = {'file': -1, 'db': -1}
        result_items[k]['file'] = count_file_object(k, v[0])
        result_items[k]['db'] = count_table_rows(v[1])
    return result_items


def create_comparison_data( host, port, dbname, user, password):
    """
    creates tables for checking value distribution and summing.
    This is done bij dynamically generating a SQL/DML script. That in in turn is populates the database with values
    for comparison
    :return:
    """
    loc_pgsql = fme_sql_utils.SQLRunner(
        host=host, port=port, dbname=dbname,
        user=user, password=password)

    def create_freq_csv(rows, name):
        log.info('Aanmaken csv bestand met vergelijking aantallen database vs. gml bstanden.')
        workdir = create_work_dir()
        csv_name = '{}/results/{}-{}.csv'.format(workdir, name, datetime.now().strftime("%Y%m%d-%H%M%S"))
        with open(csv_name, 'w') as csvfile:
            my_writer = csv.writer(csvfile, delimiter=';', quotechar='"', quoting=csv.QUOTE_MINIMAL)
            for row in rows:
                my_writer.writerow(row)
        log.info('csv bestand {} aangemaakt'.format(csv_name))

    def generate_and_run_sql(voor):
        new_script = loc_pgsql.run_sql_script(
            '{app}/fme_source_sql/{voor}'.format(app=bgt_setup.SCRIPT_ROOT, voor=voor))
        if len(new_script) > 0:
            loc_pgsql.run_sql('\n'.join([c[0] for c in new_script]))
            log.info("Performed `comparison.{voor}`.".format(voor=voor))
        else:
            log.info("No data found by comparison.{voor}`".format(voor=voor))

    for script in [
        '080_frequentieverdeling_db.sql', '080_frequentieverdeling_gml.sql',
        '080_tel_db.sql', '080_tel_gml.sql'
    ]:
        generate_and_run_sql(script)

    # Output results of the comparison of GML and DB
    create_freq_csv(
        loc_pgsql.run_sql_script(
            '{app}/fme_source_sql/080_vergelijk_gml_db.sql'.format(app=bgt_setup.SCRIPT_ROOT)),
        'vergelijk_gml_db')

    # Output results of the frequention distribution GML and DB
    create_freq_csv(
        loc_pgsql.run_sql_script(
            '{app}/fme_source_sql/080_frequentieverdeling_gml_db.sql'.format(app=bgt_setup.SCRIPT_ROOT)),
        'freq_verdeling_gml_db_alle_kolommen')

    log.info("Ready creating comparison data")
