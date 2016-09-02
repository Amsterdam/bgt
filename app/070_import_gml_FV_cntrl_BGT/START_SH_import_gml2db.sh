#!/bin/bash

# positionele parameters voor locatie GML-bestanden en toegang database
locatie_GML=$1
db_server=$2
database=$3
db_port=$4
db_user=$5
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

logbestand=${working_dir}/log/import_gml2db.${datum_tijd}.log
sql_script=${working_dir}/log/drop_imgeo_gml_tables.${datum_tijd}.sql
db_schema=imgeo_gml


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    START_SH_import_gml2db.sh                         *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (Verwerving)                                  *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :                                                        *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel:                     Importeren GML-bestanden in BGT-database          *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* DATAPUNT-BGT-versienr :   1.00.0                                            *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Wijzigingsgeschiedenis :                                                    *"
# "*                                                                             *"
# "* auteur                    datum        versie   wijziging                   *"
# "* -----------------------   ----------   ------   --------------------------- *"
# "* Ron van Barneveld, IV-BI  01-07-2016   1.00.0   RC1: initiële aanmaak       *"
# "* Raymond Young, IV-BI      04-08-2016   1.00.0   RC1: - splits START_SH en   *"
# "*                                                        aanmaak-script.SH    *"
# "*                                                      - parameters -> log    *"
# "*                                                      - wijz. parameternamen *"
# "*                                                      - interpr. met bash    *"
# "* Raymond Young, IV-BI      09-08-2016   1.00.0   RC1: gewijzigde logging     *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             locatie_GML           locatie GML-bestanden       *"
# "* Parameter 2 :             db_server             database-server BGT-gegevs  *"
# "* Parameter 3 :             database              database BGT-gegevens       *"
# "* Parameter 4 :             db_port               poort naar database-server  *"
# "* Parameter 5 :             db_user               gebruiker t.b.v. BGT        *"
# "*                                                                             *"
# "*******************************************************************************"
# ""


# Start dit script als volgt, waarbij voor parameters (<HOOFDLETTERS>, <LOCATIE_GML> etc.) juiste waarden dienen te worden meegegeven:
#
# sh START_SH_import_gml2db.sh <LOCATIE_GML> <DB_SERVER>  <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh START_SH_import_gml2db.sh ./GML/ 10.62.86.35 bgt_dev_local 5433 bgt --> hiermee wordt de lokale GML aangesproken en de lokale database benaderd.

# Ter info hieronder een voorbeeld van de parameters lokaal op de laptop:
# locatie_GML=./GML/     --> dit is een map met GML-bestanden dat bij het scriptmap wordt meegegegeven.
# db_server=10.62.86.35  --> dit is het ip-adres van de lokaal database op de laptop (met ipconfig in cmd te achterhalen)  
# database=bgt_dev_local --> databasenaam afhankelijk van lokale naamgeving
# db_port=5433           --> dit db_portnummer is specifiek van de lokale database van Ron van Barneveld.
# db_user=bgt            --> default user van de database

# (of uiteraard andere locatie- of database-gegevens)
# Als niet ALLE parameters 1 t/m 5 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).

# Ter info hieronder de parameters op datapunt:
# locatie_GML=./GML/ --> dit is een map met GML-bestanden dat bij het scriptmap wordt meegegegeven.
# db_server=85.222.225.45
# database=bgt_dev
# db_port=8080
# db_user=bgt


echo
echo "*******************************************************************************"
echo "* Start script $0 ..."
echo "* Start importeren GML-bestanden in BGT-database ...                          *"
echo "*******************************************************************************"
echo

if test "$#" -ne "5"
  then
    # als niet alle parameters 1 t/m 5 zijn gevuld,
	# worden GML-bestanden gezocht op locatie huidige directory
	# en wordt ontwikkel-BGT-database DataPunt benaderd
    # echo 'test $# -ne 5' : Vul variabelen met standaardwaarden ...
    if test "$1" = ""
      then
        locatie_GML='./GML/'
    fi
    if test "$2" = ""
      then
        db_server='85.222.225.45'
    fi
	if test "$3" = ""
      then
        database='bgt_dev'
    fi
    if test "$4" = ""
      then
        db_port='8080'
    fi
    if test "$5" = ""
      then
        db_user='bgt'
    fi
fi

sh import_gml2db.sh ${locatie_GML} ${db_server} ${database} ${db_port} ${db_user} 2>&1 | tee ${logbestand}

echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met importeren GML-bestanden in BGT-database.                         *"
echo "*******************************************************************************"
echo
