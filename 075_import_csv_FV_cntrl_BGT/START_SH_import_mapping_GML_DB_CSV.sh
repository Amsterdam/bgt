#!/bin/bash

# positionele parameters voor locatie mappingbestand en toegang database
locatie_CSV=$1
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

logbestand=${working_dir}/log/import_mapping_gml_db_csv.${datum_tijd}.log


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    START_SH_import_mapping_GML_DB_CSV.sh             *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (Controle Verwerving)                         *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :                                                        *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel:                     importen van bestand mapping.csv in tabel         *"
# "*                           imgeo_controle.mapping_gml_db                     *"
# "*                           tbv mapping GML-DB-tabel met BGT-IMGEO-tabel DB   *"
# "*                                                                             *"
# "*                           Let op, mapping.csv staat lokaal op:              *"
# "*                           C:\BGT\BGT_import_mapping_gml_db_csv\CSV\         *"
# "*                           als parameter aan Linux-script meegeven als:      *"
# "*                           C:\\BGT\\BGT_import_mapping_gml_db_csv\\CSV       *"
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
# "* Ron van Barneveld, IV-BI  22-07-2016   1.00.0   RC1: initiele aanmaak       *"
# "* Raymond Young, IV-BI      05-08-2016   1.00.0   RC1: - splits START_SH en   *"
# "*                                                        aanmaak-script.SH    *"
# "*                                                      - parameters -> log    *"
# "*                                                      - wijz. parameternamen *"
# "*                                                      - interpr. met bash    *"
# "* Raymond Young, IV-BI      09-08-2016   1.00.0   RC1: gewijzigde logging     *"
# "*                                                                             *"                                                                   
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             locatie_CSV           locatie CSV-mapping-bestand *"
# "* Parameter 2 :             db_server             database-server BGT-gegevs  *"
# "* Parameter 3 :             database              database BGT-gegevens       *"
# "* Parameter 4 :             db_port               poort naar database-server  *"
# "* Parameter 5 :             db_user               gebruiker t.b.v. BGT        *"
# "*                                                                             *"
# "*******************************************************************************"
# ""

# Start dit script als volgt:
#
# sh START_SH_import_mapping_GML_DB_CSV.sh <LOCATIE_CSV> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh START_SH_import_mapping_GML_DB_CSV.sh C:\\BGT\\BGT_import_mapping_gml_db_csv\\CSV 10.62.86.193 bgt_dev_local 5433 bgt
# (of uiteraard andere locatie- of database-gegevens)
# Als niet alle parameters 1 t/m 5 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).


echo
echo "*******************************************************************************"
echo "* Start script $0 ... "
echo "* Start importeren CSV-mapping-bestand in BGT-database ...                    *"
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
        locatie_CSV='./CSV'
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

sh import_mapping_GML_DB_CSV.sh ${locatie_CSV} ${db_server} ${database} ${db_port} ${db_user} 2>&1 | tee ${logbestand}

# Bovenstaande START_SH_import_mapping_GML_DB_CSV.sql trapt het volgende aan:
# COPY imgeo_controle.mapping_gml_db(gmlnaam,dbnaam) FROM 'C:\\BGT\\BGT_import_mapping_gml_db_csv\\CSV\\mapping.csv' DELIMITER ';' CSV HEADER;
# Hiermee wordt het mapping.csv bestand geïmporteerd in tabel imgeo_controle.mapping_gml_db
# NB de locatie_CSV is in dit geval de C-schijf op de Windowsmachine en moet op de volgende manier worden meegegeven: 
# C:\\BGT\\BGT_import_mapping_gml_db_csv\\CSV
#


echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met importeren CSV-mapping-bestand in BGT-database.                   *"
echo "*******************************************************************************"
echo
