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

logbestand=${working_dir}/log/vergelijk_gml_db.${datum_tijd}.log


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
echo "Leeg tabel VERGELIJK_GML_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "TRUNCATE TABLE imgeo_controle.VERGELIJK_GML_DB;"

echo
echo "Tel en vergelijk aantallen rijen in GML- en BGT-/IMGEO-tabellen en vul tabel VERGELIJK_GML_DB in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "insert into imgeo_controle.vergelijk_gml_db
(SELECT    db.tabelnaam                      as tabelnaam
,          gml.aantal                        as aantal_gml
,          db.aantal                         as aantal_db
,          gml.aantal - db.aantal            as verschil
FROM       imgeo_controle.tel_gml               gml
left join  imgeo_controle.mapping_gml_db        map          on lower(gml.tabelnaam)   = lower(map.gmlnaam)
right join imgeo_controle.tel_db                db           on lower(map.dbnaam)      = lower(db.tabelnaam)
order by   db.tabelnaam);"

# Bovenstaande telt en vergelijkt aantallen rijen in GML- en BGT-/IMGEO-tabellen en vult tabel VERGELIJK_GML_DB in BGT-database:
# NB in de BGT-/IMGEO-schema's zijn een aantal Objectklassen die nog niet in de GMLdownload zitten vandaar dat deze leeg zijn in de GML aantallen.
#   


echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met vergelijken van de tellingen per Objectklasse GML en DB.          *"
echo "*******************************************************************************"
echo
