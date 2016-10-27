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



sh vergelijk_gml_db.sh ${db_server} ${database} ${db_port} ${db_user} 2>&1 | tee ${logbestand}

# Bovenstaande geeft een vergelijking van de tellingen per Objectklasse tussen de geïmporteerde GML-bestanden in de postgresdatabase en de BGT-/IMGEO-schema's:
# NB in de BGT-/IMGEO-schema's zijn een aantal Objectklassen die nog niet in de GMLdownload zitten vandaar dat deze leeg zijn in de GML aantallen.
#   


echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met vergelijken van de tellingen per Objectklasse GML en DB.          *"
echo "*******************************************************************************"
echo
