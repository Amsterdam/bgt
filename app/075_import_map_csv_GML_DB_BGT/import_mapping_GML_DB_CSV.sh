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
# "* Naam :                    import_mapping_GML_DB_CSV.sh                      *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (Controle Verwerving)                         *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      START_SH_import_mapping_GML_DB_CSV.sh             *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel:                     importen van bestand mapping.csv in tabel         *"
# "*                           imgeo_controle.mapping_gml_db                     *"
# "*                           tbv mapping GML-DB-tabel met BGT-IMGEO-tabel DB   *"
# "*                                                                             *"
# "*                           Let op, mapping.csv staat lokaal op:              *"
# "*                           C:\BGT\075_import_map_csv_GML_DB_BGT\CSV\         *"
# "*                           als parameter aan Linux-script meegeven als:      *"
# "*                           C:\\BGT\\\\075_import_map_CSV_GML_DB_BGT\\CSV     *"
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
# "*                                                      - eerst truncate table *"
# "* Raymond Young, IV-BI      09-08-2016   1.00.0   RC1: gewijzigde logging     *"
# "* Raymond Young, IV-BI      26-09-2016   1.00.0   RC1: toevoeging kolommen    *"
# "*                                                 gmlbestand,shpview,dgnview  *"
# "* Raymond Young, IV-BI      26-09-2016   1.00.0   RC1: vervangen kolommen     *"
# "*                                                 shpview,dgnview door        *"
# "*                                                 een extractieview           *"
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
# sh import_mapping_GML_DB_CSV.sh <LOCATIE_CSV> <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: sh import_mapping_GML_DB_CSV.sh C:\\BGT\\\\075_import_map_csv_GML_DB_BGT\\CSV 10.62.84.42 bgt_dev_local 5433 bgt
# Let op: viermaal backslash '\\\\' vanwege opvolgende '075' (= Ascii-code '=')
# (of uiteraard andere locatie- of database-gegevens)
# Als niet alle parameters 1 t/m 5 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).


echo
echo "*******************************************************************************"
echo "* Start script $0 ..."
echo "* Start importeren CSV-mapping-bestand in BGT-database ...                    *"
echo "*******************************************************************************"
echo

if test "$#" -ne "5"
  then
    # als niet alle parameters 1 t/m 5 zijn gevuld,
	# word CSV-mapping-bestand gezocht op locatie huidige directory
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

# Hieronder worden de omgevingsvariabelen in de VM Ubuntu Linux-omgeving getoond

echo
echo "-------------------------------------------------------------------------------"
echo "ParameterX: os_user     = ${whoami} / ${who_m}"
echo "ParameterY: working_dir = ${working_dir}"
echo "ParameterZ: datum_tijd  = ${datum_tijd}"
echo "Parameter0: script      = $0"
echo "Parameter1: locatie_CSV = ${locatie_CSV}"
echo "Parameter2: db_server   = ${db_server}"
echo "Parameter3: database    = ${database}"
echo "Parameter4: db_port     = ${db_port}"
echo "Parameter5: db_user     = ${db_user}"
echo "-------------------------------------------------------------------------------"
echo

echo
echo "Leeg mapping-tabel in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "TRUNCATE TABLE imgeo_controle.mapping_gml_db;"

echo
echo "Importeer CSV-mapping-bestand in mapping-tabel in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "COPY imgeo_controle.mapping_gml_db(gmlbestand,gmlnaam,dbnaam,extractieview) FROM '${locatie_CSV}\\mapping.csv' DELIMITER ';' CSV HEADER;"

# Bovenstaande START_SH_import_mapping_GML_DB_CSV.sql trapt het volgende aan:
# COPY imgeo_controle.mapping_gml_db(gmlnaam,dbnaam) FROM 'C:\\BGT\\\\075_import_map_csv_GML_DB_BGT\\CSV\\mapping.csv' DELIMITER ';' CSV HEADER;
# Hiermee wordt het mapping.csv bestand geïmporteerd in tabel imgeo_controle.mapping_gml_db
# NB de locatie_CSV is in dit geval de C-schijf op de Windowsmachine en moet op de volgende manier worden meegegeven: 
# C:\\BGT\\\\075_import_map_csv_GML_DB_BGT\\CSV
#


echo
echo "*******************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met importeren CSV-mapping-bestand in BGT-database.                   *"
echo "*******************************************************************************"
echo
