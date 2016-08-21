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
logbestand=aanmaak_schemas_BGT.${datum_tijd}.log


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    START_SH_aanmaak_schemas_BGT.sh                   *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (database)                                    *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :                                                        *"
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


# Start dit shellscript START_SH_aanmaak_schemas_BGT.sh door:
# in Ubuntu sh START_SH_aanmaak_schemas_BGT.sh te runnen
# NB als parameters 1 t/m 4 niet zijn gevuld, wordt ontwikkel-BGT-database DataPunt benaderd


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

sh aanmaak_schemas_BGT.sh ${db_server} ${database} ${db_port} ${db_user} 2>&1 | tee ${logbestand}

# Bovenstaande roept een START_SQL_aanmaak_schemas_BGT.sql aan
# dat op zijn beurt weer een aantal create sqlscripts aanroept om schema's aan te maken in de bgt_database
#   


# ""
# "*******************************************************************************"
# "* Klaar met aanmaken DB-schemas BGT.                                          *"
# "*******************************************************************************"
# "" 
