#!/bin/bash

# positionele parameters voor toegang database
db_server=$1
database=$2
db_port=$3
db_user=$4
# wachtwoord kan niet worden meegegegeven;
# aangenomen wordt dat dat wordt gezet in bestand <Linux-gebruiker>/.pgpass.
# (let op de rechten op .pgpass ALLEEN user Root mag read/write rechten hebben.)
# (als dit niet is gedaan, moet het wachtwoord met de hand worden ingetikt
# voor ieder keer dat met een script de database wordt benaderd)
# BGT-database moet openstaan voor benadering van buitenaf;
# dit moet zijn geregeld in bestand pg_hba.conf.
# Zie voorbeeldbestandjes in submapje configuratie.

# Hieronder t.b.v. de logging een aantal standaardvariabelen uit de Linux-omgeving:
whoami=$(whoami)   					# whoami - print effective userid
who_m=$(who -m)    					# who - show who is logged on, optie: -m     only hostname and user associated with stdin
working_dir=$(pwd) 					# pwd - print name of current/working directory
datum_tijd=$(date +"%Y%m%d_%H%M%S") # date - print or set the system date and time

logbestand=${working_dir}/log/tel_db.${datum_tijd}.log
sql_script=${working_dir}/log/tel_db.${datum_tijd}.sql


echo
echo "-------------------------------------------------------------------------------"
echo "ParameterX: os_user     = ${whoami} / ${who_m}"
echo "ParameterY: working_dir = ${working_dir}"
echo "ParameterZ: datum_tijd  = ${datum_tijd}"
echo "Parameter0: script      = $0"
echo "Parameter1: db_server   = ${db_server}"
echo "Parameter2: database    = ${database}"
echo "Parameter3: db_port     = ${db_port}"
echo "Parameter4: db_user     = ${db_user}"
echo "-------------------------------------------------------------------------------"
echo

echo
echo "Leeg tabel TEL_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "TRUNCATE TABLE imgeo_controle.TEL_DB;"

echo
echo "Genereer SQL-script voor tellen rijen in BGT-/IMGEO-tabellen en vullen tabel TEL_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -t -c "select 'insert into imgeo_controle.tel_db (select ' || chr(39) || table_name || chr(39) || ' as tabelnaam,' || ' count(*) as aantal from '  || 'imgeo.'|| table_name || ');' as smt
from information_schema.tables
where table_schema='imgeo'
and ( table_name like 'bgt_%'
or   table_name like 'imgeo_%')
order by table_name;" 2>&1 | tee ${sql_script}

# Bovenstaande geeft de volgende uitvoer: (insert_scripts met tellingen rijen per BGT-/IMGEO-tabel (= objectklasse) in IMGEO-schema in BGT-database)

echo
echo "Voer SQL-script uit voor tellen rijen in BGT-/IMGEO-tabellen en vullen tabel TEL_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -f ${sql_script}

# Bovenstaande geeft de volgende uitvoer in tabel imgeo_controle.tel_db: tellingen rijen per BGT-/IMGEO-tabel (= objectklasse) in IMGEO-schema in BGT-database


echo
echo "**************************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met tellen aantallen per objectklasse DB.                                    *"
echo "**************************************************************************************"
echo 
