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

logbestand=${working_dir}/log/frequentieverdeling_gml.${datum_tijd}.log
sql_script=${working_dir}/log/frequentieverdeling_gml.${datum_tijd}.sql



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
echo "Leeg tabel FREQUENTIEVERDELING_GML in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "TRUNCATE TABLE imgeo_controle.FREQUENTIEVERDELING_GML;"

echo
echo "Genereer SQL-script voor vullen tabel FREQUENTIEVERDELING_GML in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user}  -t -c "select 'insert into imgeo_controle.frequentieverdeling_gml (select '|| chr(39) || table_name || chr(39) || ' as tabelnaam,' || chr(39) || column_name || chr(39) || ' as kolomnaam, ' || column_name || ', count (' || column_name || ') as aantal from ' || table_schema || '.' || table_name || ' group by ' || column_name || ' order by ' || column_name || ', aantal );' as smt
FROM information_schema.columns
where table_schema='imgeo_gml'
and column_name in (
  'begroeidterreindeeloptalud'
, 'bgt_fysiekvoorkomen'
, 'bgt_type'
, 'bronhouder'
, 'class'
, 'function'
, 'hoortbijtypeoverbrugging'
-- , 'identificatiebagopr'
-- , 'identificatiebagpnd'
, 'onbegroeidterreindeeloptalud'
, 'ondersteunendwegdeeloptalud'
, 'openbareruimtetype'
, 'overbruggingisbeweegbaar'
, 'plus_functieondersteunendwegdeel'
, 'plus_functiewegdeel'
, 'plus_fysiekvoorkomen'
, 'plus_fysiekvoorkomenondersteunendwegdeel'
, 'plus_fysiekvoorkomenwegdeel'
, 'plus_type'
, 'plus_typegebouwinstallatie'
, 'surfacematerial'
, 'wegdeeloptalud'
)
order by table_schema, table_name, column_name;" 2>&1 | tee ${sql_script}

# Bovenstaande geeft de volgende uitvoer (insert_scripts met aantal attribuutwaarden per attribuut van alle gmltabellen in bgt_database):
#  bv insert into imgeo_gml.cntrl_gml_attribuutwaarden (select 'auxiliarytrafficarea' as tabelnaam,'function' as kolomnaam,function ,count (function) from imgeo_gml.auxiliarytrafficarea group by function order by function);
#  enzovoorts 

echo
echo "Voer SQL-script uit voor vullen tabel FREQUENTIEVERDELING_GML in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -f ${sql_script}

# Bovenstaande geeft de volgende uitvoer in tabel imgeo_controle.frequentieverdeling_gml: frequentieverdelingen per attribuut per BGT-/GML-tabel (= objectklasse) in IMGEO_GML-schema in BGT-database


echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met maken frequentieverdeling BGT-/GML-tabellen in schema IMGEO_GML.  *"
echo "*******************************************************************************"
echo 
