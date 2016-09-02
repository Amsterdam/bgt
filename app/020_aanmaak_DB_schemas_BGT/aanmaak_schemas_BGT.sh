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
whoami=$(whoami)
who_m=$(who -m)
working_dir=$(pwd)
datum_tijd=$(date +"%Y%m%d_%H%M%S")
logbestand=${working_dir}/log/aanmaak_schemas_BGT.${datum_tijd}.log


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    aanmaak_schemas_BGT.sh                            *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (database)                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      START_SH_aanmaak_schemas_BGT.sh                   *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    Aanmaken DB-schema's t.b.v. BGT.                  *"
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
# "*                                                                             *"
# "* Ron van Barneveld, IV-BI  22-07-2016   1.00.0   RC1: initiële aanmaak       *"
# "* Raymond Young, IV-BI      04-08-2016   1.00.0   RC1: - splits START_SH en   *"
# "*                                                        aanmaak-script.SH    *"
# "*                                                      - parameters -> log    *"
# "*                                                      - wijz. parameternamen *"
# "*                                                      - interpr. met bash    *"
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


# ""
# "*******************************************************************************"
# "* Aanmaken DB-schemas BGT ...                                                 *"
# "*******************************************************************************"
# ""

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

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -f START_SQL_aanmaak_schemas_BGT.sql

# Start dit shellscript START_SH_schema.sh door:
# in Ubuntu sh START_SH_schema.sh te runnen
# NB als parameters 1 t/m 4 niet zijn gevuld, wordt ontwikkel-BGT-database DataPunt benaderd

# Bovenstaande roept een START_SQL_schema.sql aan en roept een aantal create sqlscripts aan om schema's aan te maken in de bgt_database
#   

# 
#


# ""
# "*******************************************************************************"
# "* Klaar met aanmaken DB-schemas BGT.                                          *"
# "*******************************************************************************"
# "" 
