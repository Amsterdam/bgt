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
sqlbestand=${working_dir}/log/vergelijk_gml_db.${datum_tijd}.sql


# ""
# "*******************************************************************************"
# "*                                                                             *"
# "* Naam :                    vergelijk_gml_db.sh                               *"
# "*                                                                             *"
# "* Systeem :                 DATAPUNT                                          *"
# "*                                                                             *"
# "* Module :                  BGT (Verwerving)                                  *"
# "*                                                                             *"
# "* Schema / Gegevensstroom : BGT                                               *"
# "*                                                                             *"
# "* Aangeroepen vanuit :      START_vergelijk_gml_db.sh                         *"
# "*                                                                             *"
# "*******************************************************************************"
# "*                                                                             *"
# "* Doel :                    SQL-scripts aanmaken en aftrappen voor            *"
# "*                           vergelijken aantallen per objectklasse            *"
# "*                           in GML-bestanden en DB-tabellen BGT_* en IMGEO_*  *"
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
# in Linux: sh vergelijk_gml_db.sh <DB_SERVER> <DATABASE> <DB_PORT> <DB_USER>
# parameters tussen rechte haken te vervangen door de juiste waarden,
# bijvoorbeeld: vergelijk_gml_db.sh 85.222.225.45 bgt_dev 8080 bgt
# (of uiteraard andere database-gegevens)
# Als niet alle parameters 1 t/m 4 zijn gevuld, krijgen die een standaardwaarde (zie hieronder).


echo
echo "*******************************************************************************"
echo "* Start vergelijken van de tellingen per Objectklasse GML en DB ...           *"
echo "*******************************************************************************"
echo

#lokale parameters laptop Ron
# db_server=10.62.86.35 # ip-adres laptop (lokaal; variabel!) 
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

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -c "insert into imgeo_controle.vergelijk_gml_db
(SELECT c.tabelnaam
,      a.aantal as aantal_gml
,      c.aantal as aantal_db
,      a.aantal - c.aantal as verschil
FROM imgeo_controle.tel_gml a
left join imgeo_controle.mapping_gml_db b on a.tabelnaam = b.gmlnaam
right join imgeo_controle.tel_db c on lower(b.dbnaam) = c.tabelnaam);" 2>&1 | tee ${sqlbestand}

psql -h ${db_server} -d ${database} -p ${db_port} -U ${db_user} -f ${sqlbestand}

# Bovenstaande geeft een vergelijking van de tellingen per Objectklasse tussen de geïmporteerde GML-bestanden in de postgresdatabase en de BGT-/IMGEO-schema's:
# NB in de BGT-/IMGEO-schema's zijn een aantal Objectklassen die nog niet in de GMLdownload zitten vandaar dat deze leeg zijn in de GML aantallen.
#   


echo
echo "*******************************************************************************"
echo "* Klaar met vergelijken van de tellingen per Objectklasse GML en DB.          *"
echo "*******************************************************************************"
echo
