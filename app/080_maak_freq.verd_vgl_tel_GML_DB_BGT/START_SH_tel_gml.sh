#!/bin/bash

# positionele parameters voor locatie GML-bestanden en toegang database
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

logbestand=${working_dir}/log/tel_gml.${datum_tijd}.log
sql_script=${working_dir}/log/tel_gml.${datum_tijd}.sql

sh tel_gml.sh ${db_server} ${database} ${db_port} ${db_user} 2>&1 | tee ${logbestand}

# Bovenstaande geeft de volgende uitvoer in tabel imgeo_controle.tel_gml: tellingen rijen per GML-tabel (= objectklasse) in schema IMGEO_GML in BGT-database


echo
echo "**************************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met tellen aantallen per objectklasse GML.                                   *"
echo "**************************************************************************************"
echo 
