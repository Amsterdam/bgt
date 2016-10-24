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

logbestand=${working_dir}/log/tel_gml.${datum_tijd}.log
sql_script=${working_dir}/log/tel_gml.${datum_tijd}.sql


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    tel_gml.sh                                        *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (Verwerving)                                  *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      START_SH_tel_gml.sh                               *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    SQL-scripts aanmaken en aftrappen voor            *"
# "*                           tellen aantallen per objectklasse                 *"
# "*                           in GML-tabellen in schema IMGEO_GML               *"
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
# "* Ron van Barneveld, IV-BI  14-07-2016   1.00.0   RC1: nieuw schema en tabel  *"
# "* Raymond Young, IV-BI      04-08-2016   1.00.0   RC1: - splits START_SH en   *"
# "*                                                        aanmaak-script.SH    *"
# "*                                                      - parameters -> log    *"
# "*                                                      - wijz. parameternamen *"
# "*                                                      - interpr. met bash    *"
# "* Raymond Young, IV-BI      16-08-2016   1.00.0   RC1: toevoegen leegmaken    *"
# "*                                                 tabel                       *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Parameter 1 :             db_server             database-server BGT-gegevs  *"
# "* Parameter 2 :             database              database BGT-gegevens       *"
# "* Parameter 3 :             db_port               poort naar database-server  *"
# "* Parameter 4 :             db_user               gebruiker t.b.v. BGT        *"
# "*                                                                             *"
# "*******************************************************************************"
# ""


# Start dit shellscript als volgt, waarbij voor parameters (<HOOFDLETTERS>, <DB_SERVER> etc.) juiste waarden dienen te worden meegegeven:
#
# in Linux: sh tel_gml.sh <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: tel_gml.sh 85.222.225.45 bgt_dev 8080 bgt
# (of uiteraard andere database-gegevens)
# Als niet alle parameters 1 t/m 4 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).


echo
echo "*******************************************************************************"
echo "* Start script $0 ..."
echo "* Start tellen aantallen per objectklasse GML ...                             *"
echo "*******************************************************************************"
echo

# lokale parameters laptop Ron
# server=10.62.86.35 # ip-adres laptop (lokaal; variabel!) 
# database=bgt_dev_local
# db_port=5433
# db_user=bgt

if test "$#" -ne "4"
  then
    # als niet alle parameters 1 t/m 4 zijn gevuld,
	# wordt ontwikkel-BGT-database DataPunt benaderd
    # echo 'test $# -ne 4' : Vul parameters met standaardwaarden ...
    if test "$1" = ""
      then
        db_server='85.222.225.45'
    fi
	if test "$2" = ""
      then
        database='bgt_dev'
    fi
    if test "$3" = ""
      then
        db_port='8080'
    fi
    if test "$4" = ""
      then
        db_user='bgt'
    fi
fi

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
echo "Leeg tabel TEL_GML in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "TRUNCATE TABLE imgeo_controle.TEL_GML;"

echo
echo "Genereer SQL-script voor tellen rijen in GML-tabellen en vullen tabel TEL_GML in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -t -c "select 'insert into imgeo_controle.tel_gml (select ' || chr(39) || table_name || chr(39) || ' as tabelnaam,' || ' count(*) as aantal from '  || 'imgeo_gml.'|| table_name || ');' as smt
from information_schema.tables
where table_schema='imgeo_gml'
order by table_name;" 2>&1 | tee ${sql_script}

# Bovenstaande geeft de volgende uitvoer: (insert_scripts met tellingen rijen per GML-tabel (= objectklasse) in schema IMGEO_GML in BGT-database)

echo
echo "Voer SQL-script uit voor tellen rijen in GML-tabellen en vullen tabel TEL_GML in BGT-database ..."
echo

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -f ${sql_script}

# Bovenstaande geeft de volgende uitvoer in tabel imgeo_controle.tel_gml: tellingen rijen per GML-tabel (= objectklasse) in schema IMGEO_GML in BGT-database


echo
echo "**************************************************************************************"
echo "* Klaar met script $0."
echo "* Klaar met tellen aantallen per objectklasse GML.                                   *"
echo "**************************************************************************************"
echo 
